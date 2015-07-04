//
//  PJProjector.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/8/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJProjector.h"
#import "PJLampStatus.h"
#import "PJErrorStatus.h"
#import "PJInputOption.h"
#import <CommonCrypto/CommonDigest.h>

const NSUInteger kWarmUpTime = 30;
const NSUInteger kCoolDownTime = 30;

const NSUInteger kMinInputIndex             = 1;
const NSUInteger kMaxInputIndex             = 9;
const NSUInteger kMinNumberOfLamps          = 1;
const NSUInteger kMaxNumberOfLamps          = 8;
const NSUInteger kMaxProjectorNameLength    = 64;
const NSUInteger kMaxManufacturerNameLength = 32;
const NSUInteger kMaxProductNameLength      = 32;
const NSUInteger kMaxOtherInformationLength = 32;
const NSUInteger kMaxCumulativeLightingTime = 99999;

NSString* const PJProjectorErrorDomain = @"PJProjectorErrorDomain";

@interface PJProjector()
{
    NSTimer* _powerStatusTransitionTimer;
    uint32_t _randomNumber;
}

@property(nonatomic,readwrite,copy) NSArray* inputs; // Array of PJInputOption's

@end

@implementation PJProjector

+ (PJProjector*)sharedProjector {
    static PJProjector* g_sharedProjector = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_sharedProjector = [[PJProjector alloc] init];
    });
    
    return g_sharedProjector;
}

- (id)init {
    self = [super init];
    if (self) {
        _powerStatus = PJPowerStatusStandby;
        _inputs = @[[PJInputOption inputOptionWithType:PJInputTypeRGB     number:1 name:@"RGB 1"],
                    [PJInputOption inputOptionWithType:PJInputTypeRGB     number:2 name:@"RGB 2"],
                    [PJInputOption inputOptionWithType:PJInputTypeRGB     number:3 name:@"RGB 3"],
                    [PJInputOption inputOptionWithType:PJInputTypeVideo   number:1 name:@"Video 1"],
                    [PJInputOption inputOptionWithType:PJInputTypeVideo   number:2 name:@"Video 2"],
                    [PJInputOption inputOptionWithType:PJInputTypeDigital number:1 name:@"Digital 1"],
                    [PJInputOption inputOptionWithType:PJInputTypeDigital number:2 name:@"Digital 2"],
                    [PJInputOption inputOptionWithType:PJInputTypeStorage number:1 name:@"Storage 1"],
                    [PJInputOption inputOptionWithType:PJInputTypeNetwork number:1 name:@"Network 1"]];
        _audioMuted       = NO;
        _videoMuted       = NO;
        _fanError         = PJErrorStatusOK;
        _lampError        = PJErrorStatusOK;
        _temperatureError = PJErrorStatusOK;
        _coverOpenError   = PJErrorStatusOK;
        _filterError      = PJErrorStatusOK;
        _otherError       = PJErrorStatusOK;
        _lampStatus       = @[[PJLampStatus lampStatusWithState:NO hours:11],
                              [PJLampStatus lampStatusWithState:NO hours:22],
                              [PJLampStatus lampStatusWithState:NO hours:33]];
        _projectorName    = @"Projector1";
        _manufacturerName = @"Manufacturer1";
        _productName      = @"CocoaPJLinkServer";
        _otherInformation = @"None";
        _class2Compatible = NO;
        _usePassword      = NO;
        _password         = @"pjlink";
    }

    return self;
}

- (NSUInteger)countOfInputs {
    return [_inputs count];
}

- (id)objectInInputsAtIndex:(NSUInteger)index {
    return [_inputs objectAtIndex:index];
}

- (NSArray*)inputsAtIndexes:(NSIndexSet *)indexes {
    return [_inputs objectsAtIndexes:indexes];
}

- (NSUInteger)countOfLampStatus {
    return [_lampStatus count];
}

- (id)objectInLampStatusAtIndex:(NSUInteger)index {
    return [_lampStatus objectAtIndex:index];
}

- (NSArray*)lampStatusAtIndexes:(NSIndexSet *)indexes {
    return [_lampStatus objectsAtIndexes:indexes];
}

