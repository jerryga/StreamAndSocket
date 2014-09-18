StreamAndSocket
===============

Using NSStream to test socket.

The engine is SocketEngine.h/SocketEngine.m.

## How To Get Started

- ```- (id) initWithHostAddress:(NSString *)host andPort:(NSInteger)port;
```

init the socket engine.

    self.engine = [[SocketEngine alloc] initWithHostAddress:@"towel.blinkenlights.nl" andPort:23];
---


- ```- (BOOL)connect;
```

connect network

---

- ```- (BOOL)sendNetworkPacket;
```

send data to server.

---
- ```SetBlock;
```
		- (void)setReadProgressBlock:(void (^)(unsigned int bytesReading, NSUInteger totalBytesReading))block ;
		- (void)setTerminatedBlock:(void (^)(NSError *error))block ;
		- (void)setReceivedNetworkDataBlock:(void (^)(NSData *data))block;

---
