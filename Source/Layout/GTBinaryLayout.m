//
//  BinaryLayout.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/8.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTBinaryLayout.h"
#import "GTLogEvent.h"
#import "GTCryptoTool.h"

@implementation GTBinaryLayout

- (NSData *)data:(GTLogEvent *)logEvent {
    NSString *tag = [GTCryptoTool encrypt:[logEvent getTag]];
    NSString *msg = [GTCryptoTool encrypt:[logEvent getMessage]];

    NSMutableData *data = [NSMutableData dataWithCapacity:0];

    // Time chunk
    int64_t timeChunk = CFSwapInt64HostToBig([logEvent getTimeMillis]);
    int16_t timeChunkLen = CFSwapInt16HostToBig(8);
    [data appendBytes:&timeChunkLen length:sizeof(timeChunkLen)];
    [data appendBytes:&timeChunk length:sizeof(timeChunk)];

    // Tag chunk
    NSData *tagChunk = [tag dataUsingEncoding:NSUTF8StringEncoding];
    int16_t tagChunkLen = [tagChunk length];
    int16_t tagChunkLenBig = CFSwapInt16HostToBig(tagChunkLen);
    [data appendBytes:&tagChunkLenBig length:sizeof(tagChunkLenBig)];
    [data appendData:tagChunk];

    // Message chunk
    NSData *msgChunk = [msg dataUsingEncoding:NSUTF8StringEncoding];
    int16_t msgChunkLen = [msgChunk length];
    int16_t msgChunkLenBig = CFSwapInt16HostToBig(msgChunkLen);
    [data appendBytes:&msgChunkLenBig length:sizeof(msgChunkLenBig)];
    [data appendData:msgChunk];

    // Layout id chunk
    int16_t layoutIdChunkLen = CFSwapInt16HostToBig(2);
    int16_t layoutIdChunk = CFSwapInt16HostToBig([logEvent getLayoutId]);
    [data appendBytes:&layoutIdChunkLen length:sizeof(layoutIdChunkLen)];
    [data appendBytes:&layoutIdChunk length:sizeof(layoutIdChunk)];

    // Attachment id chunk
    int32_t attachmentId = [logEvent getAttachmentId];
    if (attachmentId != -1) {
        int32_t attachmentIdChunk = CFSwapInt32HostToBig(attachmentId);
        int16_t attachmentIdLenChunk = CFSwapInt16HostToBig(4);
        [data appendBytes:&attachmentIdLenChunk length:sizeof(attachmentIdLenChunk)];
        [data appendBytes:&attachmentIdChunk length:sizeof(attachmentIdChunk)];
    }

    // EOF chunk
    int16_t eofChunk = CFSwapInt16HostToBig(-100);
    [data appendBytes:&eofChunk length:sizeof(eofChunk)];

    return [NSData dataWithData:data];
}

@end
