#import "PTUSBHub.h"
#import "Protocol.h"
#import "PTChannel.h"
#import "objChelper_mac.h"
#import "Mac_Helper-Swift.h"

@interface Ohelper() {
    // If the remote connection is over USB transport...
    NSNumber *connectingToDeviceID_;
    NSNumber *connectedDeviceID_;
    NSDictionary *connectedDeviceProperties_;
    NSDictionary *remoteDeviceInfo_;
    dispatch_queue_t notConnectedQueue_;
    BOOL notConnectedQueueSuspended_;
    PTChannel *connectedChannel_;
    NSMutableDictionary *pings_;
}

@property (readonly) NSNumber *connectedDeviceID;
@property PTChannel *connectedChannel;
@property ViewController* MainView;

@end


@implementation Ohelper

- (void)startInit:(ViewController*)view {
    // We use a serial queue that we toggle depending on if we are connected or
    // not. When we are not connected to a peer, the queue is running to handle
    // "connect" tries. When we are connected to a peer, the queue is suspended
    // thus no longer trying to connect.
    notConnectedQueue_ = dispatch_queue_create("PTExample.notConnectedQueue", DISPATCH_QUEUE_SERIAL);
    [self startListeningForDevices];
    [self enqueueConnectToLocalIPv4Port];
    [self ping];
    _MainView = view;
}

@synthesize connectedDeviceID = connectedDeviceID_;
- (IBAction)sendMessage:(id)sender {
    /*
    if (connectedChannel_) {
        dispatch_data_t payload = DispatchDataWithString(message);
        [connectedChannel_ sendFrameOfType:PTExampleFrameTypeTextMessage tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
            if (error) {
                NSLog(@"Failed to send message: %@", error);
            }
        }];
        [self presentMessage:[NSString stringWithFormat:@"[you]: %@", message] isStatus:NO];
     }
     */
}


- (void)presentMessage:(NSString*)message isStatus:(BOOL)isStatus {
    NSLog(@">> %@", message);
}


- (PTChannel*)connectedChannel {
    return connectedChannel_;
}

- (void)setConnectedChannel:(PTChannel*)connectedChannel {
    connectedChannel_ = connectedChannel;
    
    // Toggle the notConnectedQueue_ depending on if we are connected or not
    if (!connectedChannel_ && notConnectedQueueSuspended_) {
        dispatch_resume(notConnectedQueue_);
        notConnectedQueueSuspended_ = NO;
    } else if (connectedChannel_ && !notConnectedQueueSuspended_) {
        dispatch_suspend(notConnectedQueue_);
        notConnectedQueueSuspended_ = YES;
    }
    
    if (!connectedChannel_ && connectingToDeviceID_) {
        [self enqueueConnectToUSBDevice];
    }
}


#pragma mark - Ping


- (void)pongWithTag:(uint32_t)tagno error:(NSError*)error {
    NSNumber *tag = [NSNumber numberWithUnsignedInt:tagno];
    NSMutableDictionary *pingInfo = [pings_ objectForKey:tag];
    if (pingInfo) {
        NSDate *now = [NSDate date];
        [pingInfo setObject:now forKey:@"date ended"];
        [pings_ removeObjectForKey:tag];
        NSLog(@"Ping total roundtrip time: %.3f ms", [now timeIntervalSinceDate:[pingInfo objectForKey:@"date created"]]*1000.0);
    }
}


- (void)ping {
    if (connectedChannel_) {
        if (!pings_) {
            pings_ = [NSMutableDictionary dictionary];
        }
        uint32_t tagno = [connectedChannel_.protocol newTag];
        NSNumber *tag = [NSNumber numberWithUnsignedInt:tagno];
        NSMutableDictionary *pingInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"date created", nil];
        [pings_ setObject:pingInfo forKey:tag];
        [connectedChannel_ sendFrameOfType:Ping tag:tagno withPayload:nil callback:^(NSError *error) {
            [self performSelector:@selector(ping) withObject:nil afterDelay:1.0];
            [pingInfo setObject:[NSDate date] forKey:@"date sent"];
            if (error) {
                [pings_ removeObjectForKey:tag];
            }
        }];
    } else {
        [self performSelector:@selector(ping) withObject:nil afterDelay:1.0];
    }
}


#pragma mark - PTChannelDelegate


- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (   type != DeviceInfo
        && type != Problem
        && type != Ping
        && type != Pong
        && type != Projector1
        && type != Projector2
        && type != HDCP
        && type != ProblemRoom
        && type != PTFrameTypeEndOfStream) {
        NSLog(@"Unexpected frame of type %u", type);
        [channel close];
        return NO;
    } else {
        return YES;
    }
}

- (NSString*)unwrapFrame:(PTData*)payload channel:(PTChannel*)channel {
    TextFrame *textFrame = (TextFrame*)payload.data;
    textFrame->length = ntohl(textFrame->length);
    NSString *message = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];
    [self presentMessage:[NSString stringWithFormat:@"[%@]: %@", channel.userInfo, message] isStatus:NO];
    return message;
    
}

- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload {
    NSLog(@"received %@, %u, %u, %@", channel, type, tag, payload);
    if (type == DeviceInfo) {
        NSDictionary *deviceInfo = [NSDictionary dictionaryWithContentsOfDispatchData:payload.dispatchData];
        [self presentMessage:[NSString stringWithFormat:@"Connected to %@", deviceInfo.description] isStatus:YES];
        [_MainView connected:true];
    } else if (type == Problem) {
        //recieve problem string to display
        [_MainView recievedProblem:[self unwrapFrame:payload channel:channel]];
    } else if (type == Pong) {
        [self pongWithTag:tag error:nil];
    } else if (type == Projector1) {
        [_MainView recievedP1source:[self unwrapFrame:payload channel:channel]];
    } else if (type == Projector2) {
        [_MainView recievedP2source:[self unwrapFrame:payload channel:channel]];
    } else if (type == HDCP) {
        [_MainView recievedHDCPchange:[self unwrapFrame:payload channel:channel]];
    } else if (type == ProblemRoom) {
        [_MainView recievedProblemRoom:[self unwrapFrame:payload channel:channel]];
    }
}

- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
    if (connectedDeviceID_ && [connectedDeviceID_ isEqualToNumber:channel.userInfo]) {
        [self didDisconnectFromDevice:connectedDeviceID_];
    }
    
    if (connectedChannel_ == channel) {
        [self presentMessage:[NSString stringWithFormat:@"Disconnected from %@", channel.userInfo] isStatus:YES];
        self.connectedChannel = nil;
        [_MainView connected:false];
    }
}


#pragma mark - Wired device connections


- (void)startListeningForDevices {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserverForName:PTUSBDeviceDidAttachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        //NSLog(@"PTUSBDeviceDidAttachNotification: %@", note.userInfo);
        NSLog(@"PTUSBDeviceDidAttachNotification: %@", deviceID);
        
        dispatch_async(notConnectedQueue_, ^{
            if (!connectingToDeviceID_ || ![deviceID isEqualToNumber:connectingToDeviceID_]) {
                [self disconnectFromCurrentChannel];
                connectingToDeviceID_ = deviceID;
                connectedDeviceProperties_ = [note.userInfo objectForKey:@"Properties"];
                [self enqueueConnectToUSBDevice];
            }
        });
    }];
    
    [nc addObserverForName:PTUSBDeviceDidDetachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        //NSLog(@"PTUSBDeviceDidDetachNotification: %@", note.userInfo);
        NSLog(@"PTUSBDeviceDidDetachNotification: %@", deviceID);
        
        if ([connectingToDeviceID_ isEqualToNumber:deviceID]) {
            connectedDeviceProperties_ = nil;
            connectingToDeviceID_ = nil;
            if (connectedChannel_) {
                [connectedChannel_ close];
            }
        }
    }];
}


- (void)didDisconnectFromDevice:(NSNumber*)deviceID {
    NSLog(@"Disconnected from device");
    if ([connectedDeviceID_ isEqualToNumber:deviceID]) {
        [self willChangeValueForKey:@"connectedDeviceID"];
        connectedDeviceID_ = nil;
        [self didChangeValueForKey:@"connectedDeviceID"];
    }
}


- (void)disconnectFromCurrentChannel {
    if (connectedDeviceID_ && connectedChannel_) {
        [connectedChannel_ close];
        self.connectedChannel = nil;
    }
}


- (void)enqueueConnectToLocalIPv4Port {
    dispatch_async(notConnectedQueue_, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectToLocalIPv4Port];
        });
    });
}


- (void)connectToLocalIPv4Port {
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    channel.userInfo = [NSString stringWithFormat:@"127.0.0.1:%d", PTProtocolIPv4PortNumber];
    [channel connectToPort:PTProtocolIPv4PortNumber IPv4Address:INADDR_LOOPBACK callback:^(NSError *error, PTAddress *address) {
        if (error) {
            if (error.domain == NSPOSIXErrorDomain && (error.code == ECONNREFUSED || error.code == ETIMEDOUT)) {
                // this is an expected state
            } else {
                NSLog(@"Failed to connect to 127.0.0.1:%d: %@", PTProtocolIPv4PortNumber, error);
            }
        } else {
            [self disconnectFromCurrentChannel];
            self.connectedChannel = channel;
            channel.userInfo = address;
            NSLog(@"Connected to %@", address);
        }
        [self performSelector:@selector(enqueueConnectToLocalIPv4Port) withObject:nil afterDelay:PTAppReconnectDelay];
    }];
}


- (void)enqueueConnectToUSBDevice {
    dispatch_async(notConnectedQueue_, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectToUSBDevice];
        });
    });
}


- (void)connectToUSBDevice {
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    channel.userInfo = connectingToDeviceID_;
    channel.delegate = self;
    
    [channel connectToPort:PTProtocolIPv4PortNumber overUSBHub:PTUSBHub.sharedHub deviceID:connectingToDeviceID_ callback:^(NSError *error) {
        if (error) {
            if (error.domain == PTUSBHubErrorDomain && error.code == PTUSBHubErrorConnectionRefused) {
                NSLog(@"Failed to connect to device #%@: %@", channel.userInfo, error);
            } else {
                NSLog(@"Failed to connect to device #%@: %@", channel.userInfo, error);
            }
            if (channel.userInfo == connectingToDeviceID_) {
                [self performSelector:@selector(enqueueConnectToUSBDevice) withObject:nil afterDelay:PTAppReconnectDelay];
            }
        } else {
            connectedDeviceID_ = connectingToDeviceID_;
            self.connectedChannel = channel;
            //NSLog(@"Connected to device #%@\n%@", connectingToDeviceID_, connectedDeviceProperties_);
            //infoTextField_.stringValue = [NSString stringWithFormat:@"Connected to device #%@\n%@", deviceID, connectedDeviceProperties_];
        }
    }];
}

@end
