//
//  GTDBManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/7.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTDatabaseManager.h"
#import "sqlite3.h"
#import "GTLoggerConstants.h"
#import "GTCrashReportFileMeta.h"
#import "GTMsgLayout.h"
#import "GTDateTimeUtil.h"
#import "GTBaseLogEvent.h"
#import "GTStringUtils.h"
#import "GTMutableDictionary.h"
#import "GTAttachmentFileMeta.h"
#import "GTLogFileMeta.h"

#define DATABASE_NAME @"LogMeta.sqlite"

@interface GTDatabaseManager () {
    sqlite3 *db;
    NSString *dbPath;
    dispatch_queue_t operationQueue;
}

@property (nonatomic, strong, nonnull) GTMutableDictionary *layoutDictionary;

@end

@implementation GTDatabaseManager

+ (instancetype)manager {
    static GTDatabaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _layoutDictionary = [[GTMutableDictionary alloc] init];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:LOG_SYSTEM_DIR_NAME];

        BOOL isDir;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
        if (!exists) {
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                [NSException raise:@"CreateSystemDirException" format:@"Create dir failed!"];
            }
        }

        NSString *path = [NSString stringWithFormat:@"/%@/%@", LOG_SYSTEM_DIR_NAME, DATABASE_NAME];
        dbPath = [documentsDirectory stringByAppendingPathComponent:path];
        operationQueue = dispatch_queue_create("com.getui.log.db.manager", NULL);

        if (![self openDataBase]) {
            [NSException raise:@"OpenDatabaseException" format:@"Open database faield!"];
        }
    }
    return self;
}

- (BOOL)openDataBase {
    if (db) {
        return YES;
    }

    if (sqlite3_open([dbPath fileSystemRepresentation], &db) != SQLITE_OK) {
        return NO;
    }

    NSString *sqlLog = @"CREATE TABLE IF NOT EXISTS LogFileMeta (id INTEGER PRIMARY KEY AUTOINCREMENT, loggerName TEXT NOT NULL DEFAULT '', filename TEXT NOT NULL DEFAULT '', fragment INTEGER NOT NULL DEFAULT 0, status INTEGER NOT NULL DEFAULT 0, fileMD5 TEXT DEFAULT '', level INTEGER NOT NULL DEFAULT 0, createTime INTEGER NOT NULL DEFAULT 0, deleteTime INTEGER NOT NULL DEFAULT 0, date TEXT DEFAULT '', eof INTEGER NOT NULL DEFAULT 0)";
    NSString *sqlCrash = @"CREATE TABLE IF NOT EXISTS CrashReportFileMeta (id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT NOT NULL DEFAULT '', createTime INTEGER NOT NULL DEFAULT 0, deleteTime INTEGER NOT NULL DEFAULT 0, status INTEGER NOT NULL DEFAULT 0, fileMD5 TEXT DEFAULT '')";
    NSString *sqlLayout = @"CREATE TABLE IF NOT EXISTS MsgLayout (id INTEGER PRIMARY KEY AUTOINCREMENT, layout TEXT NOT NULL UNIQUE DEFAULT '')";
    NSString *sqlAttachment = @"CREATE TABLE IF NOT EXISTS AttachmentFileMeta (id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT NOT NULL DEFAULT '', sequence INTEGER NOT NULL DEFAULT 0, createTime INTEGER NOT NULL DEFAULT 0, deleteTime INTEGER NOT NULL DEFAULT 0, status INTEGER NOT NULL DEFAULT 0, fileMD5 TEXT DEFAULT '')";

    char *error;
    const char *sql_log_table = [sqlLog UTF8String];
    const char *sql_crash_table = [sqlCrash UTF8String];
    const char *sql_layout_table = [sqlLayout UTF8String];
    const char *sql_attachment_table = [sqlAttachment UTF8String];

    // Check create log file meta table.
    if (sqlite3_exec(db, sql_log_table, NULL, NULL, &error) != SQLITE_OK) {
        return NO;
    }

    // Check create crash report file meta table.
    if (sqlite3_exec(db, sql_crash_table, NULL, NULL, &error) != SQLITE_OK) {
        return NO;
    }

    // Check create msg layout table.
    if (sqlite3_exec(db, sql_layout_table, NULL, NULL, &error) != SQLITE_OK) {
        return NO;
    }

    // Check create attachment file meta table.
    if (sqlite3_exec(db, sql_attachment_table, NULL, NULL, &error) != SQLITE_OK) {
        return NO;
    }

    return YES;
}

