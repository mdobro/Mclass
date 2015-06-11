#ifndef Mclass_Ohelper_h
#define Mclass_Ohelper_h

#import <Foundation/Foundation.h>
#import "PTChannel.h"
static const NSTimeInterval PTAppReconnectDelay = 1.0;


@interface Ohelper : NSObject <PTChannelDelegate> {}

- (void)startInit;
- (IBAction)sendMessage:(id)sender;
- (void)presentMessage:(NSString*)message isStatus:(BOOL)isStatus;
- (void)startListeningForDevices;
- (void)didDisconnectFromDevice:(NSNumber*)deviceID;
- (void)disconnectFromCurrentChannel;
- (void)enqueueConnectToLocalIPv4Port;
- (void)connectToLocalIPv4Port;
- (void)connectToUSBDevice;
- (void)ping;

@end

#endif
