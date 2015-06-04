//
//  objChelper.h
//  Mclass
//
//  Created by Mike Dobrowolski on 6/4/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

#ifndef Mclass_objChelper_h
#define Mclass_objChelper_h

#include "PTChannel.h"

@interface objChelper : NSObject {}

// Invoked when a new frame has arrived on a channel.
- (NSString*)helpioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload peerChannel:(PTChannel*)peerChannel_;

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)helpioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize peerChannel:(PTChannel*)peerChannel_;

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)helpioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error;

 /*
// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)helpioFrameChannel:(PTChannel*)channel didAcceptConnection:(PTChannel*)otherChannel fromAddress:(PTAddress*)address;
 */

@end

#endif