- (BOOL)saveLogFileMeta:(GTLogFileMeta *)meta {
    NSString *sqlString;
    if (meta.id == -1) {
        sqlString = [NSString stringWithFormat:@"INSERT INTO LogFileMeta(loggerName, filename, fragment, status, level, createTime, date, eof) VALUES('%@', '%@', %d, %d, %d, %lld, '%@', %d)", meta.loggerName, meta.filename, meta.fragment, meta.status, meta.level, meta.createTime, meta.date, meta.eof];
    } else {
        sqlString = [NSString stringWithFormat:@"UPDATE LogFileMeta SET loggerName='%@', filename='%@', fragment=%d, status=%d, level=%d, createTime=%lld, deleteTime=%lld, eof=%d WHERE id = %lld", meta.loggerName, meta.filename, meta.fragment, meta.status, meta.level, meta.createTime, meta.deleteTime, meta.eof, meta.id];
    }
    return [self executeUpdate:sqlString];
}

- (BOOL)saveCrashReportFileMeta:(GTCrashReportFileMeta *)meta {
    NSString *sqlString;
    if (meta.id == -1) {
        sqlString = [NSString stringWithFormat:@"INSERT INTO CrashReportFileMeta(filename, createTime, status) VALUES('%@', %lld, %d)", meta.filename, meta.createTime, meta.status];
    } else {
        sqlString = [NSString stringWithFormat:@"UPDATE CrashReportFileMeta SET filename='%@', createTime=%lld, deleteTime=%lld, status=%d WHERE id = %lld", meta.filename, meta.createTime, meta.deleteTime, meta.status, meta.id];
    }
    return [self executeUpdate:sqlString];
}

- (int16_t)saveMsgLayout:(GTMsgLayout *)layout {
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM MsgLayout WHERE layout = '%@' LIMIT 1", layout.layout];
    NSString *insert = [NSString stringWithFormat:@"INSERT INTO MsgLayout(layout) VALUES('%@')", layout.layout];

    const char *sql_query = [query UTF8String];
    const char *sql_insert = [insert UTF8String];

    __block int layoutId = -1;
    dispatch_sync(operationQueue, ^{
        sqlite3_stmt *statement = 0x00;
        // Query exist layout.
        if (sqlite3_prepare_v2(db, sql_query, -1, &statement, NULL) == SQLITE_OK) {
            int row_count = 0;
            while (true) {
                int status = sqlite3_step(statement);
                if (status == SQLITE_ROW) {
                    layoutId = sqlite3_column_int(statement, 0);
                    row_count++;
                } else {
                    break;
                }
            }
            if (row_count == 0) {
                // Insert new layout.
                sqlite3_reset(statement);
                if (sqlite3_prepare_v2(db, sql_insert, -1, &statement, NULL) == SQLITE_OK) {
                    if (sqlite3_step(statement) == SQLITE_DONE) {
                        layoutId = (int) sqlite3_last_insert_rowid(db);
                    }
                }
            }
        }
    });
    return layoutId;
}

- (BOOL)saveAttachmentFileMeta:(GTAttachmentFileMeta *)meta {
    NSString *sqlString;
    if (meta.id == -1) {
        sqlString = [NSString stringWithFormat:@"INSERT INTO AttachmentFileMeta(filename, sequence, createTime, status) VALUES('%@', %d, %lld, %d)", meta.filename, meta.sequence, meta.createTime, meta.status];
    } else {
        sqlString = [NSString stringWithFormat:@"UPDATE AttachmentFileMeta SET filename='%@', sequence=%d, createTime=%lld, deleteTime=%lld, status=%d, fileMD5='%@' WHERE id = %lld", meta.filename, meta.sequence, meta.createTime, meta.deleteTime, meta.status, meta.fileMD5, meta.id];
    }
    return [self executeUpdate:sqlString];
}

