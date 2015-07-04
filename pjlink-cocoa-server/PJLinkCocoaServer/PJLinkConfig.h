//
//  PJLinkConfig.h
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/10/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PJLinkServer;

@interface PJLinkConfig : NSObject

- (id)initWithServer:(PJLinkServer *)server;
- (id)initWithServer:(PJLinkServer *)server queue:(dispatch_queue_t)q;

@property(nonatomic, weak, readonly) PJLinkServer*    server;
@property(nonatomic, readonly)       dispatch_queue_t queue;

@end
