//
//  PJLampStatus.h
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/16/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJLampStatus : NSObject

@property(nonatomic,assign,getter=isOn) BOOL       on;
@property(nonatomic,assign)             NSUInteger cumulativeLightingHours;

+ (PJLampStatus*)lampStatusWithState:(BOOL)lampOn hours:(NSUInteger)hours;

@end
