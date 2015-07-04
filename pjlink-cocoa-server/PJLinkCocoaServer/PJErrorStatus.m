//
//  PJErrorStatus.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/20/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJErrorStatus.h"

@interface PJErrorStatus()

@property(nonatomic,readwrite,copy) NSString* name;

@end

@implementation PJErrorStatus

@synthesize name;
@synthesize status;

+ (PJErrorStatus*)errorStatusWithName:(NSString*)name {
    return [PJErrorStatus errorStatusWithName:name initialStatus:PJErrorStatusOK];
}

+ (PJErrorStatus*)errorStatusWithName:(NSString*)name initialStatus:(NSUInteger)initStatus {
    PJErrorStatus* errorStatus = [[PJErrorStatus alloc] init];
    errorStatus.name = name;
    errorStatus.status = PJErrorStatusOK;
    return errorStatus;
}

@end
