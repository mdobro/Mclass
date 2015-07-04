//
//  PJAMXBeaconSource.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 7/15/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJAMXBeaconSource.h"
#import "GCDAsyncUdpSocket.h"

uint16_t       const kAMXBeaconPort                     = 9131;
NSString*      const kAMXMulticastGroup                 = @"239.255.250.250";
NSString*      const kAMXPing                           = @"AMX\r";
NSTimeInterval const kAMXDefaultBeaconPulseTimeInterval = 30.0;
NSInteger      const kAMXBeaconDataWriteTag             = 10;
NSString*      const kAMXDefaultSDKClass                = @"Utility";
NSString*      const kAMXDefaultMake                    = @"Apple";
NSString*      const kAMXDefaultModel                   = @"MacBook Pro";
NSString*      const kAMXDefaultRevision                = @"1.0.0";
NSString*      const kAMXDefaultConfigName              = @"";
NSString*      const kAMXDefaultConfigURL               = @"";

@interface PJAMXBeaconSource() <GCDAsyncUdpSocketDelegate>
{
    dispatch_queue_t   _queue;
	GCDAsyncUdpSocket* _socket;
    BOOL               _active;
    NSTimer*           _timer;
}

@end


@implementation PJAMXBeaconSource

+ (PJAMXBeaconSource*)sharedSource {
    static PJAMXBeaconSource* g_sharedAMXBeaconSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_sharedAMXBeaconSource = [[PJAMXBeaconSource alloc] init];
    });

    return g_sharedAMXBeaconSource;
}

- (void)dealloc {
    [self stopPulseTimer];
}

-(id) init
{
    self = [super init];
    if (self)
    {
        // Set the default interval between beacon pulses
        _beaconPulseTimeInterval = kAMXDefaultBeaconPulseTimeInterval;
        // Create a serial dispatch queue to do fetches on
        _queue = dispatch_queue_create([@"PJAMXBeaconSourceQueue" UTF8String], DISPATCH_QUEUE_SERIAL);
        // Create the UDP socket to listen on
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_queue];
        // Create some placeholder parameters
        _uuid       = [[NSUUID UUID] UUIDString];
        _sdkClass   = kAMXDefaultSDKClass;
        _make       = kAMXDefaultMake;
        _model      = kAMXDefaultModel;
        _revision   = kAMXDefaultRevision;
        _configName = kAMXDefaultConfigName;
        _configURL  = kAMXDefaultConfigURL;
    }

    return self;
}

- (void)setBeaconPulseTimeInterval:(NSTimeInterval)beaconPulseTimeInterval {
    if (_beaconPulseTimeInterval != beaconPulseTimeInterval) {
        _beaconPulseTimeInterval = beaconPulseTimeInterval;
        // We need to stop and restart the timer.
        // If we don't have a scheduled timer, then
        // these methods are no-ops.
        [self stopPulseTimer];
        [self startPulseTimer];
    }
}

-(BOOL) isActive
{
	__block BOOL ret;

	dispatch_sync(_queue, ^{
		ret = _active;
	});

	return ret;
}

-(BOOL) start:(NSError**) pError
{
    __block BOOL     ret = NO;
    __block NSError* err = nil;

    // Start the pulse timer.
    [self startPulseTimer];

    // Start listening to the multicast group for explicit
    // signals to respond as well.
    dispatch_sync(_queue, ^{
        @autoreleasepool
        {
            if (!_active)
            {
                // Bind the UDP socket to the port
                NSError* error = nil;
                if ([_socket bindToPort:kAMXBeaconPort error:&error])
                {
                    // Join the multicast group
                    if ([_socket joinMulticastGroup:kAMXMulticastGroup error:&error])
                    {
                        // Begin receiving datagrams on this port
                        if ([_socket beginReceiving:&error])
                        {
                            NSLog(@"AMX Beacon source set up successfully, socket = %@", _socket);
                            // Set the flag saying we are now listening
                            _active = YES;
                        }
                        else
                        {
                            NSLog(@"Could not begin receiving on UDP socket, error = %@", error);
                            [_socket close];
                        }
                    }
                    else
                    {
                        NSLog(@"Could not join multicast group, error = %@", error);
                        [_socket close];
                    }
                }
                else
                {
                    NSLog(@"Could not bind UDP socket to port, error = %@", error);
                }
                // Save the error (if there was one)
                err = error;
            }
            // Set the return value to the same as _active
            ret = _active;
        }
    });

    if (pError)
    {
        *pError = err;
    }

    return ret;
}

