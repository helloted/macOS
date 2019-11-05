//
//  AppDelegate.m
//  UdpForMac
//
//  Created by 曹操 on 16/9/12.
//  Copyright © 2016年 Xydawn. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncUdpSocket.h"

@interface AppDelegate () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong)GCDAsyncUdpSocket  *udpSocket;

@end

@implementation AppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self createClientUdpSocket];
//    udp = [UdpSocket shareUdpScoket];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)createClientUdpSocket{
    //创建udp socket
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    
    
    
    
    //banding一个端口(可选),如果不绑定端口,那么就会随机产生一个随机的电脑唯一的端口
    NSError * error = nil;
    [self.udpSocket bindToPort:31245 interface:nil error:&error];
    
    //启用广播
    [self.udpSocket enableBroadcast:YES error:&error];
    
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {//监听成功则开始接收信息
        NSLog(@"UDP创建成功");
        [self.udpSocket beginReceiving:&error];
    }
}

@end
