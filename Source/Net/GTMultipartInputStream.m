// PKMultipartInputStream.h
//
// Copyright (c) 2010 Pierre-Yves Kerembellec <py.kerembellec@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GTMultipartInputStream.h"
#import <UIKit/UIKit.h>
#define kHeaderStringFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define kHeaderDataFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\nContent-Type: %@\r\n\r\n"
#define kHeaderPathFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n"
#define kFooterFormat @"--%@--\r\n"

static NSString *MIMETypeForExtension(NSString *extension) {
    if ([extension isEqualToString:@"jpg"]) {
        return @"image/jpeg";
    } else if ([extension isEqualToString:@"txt"]) {
        return @"text/plain";
    } else if ([extension isEqualToString:@"png"]) {
        return @"image/png";
    } else {
        return @"application/octet-stream";
    }
}

@interface GTMultipartElement : NSObject
@property (nonatomic, strong) NSData *headers;
@property (nonatomic, strong) NSInputStream *body;
@property (nonatomic) NSUInteger headersLength, bodyLength, length, delivered;
@end

@implementation GTMultipartElement
- (void)updateLength {
    self.length = self.headersLength + self.bodyLength + 2;
    [self.body open];
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary string:(NSString *)string {
    self = [super init];
    self.headers = [[NSString stringWithFormat:kHeaderStringFormat, boundary, name] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    self.body = [NSInputStream inputStreamWithData:stringData];
    self.bodyLength = stringData.length;
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data contentType:(NSString *)contentType {
    self = [super init];
    self.headers = [[NSString stringWithFormat:kHeaderDataFormat, boundary, name, contentType] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body = [NSInputStream inputStreamWithData:data];
    self.bodyLength = [data length];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data contentType:(NSString *)contentType filename:(NSString *)filename {
    self = [super init];
    self.headers = [[NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, contentType] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body = [NSInputStream inputStreamWithData:data];
    self.bodyLength = [data length];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary path:(NSString *)path {
    if (!filename) {
        filename = path.lastPathComponent;
    }
    self.headers = [[NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, MIMETypeForExtension(path.pathExtension)] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body = [NSInputStream inputStreamWithFileAtPath:path];
    self.bodyLength = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] unsignedIntegerValue];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary stream:(NSInputStream *)stream streamLength:(NSUInteger)streamLength {
    self.headers = [[NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, MIMETypeForExtension(filename.pathExtension)] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body = stream;
    self.bodyLength = streamLength;
    [self updateLength];
    return self;
}
- (NSUInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
    NSUInteger sent = 0, read;

    if (self.delivered >= self.length) {
        return 0;
    }
    if (self.delivered < self.headersLength && sent < len) {
        read = MIN(self.headersLength - self.delivered, len - sent);
        [self.headers getBytes:buffer + sent range:NSMakeRange(self.delivered, read)];
        sent += read;
        self.delivered += sent;
    }
    while (self.delivered >= self.headersLength && self.delivered < (self.length - 2) && sent < len) {
        if ((read = [self.body read:buffer + sent maxLength:len - sent]) == 0) {
            break;
        }
        sent += read;
        self.delivered += read;
    }
    if (self.delivered >= (self.length - 2) && sent < len) {
        if (self.delivered == (self.length - 2)) {
            *(buffer + sent) = '\r';
            sent++;
            self.delivered++;
        }
        *(buffer + sent) = '\n';
        sent++;
        self.delivered++;
    }
    return sent;
}
@end

@interface GTMultipartInputStream ()
@property (nonatomic, strong) NSMutableArray *parts;
@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, strong) NSData *footer;
@property (nonatomic) NSUInteger currentPart, delivered, length;
@property (nonatomic) NSStreamStatus status;
@end

@implementation GTMultipartInputStream
- (void)updateLength {
    self.length = self.footer.length + [[self.parts valueForKeyPath:@"@sum.length"] unsignedIntegerValue];
}
- (id)init {
    self = [super init];
    if (self) {
        self.parts = [NSMutableArray array];
        self.boundary = [[NSProcessInfo processInfo] globallyUniqueString];
        self.footer = [[NSString stringWithFormat:kFooterFormat, self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
        [self updateLength];
    }
    return self;
}
- (void)addPartWithName:(NSString *)name string:(NSString *)string {
    [self.parts addObject:[[GTMultipartElement alloc] initWithName:name boundary:self.boundary string:string]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name data:(NSData *)data {
    [self.parts addObject:[[GTMultipartElement alloc] initWithName:name boundary:self.boundary data:data contentType:@"application/octet-stream"]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name data:(NSData *)data contentType:(NSString *)type {
    [self.parts addObject:[[GTMultipartElement alloc] initWithName:name boundary:self.boundary data:data contentType:type]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename data:(NSData *)data contentType:(NSString *)type {
    [self.parts addObject:[[GTMultipartElement alloc] initWithName:name boundary:self.boundary data:data contentType:type filename:filename]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name path:(NSString *)path {
    [self.parts addObject:[[GTMultipartElement alloc] initWithName:name filename:nil boundary:self.boundary path:path]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename path:(NSString *)path {
    [self.parts addObject:[[GTMultipartElement alloc] initWithName:name filename:filename boundary:self.boundary path:path]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename stream:(NSInputStream *)stream streamLength:(NSUInteger)streamLength {
    [self.parts addObject:[[GTMultipartElement alloc] initWithName:name filename:filename boundary:self.boundary stream:stream streamLength:streamLength]];
    [self updateLength];
}
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
    NSUInteger sent = 0, read;

    self.status = NSStreamStatusReading;
    while (self.delivered < self.length && sent < len && self.currentPart < self.parts.count) {
        if ((read = [[self.parts objectAtIndex:self.currentPart] read:(buffer + sent) maxLength:(len - sent)]) == 0) {
            self.currentPart++;
            continue;
        }
        sent += read;
        self.delivered += read;
    }
    if (self.delivered >= (self.length - self.footer.length) && sent < len) {
        read = MIN(self.footer.length - (self.delivered - (self.length - self.footer.length)), len - sent);
        [self.footer getBytes:buffer + sent range:NSMakeRange(self.delivered - (self.length - self.footer.length), read)];
        sent += read;
        self.delivered += read;
    }
    return sent;
}
- (BOOL)hasBytesAvailable {
    return self.delivered < self.length;
}
- (void)open {
    self.status = NSStreamStatusOpen;
}
- (void)close {
    self.status = NSStreamStatusClosed;
}
- (NSStreamStatus)streamStatus {
    if (self.status != NSStreamStatusClosed && self.delivered >= self.length) {
        self.status = NSStreamStatusAtEnd;
    }
    return self.status;
}
- (void)_scheduleInCFRunLoop:(NSRunLoop *)runLoop forMode:(id)mode {
}
- (void)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext)context {
}
- (void)removeFromRunLoop:(__unused NSRunLoop *)aRunLoop forMode:(__unused NSString *)mode {
}
@end
