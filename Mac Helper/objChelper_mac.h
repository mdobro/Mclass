#ifndef Mclass_Ohelper_h
#define Mclass_Ohelper_h

#import <Foundation/Foundation.h>
#import "PTChannel.h"
@class ViewController;

static const NSTimeInterval PTAppReconnectDelay = 1.0;


@interface Ohelper : NSObject <PTChannelDelegate> {}

- (void)startInit:(ViewController*)view;
- (IBAction)sendMessage:(id)sender;
- (void)presentMessage:(NSString*)message isStatus:(BOOL)isStatus;
- (void)startListeningForDevices;
- (void)didDisconnectFromDevice:(NSNumber*)deviceID;
- (void)disconnectFromCurrentChannel;
- (void)enqueueConnectToLocalIPv4Port;
- (void)connectToLocalIPv4Port;
- (void)connectToUSBDevice;
- (void)ping;

//PTChannelDelegate
- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize;
- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload;
- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error;


@end

#endif
