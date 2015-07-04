//
//  PJInputInfo.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/20/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJInputInfo.h"

@interface PJInputInfo()

@property(nonatomic,readwrite,copy) NSString* name;

@end

@implementation PJInputInfo

@synthesize name;
@synthesize numberOfInputs;

+ (PJInputInfo*)inputInfoWithName:(NSString*)name numberOfInputs:(NSUInteger)numInputs {
    PJInputInfo* ret = [[PJInputInfo alloc] init];
    ret.name = name;
    ret.numberOfInputs = numInputs;

    return ret;
}

@end
