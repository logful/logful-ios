//
//  GTCaptureTool.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTCaptureTool.h"
#import "GTLogStorage.h"
#import "GTUniqueSequenceTool.h"
#import "GTAttachmentFileMeta.h"
#import "GTDatabaseManager.h"
#import "GTBaseLogger.h"
#import "GTBaseLogEvent.h"
#import "GTAppenderManager.h"
#import "GTLoggerFactory.h"

@implementation GTCaptureTool

+ (void)captureThenLog:(GTLogger *)logger
                 level:(int)level
                   tag:(NSString *)tag
                   msg:(NSString *)msg {
    GTLoggerConfigurator *config = [GTLoggerFactory config];
    if (!config) {
        return;
    }
    float quality = (float) config.screenshotQuality / 100;
    float scale = config.screenshotScale;
    __weak GTLogger *temp = logger;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [[UIScreen mainScreen] scale]);
        } else {
            UIGraphicsBeginImageContext(window.bounds.size);
        }

        [window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIImage *scaleImage = [self scaleImage:image scale:scale];
        
        NSData *data = UIImageJPEGRepresentation(scaleImage, quality);
        if (data) {
            @autoreleasepool {
                int32_t sequence = [GTUniqueSequenceTool sequence];
                NSString *filename = [NSString stringWithFormat:@"%d.jpg", sequence];
                NSString *filePath = [GTLogStorage attachmentFilePath:filename];
                if ([data writeToFile:filePath atomically:YES]) {
                    GTAttachmentFileMeta *meta = [GTAttachmentFileMeta create:filename sequence:sequence];
                    if ([[GTDatabaseManager manager] saveAttachmentFileMeta:meta]) {
                        GTBaseLogEvent *logEvent = [GTBaseLogEvent createEvent:[temp getName]
                                                                         level:level
                                                                           tag:tag
                                                                       message:msg
                                                                  layoutString:[temp getMsgLayout]
                                                                  attachmentId:sequence];
                        [GTAppenderManager append:logEvent];
                    }
                }
            }
        }
    });
}

+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)scale {
    CGRect scaledImageRect = CGRectZero;

    CGFloat newWidth = image.size.width * scale;
    CGFloat newHeight = image.size.height * scale;
    CGSize newSize = CGSizeMake(newWidth, newHeight);

    scaledImageRect.size.width = newSize.width;
    scaledImageRect.size.height = newSize.height;

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    [image drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return scaledImage;
}

@end