- (int32_t)findMaxAttachmentSequence {
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM AttachmentFileMeta ORDER BY sequence DESC LIMIT 1"];
    NSArray *result = [self executeQueryAttachmentMetaList:sqlString];
    if (result.count > 0) {
        GTAttachmentFileMeta *meta = [result objectAtIndex:0];
        return meta.sequence;
    }
    return -1;
}

- (int16_t)layoutId:(NSString *)layoutString {
    if ([GTStringUtils isEmpty:layoutString]) {
        return -1;
    }
    id object = [_layoutDictionary objectForKey:layoutString];
    if (object == nil) {
        GTMsgLayout *msgLayout = [[GTMsgLayout alloc] init];
        msgLayout.layout = layoutString;
        int16_t layoutId = [self saveMsgLayout:msgLayout];
        if (layoutId != -1) {
            [_layoutDictionary setObject:@(layoutId) forKey:layoutString];
        }
    } else {
        return [object shortValue];
    }
    return -1;
}

- (BOOL)closeLogFile:(NSString *)loggerName level:(int)level fragment:(int)fragment {
    NSString *date = [GTDateTimeUtil dateString];
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE LogFileMeta SET eof = %d, status = %d WHERE loggerName = '%@' AND level = %d AND fragment = %d AND date = '%@'", YES, FILE_STATE_WILL_UPLOAD, loggerName, level, fragment, date];
    return [self executeUpdate:sqlString];
}

- (BOOL)closeAllLogFile {
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE LogFileMeta SET status=%d, eof=%d WHERE status = %d", FILE_STATE_WILL_UPLOAD, YES, FILE_STATE_NORMAL];
    return [self executeUpdate:sqlString];
}

- (NSArray *)findAllLogFileMetaList {
    NSString *sqlString = @"SELECT * FROM LogFileMeta";
    return [self executeQueryLogMetaList:sqlString];
}

- (NSArray *)findAllNotUploadLogFileMetaList {
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM LogFileMeta WHERE status = %d AND eof = %d", FILE_STATE_WILL_UPLOAD, YES];
    return [self executeQueryLogMetaList:sqlString];
}

- (GTLogFileMeta *)findMaxFragment:(GTLogEvent *)logEvent {
    NSString *loggerName = [logEvent getLoggerName];
    int level = [logEvent getLevel];
    NSString *date = [GTDateTimeUtil dateString];
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM LogFileMeta WHERE loggerName = '%@' AND level = %d AND date = '%@' ORDER BY date DESC LIMIT 1", loggerName, level, date];
    NSArray *list = [self executeQueryLogMetaList:sqlString];
    return list.count > 0 ? list[0] : nil;
}

- (NSArray *__nonnull)findLogFileMetaListByLevel:(NSArray *__nonnull)levels {
    if (levels.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSNumber *level in levels) {
            [array addObject:[NSString stringWithFormat:@"level = %d", [level intValue]]];
        }
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM LogFileMeta WHERE %@", [array componentsJoinedByString:@" OR "]];
        return [self executeQueryLogMetaList:sqlString];
    }
    return [NSArray array];
}

- (NSArray *)findLogFileMetaListByTime:(int64_t)startTime endTime:(int64_t)endTime {
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM LogFileMeta WHERE createTime >= %lld AND createTime <= %lld", startTime, endTime];
    return [self executeQueryLogMetaList:sqlString];
}

- (NSArray *)findLogFileMetaListByLevelAndTime:(NSArray *__nonnull)levels
                                     startTime:(int64_t)startTime
                                       endTime:(int64_t)endTime {
    if (levels.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSNumber *level in levels) {
            [array addObject:[NSString stringWithFormat:@"level = %d", [level intValue]]];
        }
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM LogFileMeta WHERE (%@) AND createTime >= %lld AND createTime <= %lld", [array componentsJoinedByString:@" OR "], startTime, endTime];
        return [self executeQueryLogMetaList:sqlString];
    }
    return [NSArray array];
}

- (NSArray *)findAllNotUploadCrashReportMeta {
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM CrashReportFileMeta WHERE status = %d", FILE_STATE_NORMAL];
    return [self executeQueryCrashMetaList:sqlString];
}