-(void) stop
{
    // Stop the pulse timer
    [self stopPulseTimer];
    // Stop listening to the multicast group
    dispatch_sync(_queue, ^{
        @autoreleasepool
        {
            if (_active)
            {
                // Leave the multicast group
                NSError* error = nil;
                BOOL bLeaveRet = [_socket leaveMulticastGroup:kAMXMulticastGroup error:&error];
                if (!bLeaveRet)
                {
                    NSLog(@"Could not leave multicast group, error = %@", error);
                }
                // We just need to close the UDP socket
                [_socket close];
                // Clear the flag which says we are listening
                _active = NO;
                NSLog(@"AMX Beacon source stopped.");
            }
        }
    });
}

#pragma mark -
#pragma mark GCDAsyncUdpSocketDelegate methods

-(void) udpSocket:(GCDAsyncUdpSocket*) sock didConnectToAddress:(NSData*) address
{
    NSLog(@"udpSocket:%@ didConnectToAddress:%@", sock, address);
}

-(void) udpSocket:(GCDAsyncUdpSocket*) sock didNotConnect:(NSError*) error
{
    NSLog(@"udpSocket:%@ didNotConnect:%@", sock, error);
}

-(void) udpSocket:(GCDAsyncUdpSocket*) sock didSendDataWithTag:(long) tag
{
    NSLog(@"udpSocket:%@ didSendDataWithTag:%ld", sock, tag);
}

-(void) udpSocket:(GCDAsyncUdpSocket*) sock didNotSendDataWithTag:(long) tag dueToError:(NSError*) error
{
    NSLog(@"udpSocket:%@ didNotSendDataWithTag:%ld dueToError:%@", sock, tag, error);
}

-(void)   udpSocket:(GCDAsyncUdpSocket*) sock
     didReceiveData:(NSData*) data
        fromAddress:(NSData*) address
  withFilterContext:(id) filterContext
{
    // Convert the data to a string
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // Convert the binary address into human readable
    NSString* host = @"";
    uint16_t  port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    NSString* addressReadable = [NSString stringWithFormat:@"%@:%u", host, port];
    NSLog(@"udpSocket:%@ didReceiveData:\"%@\" fromAddress:\"%@\" withFilterContext:%@", sock, dataStr, addressReadable, filterContext);
    // Check if this is a beacon request ("AMX\r"). It could be another device sending
    // a pulse. If so, then we don't want to respond.
    if ([dataStr isEqualToString:kAMXPing]) {
        NSLog(@"PJAMXBeaconSource: Received AMX ping.");
        // We were pinged, so we should respond with our beacon text
        [self sendAMXBeaconPulse];
    }
}

-(void) udpSocketDidClose:(GCDAsyncUdpSocket*) sock withError:(NSError*) error
{
    NSLog(@"udpSocketDidClose:%@ withError:%@", sock, error);
}

- (NSString*)amxBeaconText {
    NSMutableString* tmp = [NSMutableString stringWithString:@"AMXB"];

    // Send each of the parameters for which
    // we have a valid string.
    if ([_uuid length] > 0) {
        [tmp appendFormat:@"<-UUID=%@>", _uuid];
    }
    if ([_sdkClass length] > 0) {
        [tmp appendFormat:@"<-SDKClass=%@>", _sdkClass];
    }
    if ([_make length] > 0) {
        [tmp appendFormat:@"<-Make=%@>", _make];
    }
    if ([_model length] > 0) {
        [tmp appendFormat:@"<-Model=%@>", _model];
    }
    if ([_revision length] > 0) {
        [tmp appendFormat:@"<-Revision=%@>", _revision];
    }
    if ([_configName length] > 0) {
        [tmp appendFormat:@"<Config-Name=%@>", _configName];
    }
    if ([_configURL length] > 0) {
        [tmp appendFormat:@"<Config-URL=%@>", _configURL];
    }
    // Append the carriage return
    [tmp appendString:@"\r"];

    return [NSString stringWithString:tmp];
}

- (void)sendAMXBeaconPulse {
    // Send the beacon data
    dispatch_async(_queue, ^{
        // Get the AMX beacon text
        NSString* beaconText = [self amxBeaconText];
        NSLog(@"PJAMXBeaconSource: Sending AMX Beacon with text \"%@\"", beaconText);
        // Convert to data
        NSData* beaconData = [beaconText dataUsingEncoding:NSUTF8StringEncoding];
        // Send the beacon data to whoever is listening on the multicast address
        [_socket sendData:beaconData
                   toHost:kAMXMulticastGroup
                     port:kAMXBeaconPort
              withTimeout:-1
                      tag:kAMXBeaconDataWriteTag];
    });
}

- (void)startPulseTimer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_beaconPulseTimeInterval
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)stopPulseTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerFired:(NSTimer*)timer {
    NSLog(@"PJAMXBeaconSource: Scheduled timer fired");
    [self sendAMXBeaconPulse];
}

@end
