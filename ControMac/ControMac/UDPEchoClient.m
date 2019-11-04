//
//  UDPEchoClient.m
//  ControMac
//
//  Created by iMac on 2019/11/5.
//  Copyright © 2019 iMac. All rights reserved.
//

#import "UDPEchoClient.h"
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netinet/in.h>
#include <pcap.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/if_ether.h>
#include <netinet/ip.h>
#include <string.h>

#define IP      "192.168.1.91"
#define PORT    31245

static void dataAvailableCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    //
    //  receiving information sent back from the echo server
    //
    CFDataRef dataRef = (CFDataRef)data;
    NSLog(@"data recieved (%s) ", CFDataGetBytePtr(dataRef));
}

@implementation UDPEchoClient
{
    //
    //  socket for communication
    //
    CFSocketRef cfsocketout;
    
    //
    //  address object to store the host details
    //
    struct sockaddr_in  addr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //
        //  instantiating the CFSocketRef
        //
        cfsocketout = CFSocketCreate(kCFAllocatorDefault,
                                     PF_INET,
                                     SOCK_DGRAM,
                                     IPPROTO_UDP,
                                     kCFSocketDataCallBack,
                                     dataAvailableCallback,
                                     NULL);
        
        memset(&addr, 0, sizeof(addr));
        
        addr.sin_len            = sizeof(addr);
        addr.sin_family         = AF_INET;
        addr.sin_port           = htons(PORT);
        addr.sin_addr.s_addr    = inet_addr(IP);
        
        //
        // set runloop for data reciever
        //
        CFRunLoopSourceRef rls = CFSocketCreateRunLoopSource(kCFAllocatorDefault, cfsocketout, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
        CFRelease(rls);
        
    }
    return self;
}


//
//  returns true upon successfull sending
//
- (BOOL) sendData:(const char *)msg
{
    //
    //  checking, is my socket is valid
    //
    if(cfsocketout)
    {
        //
        //  making the data from the address
        //
        CFDataRef addr_data = CFDataCreate(NULL, (const UInt8*)&addr, sizeof(addr));
        
        //
        //  making the data from the message
        //
        CFDataRef msg_data  = CFDataCreate(NULL, (const UInt8*)msg, strlen(msg));
        
        //
        //  actually sending the data & catch the status
        //
        CFSocketError socketErr = CFSocketSendData(cfsocketout,
                                                   addr_data,
                                                   msg_data,
                                                   0);
        
        //
        //  return true/false upon return value of the send function
        //
        return (socketErr == kCFSocketSuccess);
        
    }
    else
    {
        NSLog(@"socket reference is null");
        return false;
    }
}
@end
