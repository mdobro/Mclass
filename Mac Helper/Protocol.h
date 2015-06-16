//
//  PTProtocol.h
//  Mclass
//
//  Created by Mike Dobrowolski on 6/10/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

#ifndef Mclass_Protocol_h
#define Mclass_Protocol_h

const int PTProtocolIPv4PortNumber = 2345;

enum {
    DeviceInfo = 100, Problem = 101, Ping = 102, Pong = 103, Projector1 = 104, Projector2 = 105, HDCP = 106, ProblemRoom = 107, SourceVolume = 108
};

typedef struct _TextFrame {
    uint32_t length;
    uint8_t utf8text[0];
} TextFrame;


dispatch_data_t DispatchDataWithString(NSString *message) {
    // Use a custom struct
    if (message != nil) {
        const char *utf8text = [message cStringUsingEncoding:NSUTF8StringEncoding];
        size_t length = strlen(utf8text);
        TextFrame *textFrame = CFAllocatorAllocate(nil, sizeof(TextFrame) + length, 0);
        memcpy(textFrame->utf8text, utf8text, length); // Copy bytes to utf8text array
        textFrame->length = htonl(length); // Convert integer to network byte order
        
        // Wrap the textFrame in a dispatch data object
        return dispatch_data_create((const void*)textFrame, sizeof(TextFrame)+length, nil, ^{
            CFAllocatorDeallocate(nil, textFrame);
        });
    }
    return nil;
}


#endif
