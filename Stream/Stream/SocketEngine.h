//
//  SocketEngine.h
//  Stream
//
//  Created by Static Ga on 14-9-18.
//  Copyright (c) 2014年 Static Ga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketEngine : NSObject

- (id) initWithHostAddress:(NSString *)host andPort:(NSInteger)port;
- (BOOL)connect;
- (void) sendNetworkPacket:(NSData *)data;

- (void)setReadProgressBlock:(void (^)(unsigned int bytesReading, NSUInteger totalBytesReading))block ;
- (void)setTerminatedBlock:(void (^)(NSError *error))block ;
- (void)setReceivedNetworkDataBlock:(void (^)(NSData *data))block;
@end
