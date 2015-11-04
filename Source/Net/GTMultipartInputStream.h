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

#import <Foundation/Foundation.h>

@interface GTMultipartInputStream : NSInputStream
- (void)addPartWithName:(NSString *)name string:(NSString *)string;
- (void)addPartWithName:(NSString *)name data:(NSData *)data;
- (void)addPartWithName:(NSString *)name data:(NSData *)data contentType:(NSString *)type;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename data:(NSData *)data contentType:(NSString *)type;
- (void)addPartWithName:(NSString *)name path:(NSString *)path;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename path:(NSString *)path;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename stream:(NSInputStream *)stream streamLength:(NSUInteger)streamLength;

@property (nonatomic, readonly) NSString *boundary;
@property (nonatomic, readonly) NSUInteger length;

@end
