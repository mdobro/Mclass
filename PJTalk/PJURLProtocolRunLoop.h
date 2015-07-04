//
//  PJURLProtocolRunLoop.h
//  PJLinkCocoa
//
//  Created by Eric Hyche on 4/25/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kPJLinkScheme      = @"pjlink";
static NSString* const kPJLinkPOWR        = @"POWR";
static NSString* const kPJLinkINPT        = @"INPT";
static NSString* const kPJLinkAVMT        = @"AVMT";
static NSString* const kPJLinkERST        = @"ERST";
static NSString* const kPJLinkLAMP        = @"LAMP";
static NSString* const kPJLinkINST        = @"INST";
static NSString* const kPJLinkNAME        = @"NAME";
static NSString* const kPJLinkINF1        = @"INF1";
static NSString* const kPJLinkINF2        = @"INF2";
static NSString* const kPJLinkINFO        = @"INFO";
static NSString* const kPJLinkCLSS        = @"CLSS";
static NSString* const kPJLinkOK          = @"OK";
static NSString* const kPJLinkERR1        = @"ERR1";
static NSString* const kPJLinkERR2        = @"ERR2";
static NSString* const kPJLinkERR3        = @"ERR3";
static NSString* const kPJLinkERR4        = @"ERR4";
static NSString* const kPJLinkHeaderClass = @"%1";
static NSString* const kPJLinkCR          = @"\r";
static NSString* const PJLinkErrorDomain  = @"PJLinkErrorDomain";

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