- (NSString *)layoutJsonArray {
    NSString *sqlString = @"SELECT * FROM MsgLayout";
    NSArray *list = [self executeQueryLayoutList:sqlString];
    NSMutableArray *array = [NSMutableArray array];
    for (GTMsgLayout *instance in list) {
        NSDictionary *item = @{ @"id" : @(instance.id),
                                @"layout" : instance.layout };
        [array addObject:item];
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array
                                                   options:0
                                                     error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return @"[]";
}

- (NSArray *)findAllNotUploadAttachmentMeta {
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM AttachmentFileMeta WHERE status = %d", FILE_STATE_NORMAL];
    return [self executeQueryAttachmentMetaList:sqlString];
}

- (BOOL)deleteElement:(NSObject *__nonnull)element {
    NSString *temp = @"DELETE FROM %@ WHERE id = %lld";
    NSString *sqlString;
    if ([element isKindOfClass:[GTLogFileMeta class]]) {
        GTLogFileMeta *meta = (GTLogFileMeta *) element;
        if (meta.id != -1) {
            sqlString = [NSString stringWithFormat:temp, @"LogFileMeta", meta.id];
        }
    }

    if ([element isKindOfClass:[GTCrashReportFileMeta class]]) {
        GTCrashReportFileMeta *meta = (GTCrashReportFileMeta *) element;
        if (meta.id != -1) {
            sqlString = [NSString stringWithFormat:temp, @"CrashReportFileMeta", meta.id];
        }
    }

    if ([element isKindOfClass:[GTMsgLayout class]]) {
        GTMsgLayout *layout = (GTMsgLayout *) element;
        if (layout.id != -1) {
            sqlString = [NSString stringWithFormat:temp, @"MsgLayout", layout.id];
        }
    }

    return [self executeUpdate:sqlString];
}

/**
 *  Query log file meta list.
 *
 *  @param sqlString SQL string
 *
 *  @return Log file meta list
 */
- (NSArray *)executeQueryLogMetaList:(NSString *)sqlString {
    const char *sql = [sqlString UTF8String];
    __block NSMutableArray *result = [NSMutableArray array];
    dispatch_sync(operationQueue, ^{
        sqlite3_stmt *statement = 0x00;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            int cols = sqlite3_column_count(statement);
            while (true) {
                int status = sqlite3_step(statement);
                if (status == SQLITE_ROW) {
                    int col;
                    GTLogFileMeta *meta = [[GTLogFileMeta alloc] init];
                    for (col = 0; col < cols; col++) {
                        const char *col_name = sqlite3_column_name(statement, col);
                        if (strcmp(col_name, "id") == 0) {
                            meta.id = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "loggerName") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.loggerName = [NSString stringWithUTF8String:val];
                        }
                        if (strcmp(col_name, "filename") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.filename = [NSString stringWithUTF8String:val];
                        }
                        if (strcmp(col_name, "fragment") == 0) {
                            meta.fragment = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "status") == 0) {
                            meta.status = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "fileMD5") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.fileMD5 = [NSString stringWithUTF8String:val];
                        }
                        if (strcmp(col_name, "level") == 0) {
                            meta.level = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "createTime") == 0) {
                            meta.createTime = sqlite3_column_int64(statement, col);
                        }
                        if (strcmp(col_name, "deleteTime") == 0) {
                            meta.deleteTime = sqlite3_column_int64(statement, col);
                        }
                        if (strcmp(col_name, "date") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.date = [NSString stringWithUTF8String:val];
                        }
                        if (strcmp(col_name, "eof") == 0) {
                            meta.eof = sqlite3_column_int(statement, col);
                        }
                    }
                    [result addObject:meta];
                } else {
                    break;
                }
            }
        }
    });
    return [NSArray arrayWithArray:result];
}

/**
 *  Query crash report file meta list.
 *
 *  @param sqlString SQL string
 *
 *  @return Crash report file meta list
 */