- (void)handlePowerCommand:(BOOL)on {
    if (on) {
        if (self.powerStatus == PJPowerStatusStandby) {
            // We we are in standby, and we get a power on, then
            // we transition to warm up and set a timer. When the
            // timer fires, then we transition to lamp on
            self.powerStatus = PJPowerStatusWarmUp;
            // Schedule a timer
            [self scheduleTimerWithTimeout:kWarmUpTime];
        }
    } else {
        if (self.powerStatus == PJPowerStatusLampOn) {
            // Transition to cool down
            self.powerStatus = PJPowerStatusCooling;
            // When we are in lamp on status, and we get a power off,
            // then we transition to cooling down, and set a timer.
            // When the timer fires, we transtion to standby
            [self scheduleTimerWithTimeout:kCoolDownTime];
        }
    }
}

- (void)setUsePassword:(BOOL)usePassword {
    if (_usePassword != usePassword) {
        _usePassword = usePassword;
        [self updatePassword];
    }
}

- (void)setPassword:(NSString *)password {
    if (![_password isEqualToString:password]) {
        _password = [password copy];
        [self updatePassword];
    }
}

- (BOOL)validatePowerStatus:(id *)ioValue error:(NSError * __autoreleasing *)outError {
    BOOL ret = NO;

    if (ioValue != nil) {
        id powerStatusId = *ioValue;
        if ([powerStatusId isKindOfClass:[NSNumber class]]) {
            NSUInteger powerStatus = [powerStatusId unsignedIntegerValue];
            if (powerStatus <= PJPowerStatusWarmUp) {
                ret = YES;
            }
        }
    }
    if (!ret && outError != NULL) {
        *outError = [PJProjector errorWithCode:PJErrorCodeInvalidPowerStatus localizedDescription:@"Invalid value for power status. Power status must be 0-3."];
    }

    return ret;
}

#pragma mark - PJProjector private methods

- (void)timerFired:(NSTimer*)timer {
    _powerStatusTransitionTimer = nil;
    if (self.powerStatus == PJPowerStatusWarmUp) {
        self.powerStatus = PJPowerStatusLampOn;
    } else if (self.powerStatus == PJPowerStatusCooling) {
        self.powerStatus = PJPowerStatusStandby;
    }
}

- (void)scheduleTimerWithTimeout:(NSTimeInterval)timeout {
    [_powerStatusTransitionTimer invalidate];
    _powerStatusTransitionTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                                   target:self
                                                                 selector:@selector(timerFired:)
                                                                 userInfo:nil
                                                                  repeats:NO];
}

+ (NSError*)errorWithCode:(NSInteger)code localizedDescription:(NSString*)description {
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : description };
    return [NSError errorWithDomain:PJProjectorErrorDomain code:code userInfo:userInfo];
}

- (uint32_t)generate32BitRandomInteger {
    uint32_t rand = 0;

    FILE* fp = fopen("/dev/random", "r");
    if (fp != NULL) {
        for (int i = 0; i < 4; i++) {
            uint8_t randByte = fgetc(fp);
            uint32_t randByteShifted = randByte << (i * 8);
            rand |= randByteShifted;
        }
    }

    return rand;
}

- (void)updatePassword {
    if (_usePassword && [_password length] > 0) {
        // Get a random number
        _randomNumber = [self generate32BitRandomInteger];
        // Concatenate the random number and the password
        NSString* randomPlusPassword = [NSString stringWithFormat:@"%08x%@", _randomNumber, _password];
        // Get UTF8 data for this
        NSData* randomPlusPasswordData = [randomPlusPassword dataUsingEncoding:NSUTF8StringEncoding];
        // Call CC_MD5 to do the hash
        unsigned char md5Result[CC_MD5_DIGEST_LENGTH];
        CC_MD5([randomPlusPasswordData bytes], [randomPlusPasswordData length], md5Result);
        // Create a hex string from the MD5 data
        NSMutableString* tmpStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char ithChar = md5Result[i];
            [tmpStr appendFormat:@"%02x", ithChar];
        }
        // Create a string from this hex string
        _encryptedPassword = [NSString stringWithString:tmpStr];
    } else {
        // Password was cleared, so clear out random number and encrypted password
        _randomNumber      = 0;
        _encryptedPassword = nil;
    }
}

@end
