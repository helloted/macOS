//
//  UDPServer.m
//  MacUDPServer
//
//  Created by Akihiro Okubo on 2014/06/22.
//  Copyright (c) 2014年 Akihiro Okubo. All rights reserved.
//

#import "UDPServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <sys/types.h>
#include <netinet/in.h>

@implementation UDPServer
{
    CFSocketRef          sock;
    CFRunLoopSourceRef   cfSource;
}
    
- (id)init
{
    self = [super init];
    if (self) {
        [self showNetworkInfo];
        [self createUdpSocketServer];
    }
    return self;
}

#define PORT 30050

- (void)createUdpSocketServer
{
    /*
    int sock;
    struct sockaddr_in addr;
    
    char buf[2048];
    
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    
    addr.sin_family = AF_INET;
    addr.sin_port = htons(30050);
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_len = sizeof(addr);
    
    bind(sock, (struct sockaddr *)&addr, sizeof(addr));
    
    memset(buf, 0, sizeof(buf));
    recv(sock, buf, sizeof(buf), 0);
    
    NSLog(@"%s", buf);
    
    close(sock);
    */
    
    int yes = 1;
    int setSockResult = 0;
    
    CFSocketContext socketContext = {0, (__bridge void*)self, NULL, NULL, NULL};
    
    // Create the server socket as a UDP IPv4 socket and set a callback
    // for calls to the socket's lower-level accept() function
    sock = CFSocketCreate(NULL, PF_INET, SOCK_DGRAM, IPPROTO_UDP,
                          kCFSocketAcceptCallBack | kCFSocketDataCallBack | kCFSocketReadCallBack |
                          kCFSocketConnectCallBack,
                          (CFSocketCallBack)bcSocketCallback, &socketContext);
    if(sock == NULL)
    {
        NSLog(@"UDP socket could not be created\n");
        return;
    }
    
    // Re-use local addresses.
    // まだTIME_WAIT状態の場合、ローカルアドレスを利用
    // setsockopt()を利用してソケットに対してSO_REUSEADDRを設定すると、
    // TIME_WAIT状態のポートが存在していてもbindができるようになる
    setSockResult = setsockopt(CFSocketGetNative(sock),
                               SOL_SOCKET, SO_REUSEADDR, //SO_BROADCAST,
                               (void *)&yes, sizeof(yes));
    
    if(setSockResult < 0)
    {
        NSLog(@"Could not setsockopt for broadcast");
        CFSocketInvalidate(sock);
        CFRelease(sock);
        return;
    }
    
    // Set the port and address we want to listen on
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    //ホストバイトオーダーからTCP/IPネットワークバイトオーダー（ビッグエンディアン）に変換
    addr.sin_port = htons(PORT);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    NSData *address = [NSData dataWithBytes:&addr length: sizeof(addr)];
    int success = CFSocketSetAddress(sock, (__bridge CFDataRef)address);
    if(address != nil && success != kCFSocketSuccess)
    {
        NSLog(@"CFSocketSetAddress() failed\n");
        CFSocketInvalidate(sock);
        CFRelease(sock);
        return;
    }
    
    // Set the socket listener up in the main run loop.
    cfSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, sock, 0);
    if(cfSource == NULL)
    {
        NSLog(@"CFRunLoopSourceRef is null");
        CFSocketInvalidate(sock);
        CFRelease(sock);
        return;
    }
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);
    NSLog(@"Socket listening on port %d", PORT);
}

static void bcSocketCallback(CFSocketRef cfSocket,
                             CFSocketCallBackType type,
                             CFDataRef address,
                             const void *data,
                             void *userInfo)
{
    NSLog(@"Received broadcast packet call back=%d", type);
    
    if(type == kCFSocketDataCallBack)
    {
        //受信データ取得
        int packetSize = CFDataGetLength((CFDataRef)data);
        const UInt8 *packet = CFDataGetBytePtr((CFDataRef)data);
        
        NSLog(@"Received broadcast packet of %d bytes",packetSize);
        NSString *ident = [[NSString alloc] initWithBytes:packet
                                                   length:packetSize
                                                 encoding:NSASCIIStringEncoding];
        NSLog(@"Packet ident is %@",ident);
        
        //送信先IPアドレス取得
        const UInt8 *addr = CFDataGetBytePtr(address);
        NSString *ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)addr)->sin_addr)];
        NSLog(@"Detected IP Address %@",ip);
    }
}

#pragma - Debug

- (void)showNetworkInfo
{
    struct ifaddrs *ifa_list;
    struct ifaddrs *ifa;
    int n;
    char addrstr[256], netmaskstr[256];
    
    /* (1) */
    n = getifaddrs(&ifa_list);
    if (n != 0) {
        return;
    }
    
    /* (2) */
    for(ifa = ifa_list; ifa != NULL; ifa=ifa->ifa_next) {
        
        /* (3) */
        printf("%s\n", ifa->ifa_name);
        printf("  0x%.8x\n", ifa->ifa_flags);
        
        memset(addrstr, 0, sizeof(addrstr));
        memset(netmaskstr, 0, sizeof(netmaskstr));
        
        if (ifa->ifa_addr->sa_family == AF_INET) {  /* (4) */
            inet_ntop(AF_INET,
                      &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr,
                      addrstr, sizeof(addrstr));
            
            inet_ntop(AF_INET,
                      &((struct sockaddr_in *)ifa->ifa_netmask)->sin_addr,
                      netmaskstr, sizeof(netmaskstr));
            
            printf("  IPv4: %s netmask %s\n", addrstr, netmaskstr);
            
        } else if (ifa->ifa_addr->sa_family == AF_INET6) { /* (5) */
            inet_ntop(AF_INET6,
                      &((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_addr,
                      addrstr, sizeof(addrstr));
            
            inet_ntop(AF_INET6,
                      &((struct sockaddr_in6 *)ifa->ifa_netmask)->sin6_addr,
                      netmaskstr, sizeof(netmaskstr));
            
            printf("  IPv6: %s netmask %s\n", addrstr, netmaskstr);
        } else { /* (6) */
            printf("  else:%d\n", ifa->ifa_addr->sa_family);
        }
        
        printf("\n");
    }
    
    /* (7) */
    freeifaddrs(ifa_list);
}

@end
