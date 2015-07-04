//
//  PJInputOption.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/21/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJInputOption.h"

@interface PJInputOption()

@property(nonatomic,readwrite)      NSUInteger inputType;
@property(nonatomic,readwrite)      NSUInteger inputNumber;
@property(nonatomic,readwrite,copy) NSString*  name;

@end

@implementation PJInputOption

+ (PJInputOption*)inputOptionWithType:(NSUInteger)type number:(NSUInteger)number name:(NSString *)name {
    PJInputOption* inputOption = [[PJInputOption alloc] init];
    inputOption.inputType = type;
    inputOption.inputNumber = number;
    inputOption.name = name;

    return inputOption;
}

- (NSString*)description {
    return self.name;
}

@end
