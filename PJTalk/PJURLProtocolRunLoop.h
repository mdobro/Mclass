//
//  PJURLProtocolRunLoop.h
//  PJLinkCocoa
//
//  Created by Eric Hyche on 4/25/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kPJLinkScheme;
static NSString* const kPJLinkPOWR;
static NSString* const kPJLinkINPT;
static NSString* const kPJLinkAVMT;
static NSString* const kPJLinkERST;
static NSString* const kPJLinkLAMP;
static NSString* const kPJLinkINST;
static NSString* const kPJLinkNAME;
static NSString* const kPJLinkINF1;
static NSString* const kPJLinkINF2;
static NSString* const kPJLinkINFO;
static NSString* const kPJLinkCLSS;
static NSString* const kPJLinkOK;
static NSString* const kPJLinkERR1;
static NSString* const kPJLinkERR2;
static NSString* const kPJLinkERR3;
static NSString* const kPJLinkERR4;
static NSString* const kPJLinkHeaderClass;
static NSString* const PJLinkErrorDomain;
static NSString* const kPJLinkCR;

enum {
    PJLinkErrorUnknown                  = -1,
    PJLinkErrorNoValidCommandsInRequest = -100,
    PJLinkErrorInvalidAuthSeed          = -101,
    PJLinkErrorNoDataInAuthChallenge    = -102,
    PJLinkErrorNoPasswordProvided       = -103,
    PJLinkErrorNoDataInResponse         = -104,
    PJLinkErrorMissingResponseHeader    = -105
};

@interface PJURLProtocolRunLoop : NSURLProtocol

@end
