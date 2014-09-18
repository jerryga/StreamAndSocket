//
//  SocketEngine.m
//  Stream
//
//  Created by Static Ga on 14-9-18.
//  Copyright (c) 2014年 Static Ga. All rights reserved.
//

#import "SocketEngine.h"
#import "NSStream+Host.h"

typedef void (^SEReadingProgressBlock)(unsigned int bytesReading, NSUInteger totalBytesReading);
typedef void (^SEConnectionTerminatedBlock)(NSError *error);
typedef void (^SEReceivedNetworkDataBlock)(NSData *data);


@interface SocketEngine ()<NSStreamDelegate>
{
    NSMutableData *_incomingDataBuffer;
    NSMutableData *_outgoingDataBuffer;
}
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) NSInteger port;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (readwrite, nonatomic, copy) SEReadingProgressBlock readingProgress;
@property (readwrite, nonatomic, copy) SEConnectionTerminatedBlock terminated;
@property (readwrite, nonatomic, copy) SEReceivedNetworkDataBlock receivedNetworkData;

@end

@implementation SocketEngine

- (id) initWithHostAddress:(NSString *)host andPort:(NSInteger)port {
    if (self = [super init]) {
        
        [self clean];
        
        self.host = host;
        self.port = port;
    }
    return self;
}

#pragma mark - private

- (void)clean {
    [self closeStream:self.inputStream];
    [self closeStream:self.outputStream];
}

- (void)closeStream:(NSStream *)stream {
    if (stream) {
        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [stream close];
        stream = nil;
    }
}

- (void) setupSocketStreams {
    NSInputStream *tmpInputStream;
    NSOutputStream *tmpOutStream;
    [NSStream getStreamsToHostNamed:self.host port:self.port inputStream:&tmpInputStream outputStream:&tmpOutStream];
    self.inputStream = tmpInputStream;
    self.outputStream = tmpOutStream;
}
#pragma mark - public

- (BOOL)connect {
    if (self.host) {
        [self setupSocketStreams];
        
        self.inputStream.delegate = self;
        self.outputStream.delegate = self;
        
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        [self.inputStream open];
        [self.outputStream open];
        
        return YES;
    }
    return NO;
}

- (void) sendNetworkPacket:(NSData *)data {
    if (!data) {
        return;
    }
    
    if (!_outgoingDataBuffer) {
        _outgoingDataBuffer = [[NSMutableData alloc] init];
    }
    
    [_outgoingDataBuffer appendData:data];
    
    [self writeOutgoingBufferToStream];
}

- (void)setReadProgressBlock:(void (^)(unsigned int bytesReading, NSUInteger totalBytesReading))block {
    self.readingProgress = block;
}

- (void)setTerminatedBlock:(void (^)(NSError *))block {
    self.terminated = block;
}

- (void)setReceivedNetworkDataBlock:(void (^)(NSData *))block {
    self.receivedNetworkData = block;
}
#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable: {
            if (!_incomingDataBuffer) {
                _incomingDataBuffer = [[NSMutableData alloc] init];
            }
            
            uint8_t buf[BUFSIZ];
            unsigned int len = 0;
            len = [self.inputStream read:buf maxLength:BUFSIZ];
            if (len > 0) {
                //Block
                [_incomingDataBuffer appendBytes:buf length:len];
                if (self.readingProgress) {
                    self.readingProgress(len, [_incomingDataBuffer length]);
                }
                
                if (self.receivedNetworkData) {
                    self.receivedNetworkData([NSData dataWithBytes:buf length:len]);
                }
                
            }else {
                //Finished
                if (_incomingDataBuffer) {
                    [_incomingDataBuffer resetBytesInRange:NSMakeRange(0, _incomingDataBuffer.length)];
                    [_incomingDataBuffer setLength:0];
                }
                if (self.terminated) {
                    self.terminated(nil);
                }
            }
        }
            break;
        case NSStreamEventHasSpaceAvailable: {
            [self writeOutgoingBufferToStream];
        }
            break;
		case NSStreamEventErrorOccurred: {
            NSLog(@"err %@",stream.streamError);
			[self closeStream:stream];
            if (self.terminated) {
                self.terminated(stream.streamError);
            }
		}
			break;
		case NSStreamEventEndEncountered: {
            [self closeStream:stream];
            if (self.terminated) {
                self.terminated(nil);
            }
		}
            break;

		default:
			break;
	}
}

#pragma mark - write

- (void) writeOutgoingBufferToStream {
    if (!_outgoingDataBuffer || 0 == [_outgoingDataBuffer length]) {
        return;
    }
    
    if ([self.outputStream hasSpaceAvailable]) {
        uint8_t *readBytes = (uint8_t *)[_outgoingDataBuffer mutableBytes];
        int byteIndex = 0;
        readBytes += byteIndex; // instance variable to move pointer
        int data_len = [_outgoingDataBuffer length];
        unsigned int len = ((data_len - byteIndex >= 1024) ?
                            1024 : (data_len-byteIndex));
        uint8_t buf[len];
        (void)memcpy(buf, readBytes, len);
        len = [self.outputStream write:(const uint8_t *)buf maxLength:len];
        if (len) {
            [_outgoingDataBuffer replaceBytesInRange:NSMakeRange(byteIndex, len) withBytes:NULL length:0];
            byteIndex += len;
        }else {
            [self closeStream:self.outputStream];
            if (self.terminated) {
                self.terminated(nil);
            }
        }
    }
}

@end
