//
//  objChelper.m
//  Mclass
//
//  Created by Mike Dobrowolski on 6/4/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objChelper.h"
#import "Protocol.h"

@implementation objChelper

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)helpioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize peerChannel:(PTChannel*)peerChannel_ {
    if (channel != peerChannel_) {
        // A previous channel that has been canceled but not yet ended. Ignore.
        return NO;
    } else if (type < 100 || type > 111) {
        NSLog(@"Unexpected frame of type %u", type);
        [channel close];
        return NO;
    } else {
        return YES;
    }
}

// Invoked when a new frame has arrived on a channel.
- (NSString*)helpioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload peerChannel:(PTChannel*)peerChannel_ {
    //NSLog(@"didReceiveFrameOfType: %u, %u, %@", type, tag, payload);
    
    //UNCOMMENT THIS TO ACCEPT FRAMES TO IPAD
    
    if (type == Problem || type == ClassName) {
        TextFrame *textFrame = (TextFrame*)payload.data;
        textFrame->length = ntohl(textFrame->length);
        NSString *message = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];
        //NSLog(@"%@ %@",channel.userInfo,message);
        return message;
     }
    
    if (type == Ping && peerChannel_) {
        [peerChannel_ sendFrameOfType:Pong tag:tag withPayload:nil callback:nil];
    }
    return @"";
}

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)helpioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
    if (error) {
        NSLog(@"%@ ended with error: %@", channel, error);
    } else {
        NSLog(@"Disconnected from %@", channel.userInfo);
    }
}

 /*
// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)helpioFrameChannel:(PTChannel*)channel didAcceptConnection:(PTChannel*)otherChannel fromAddress:(PTAddress*)address peerChannel:(PTChannel*)peerChannel_{
    // Cancel any other connection. We are FIFO, so the last connection
    // established will cancel any previous connection and "take its place".
    if (peerChannel_) {
        [peerChannel_ cancel];
    }
    
    // Weak pointer to current connection. Connection objects live by themselves
    // (owned by its parent dispatch queue) until they are closed.
    peerChannel_ = otherChannel;
    peerChannel_.userInfo = address;
    [self appendOutputMessage:[NSString stringWithFormat:@"Connected to %@", address]];
    
    // Send some information about ourselves to the other end
    [self sendDeviceInfo];
}
 */

@end
