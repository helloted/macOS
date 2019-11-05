//
//  AppDelegate.m
//  ControMac
//
//  Created by iMac on 2019/11/4.
//  Copyright © 2019 iMac. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncUdpSocket.h"
#import "HTHandler.h"
#import "UDPEchoClient.h"
#import "AsyncUdpSocket.h"
#import "UDPServer.h"

@interface AppDelegate ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (nonatomic, strong) NSMenuItem *ipMenuItem;

@property (nonatomic, strong)GCDAsyncUdpSocket  *udpSocket;

@property (nonatomic, strong)NSMutableDictionary   *sendDatas;

@property (nonatomic, strong)UDPEchoClient      *client;

@property (nonatomic, strong)AsyncUdpSocket *asy;

@end

@implementation AppDelegate

//{
//    UDPSocket *udp;
//}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // sudo lsof -i -n -P | grep UDP
    [self customStatusItem];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       UDPServer *server = [[UDPServer alloc] init];
                   });
    
//    udp = [UDPSocket shareUdpScoket];
//    [self createClientUdpSocket];
    
//    udp = [[UdpSocket alloc]init];
//    self.asy =  [[AsyncUdpSocket alloc]initWithDelegate:self];
//    NSError *err = nil;
//    BOOL reuslt = [self.asy bindToPort:19998 error:&err];
//    //启动接收线程
//    [self.asy receiveWithTimeout:-1 tag:200];
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


- (void)sendUDPWithData:(NSDictionary *)data toHost:(NSString *)host{
    if (!data) {
        NSLog(@"data为空");
        return;
    }
        NSError *error;
        int tag = arc4random() % 1000;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
        //发送数据（tag: 消息标记）
        [self.udpSocket sendData:jsonData toHost:host port:33333 withTimeout:-1 tag:tag];
    
        [self.sendDatas setValue:data forKey:@(tag).stringValue];
}

#pragma mark GCDAsyncUdpSocketDelegate


//发送数据成功
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSDictionary *send = [self.sendDatas valueForKey:@(tag).stringValue];
    NSLog(@"iphone=>mac:%@",send);
}

//发送数据失败
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"标记为%ld的数据发送失败，失败原因：%@",tag, error);
}

//接收到数据
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    if (!data) {
        return;
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *result = [HTHandler dictionaryWithJsonString:str];
    NSLog(@"iphone=>mac:%@",result);
    //
    //    if (result) {
    //        NSInteger type = 0;
    //        NSNumber *typeNum = [result objectForKey:@"type"];
    //        if (typeNum && [typeNum respondsToSelector:@selector(integerValue)]) {
    //            type = typeNum.integerValue;
    //        }
    //
    //        if (type == 2) { // 向外广播搜索时的回消息
    //            self.receivedMacHostName = [result objectForKey:@"hostname"];
    //            self.receivedMacHostIP = [GCDAsyncUdpSocket hostFromAddress:address];
    //            self.lastIP = self.receivedMacHostIP;
    //            [[NSUserDefaults standardUserDefaults] setValue:self.lastIP forKey:kRemoteIPKey];
    //        }
    //
    //    }
    
}

- (void)customStatusItem{
    // info.plist里加LSUIElement为YES可以让App不出现在Dock栏，Main.storyboard的向右箭头删除不出现主窗口
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // status栏的图片，16*16pt
    _statusItem.button.image = [NSImage imageNamed:@"status_bar"];
    
    // 点击后的status栏的图片，一般用白色的
    _statusItem.button.alternateImage = [NSImage imageNamed:@"status_bar_white"];
    
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    //    NSString *ip = [self getIPAddress];
    //
    //    [menu addItemWithTitle:[self getIPAddress] action:@selector(openFeedbin:) keyEquivalent:@""];
    
    self.ipMenuItem.title = [HTHandler getIPAddress];
    [menu addItem:self.ipMenuItem];
    [menu addItemWithTitle:@"Refresh" action:@selector(openFeedbin:) keyEquivalent:@""];
    
    // 灰色分割线
    [menu addItem:[NSMenuItem separatorItem]];
    
    // 退出
    [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
}


- (void)openFeedbin:(id)sender{
    NSLog(@"openFeedbin clicked ==%@",[HTHandler getIPAddress]);
    [self sendUDPWithData:@{@"hello":@"world"} toHost:[HTHandler getIPAddress]];
}


#pragma mark Getter&Setter

- (NSMenuItem *)ipMenuItem{
    if (!_ipMenuItem) {
        _ipMenuItem = [[NSMenuItem alloc]initWithTitle:@"" action:nil keyEquivalent:@"A"];
        _ipMenuItem.enabled = YES;
        _ipMenuItem.alternate = YES;
    }
    return _ipMenuItem;
}

#pragma mark Getter&Setter

- (NSMutableDictionary *)sendDatas{
    if (!_sendDatas) {
        _sendDatas = [NSMutableDictionary dictionary];
    }
    return _sendDatas;
}


@end
