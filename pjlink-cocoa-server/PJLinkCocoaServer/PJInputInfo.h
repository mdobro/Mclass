//
//  PJInputInfo.h
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/20/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJInputInfo : NSObject

@property(nonatomic,readonly,copy) NSString* name;
@property(nonatomic,assign)        NSUInteger numberOfInputs;

+ (PJInputInfo*)inputInfoWithName:(NSString*)name numberOfInputs:(NSUInteger)numInputs;

@end
