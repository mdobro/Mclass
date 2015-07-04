//
//  PJAMXBeaconSource.h
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 7/15/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJAMXBeaconSource : NSObject

@property(nonatomic,assign)                   NSTimeInterval beaconPulseTimeInterval;
@property(nonatomic,readonly,getter=isActive) BOOL           active;
@property(nonatomic,copy)                     NSString*      uuid;
@property(nonatomic,copy)                     NSString*      sdkClass;
@property(nonatomic,copy)                     NSString*      make;
@property(nonatomic,copy)                     NSString*      model;
@property(nonatomic,copy)                     NSString*      revision;
@property(nonatomic,copy)                     NSString*      configName;
@property(nonatomic,copy)                     NSString*      configURL;

+ (PJAMXBeaconSource*)sharedSource;

// Start the beacon
-(BOOL) start:(NSError**) pError;

// Stop sending the beacon pulses
-(void) stop;

@end
