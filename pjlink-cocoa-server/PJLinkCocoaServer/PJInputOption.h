//
//  PJInputOption.h
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/21/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJInputOption : NSObject

@property(nonatomic,readonly)      NSUInteger inputType;
@property(nonatomic,readonly)      NSUInteger inputNumber;
@property(nonatomic,readonly,copy) NSString*  name;

+ (PJInputOption*)inputOptionWithType:(NSUInteger)type number:(NSUInteger)number name:(NSString*)name;

@end
