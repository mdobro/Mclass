//
//  PJLinkConfig.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/10/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJLinkConfig.h"

@implementation PJLinkConfig

@synthesize server = _server;
@synthesize queue  = _queue;

- (id)initWithServer:(PJLinkServer *)aServer
{
    if ((self = [super init]))
    {
        _server = aServer;
    }

    return self;
}

- (id)initWithServer:(PJLinkServer *)aServer queue:(dispatch_queue_t)q
{
    if ((self = [super init]))
    {
        _server = aServer;
        
        if (q)
        {
            _queue = q;
        }
    }
    return self;
}

@end
