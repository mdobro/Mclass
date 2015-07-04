//
//  PJLampStatus.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/16/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJLampStatus.h"

@implementation PJLampStatus

+ (PJLampStatus*)lampStatus {
    return [[PJLampStatus alloc] init];
}

+ (PJLampStatus*)lampStatusWithState:(BOOL)lampOn hours:(NSUInteger)hours {
    PJLampStatus* ret = [[PJLampStatus alloc] init];
    ret.on = lampOn;
    ret.cumulativeLightingHours = hours;
    return ret;
}

@end