- (NSArray *)executeQueryCrashMetaList:(NSString *)sqlString {
    const char *sql = [sqlString UTF8String];
    __block NSMutableArray *result = [NSMutableArray array];
    dispatch_sync(operationQueue, ^{
        sqlite3_stmt *statement = 0x00;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            int cols = sqlite3_column_count(statement);
            while (true) {
                int status = sqlite3_step(statement);
                if (status == SQLITE_ROW) {
                    int col;
                    GTCrashReportFileMeta *meta = [[GTCrashReportFileMeta alloc] init];
                    for (col = 0; col < cols; col++) {
                        const char *col_name = sqlite3_column_name(statement, col);
                        if (strcmp(col_name, "id") == 0) {
                            meta.id = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "filename") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.filename = [NSString stringWithUTF8String:val];
                        }
                        if (strcmp(col_name, "createTime") == 0) {
                            meta.createTime = sqlite3_column_int64(statement, col);
                        }
                        if (strcmp(col_name, "deleteTime") == 0) {
                            meta.deleteTime = sqlite3_column_int64(statement, col);
                        }
                        if (strcmp(col_name, "status") == 0) {
                            meta.status = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "fileMD5") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.fileMD5 = [NSString stringWithUTF8String:val];
                        }
                    }
                    [result addObject:meta];
                } else {
                    break;
                }
            }
        }
    });
    return [NSArray arrayWithArray:result];
}

/**
 *  Query message layout list.
 *
 *  @param sqlString SQL string
 *
 *  @return Message layout list
 */
- (NSArray *)executeQueryLayoutList:(NSString *)sqlString {
    const char *sql = [sqlString UTF8String];
    __block NSMutableArray *result = [NSMutableArray array];
    dispatch_sync(operationQueue, ^{
        sqlite3_stmt *statement = 0x00;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            int cols = sqlite3_column_count(statement);
            while (true) {
                int status = sqlite3_step(statement);
                if (status == SQLITE_ROW) {
                    int col;
                    GTMsgLayout *layout = [[GTMsgLayout alloc] init];
                    for (col = 0; col < cols; col++) {
                        const char *col_name = sqlite3_column_name(statement, col);
                        if (strcmp(col_name, "id") == 0) {
                            layout.id = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "layout") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            layout.layout = [NSString stringWithUTF8String:val];
                        }
                    }
                    [result addObject:layout];
                } else {
                    break;
                }
            }
        }
    });
    return [NSArray arrayWithArray:result];
}

/**
 *  Query attachment file meta list.
 *
 *  @param sqlString Sql string
 *
 *  @return Attachment file meta list
 */
- (NSArray *)executeQueryAttachmentMetaList:(NSString *)sqlString {
    const char *sql = [sqlString UTF8String];
    __block NSMutableArray *result = [NSMutableArray array];
    dispatch_sync(operationQueue, ^{
        sqlite3_stmt *statement = 0x00;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            int cols = sqlite3_column_count(statement);
            while (true) {
                int status = sqlite3_step(statement);
                if (status == SQLITE_ROW) {
                    int col;
                    GTAttachmentFileMeta *meta = [[GTAttachmentFileMeta alloc] init];
                    for (col = 0; col < cols; col++) {
                        const char *col_name = sqlite3_column_name(statement, col);
                        if (strcmp(col_name, "id") == 0) {
                            meta.id = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "filename") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.filename = [NSString stringWithUTF8String:val];
                        }
                        if (strcmp(col_name, "sequence") == 0) {
                            meta.sequence = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "createTime") == 0) {
                            meta.createTime = sqlite3_column_int64(statement, col);
                        }
                        if (strcmp(col_name, "deleteTime") == 0) {
                            meta.deleteTime = sqlite3_column_int64(statement, col);
                        }
                        if (strcmp(col_name, "status") == 0) {
                            meta.status = sqlite3_column_int(statement, col);
                        }
                        if (strcmp(col_name, "fileMD5") == 0) {
                            const char *val = (const char *) sqlite3_column_text(statement, col);
                            meta.fileMD5 = [NSString stringWithUTF8String:val];
                        }
                    }
                    [result addObject:meta];
                } else {
                    break;
                }
            }
        }
    });
    return [NSArray arrayWithArray:result];
}

- (BOOL)executeUpdate:(NSString *)sqlString {
    const char *sql = [sqlString UTF8String];
    __block BOOL result = NO;
    dispatch_sync(operationQueue, ^{
        sqlite3_stmt *statement = 0x00;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                result = YES;
            }
            sqlite3_reset(statement);
        } else {
            sqlite3_finalize(statement);
        }
    });
    return result;
}

- (BOOL)closeDatabase {
    if (db == nil) {
        return YES;
    }

    //TODO
    sqlite3_close(db);

    return YES;
}

- (void)dealloc {
    [self closeDatabase];
}

@end
