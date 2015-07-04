#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class PJLinkConfig;

#define PJLinkConnectionDidDieNotification  @"PJLinkConnectionDidDie"

@interface PJLinkConnection : NSObject

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(PJLinkConfig *)aConfig;
- (void)start;
- (void)stop;

@end

