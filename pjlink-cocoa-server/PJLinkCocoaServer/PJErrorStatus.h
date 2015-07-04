//
//  PJErrorStatus.h
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/20/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    PJErrorStatusOK,
    PJErrorStatusWarning,
    PJErrorStatusError
};

@interface PJErrorStatus : NSObject

@property(nonatomic,readonly,copy) NSString*  name;
@property(nonatomic,assign)        NSUInteger status;

+ (PJErrorStatus*)errorStatusWithName:(NSString*)name;
+ (PJErrorStatus*)errorStatusWithName:(NSString*)name initialStatus:(NSUInteger)initStatus;

@end
