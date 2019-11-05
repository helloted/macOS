//
//  AppDelegate.m
//  iSandBox
//
//  Created by Haozhicao on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncUdpSocket.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface AppDelegate () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (nonatomic, strong)NSMenuItem *ipMenuItem;

@property (strong, nonatomic)GCDAsyncUdpSocket * udpSocket;
@property (nonatomic, strong)NSMutableDictionary   *sendDatas;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self customStatusItem];
    [self createClientUdpSocket];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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
    [menu addItemWithTitle:[self getIPAddress] action:@selector(openFeedbin:) keyEquivalent:@""];
    
//    [menu addItem:self.ipMenuItem];
    [menu addItemWithTitle:@"Refresh" action:@selector(openFeedbin:) keyEquivalent:@""];

    // 灰色分割线
    [menu addItem:[NSMenuItem separatorItem]];
    
    // 退出
    [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
}

//- (void)initUDPSocket{
//    self.ipMenuItem.title = [self getIPAddress];
//}

- (void)openFeedbin:(id)sender{
    NSLog(@"openFeedbin clicked ==%@",[self getIPAddress]);
}

- (NSString *)getIPAddress {

    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSLog(@"inter:%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] containsString:@"en"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

                }

            }

            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;

}

-(void)createClientUdpSocket{
    //创建udp socket
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //banding一个端口(可选),如果不绑定端口,那么就会随机产生一个随机的电脑唯一的端口
    NSError * error = nil;
//    [self.udpSocket bindToPort:31245 error:&error];
    
    [self.udpSocket bindToPort:31288 error:&error];
    
    //启用广播
    [self.udpSocket enableBroadcast:YES error:&error];
    
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {//监听成功则开始接收信息
        NSLog(@"UDP创建成功");
        [self.udpSocket beginReceiving:&error];
    }
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSError * error = nil;
//        [self.udpSocket bindToPort:31245 error:&error];
//        NSLog(@"bbbbbbind==");
//    });
}

////广播
//-(void)broadcast{
//    NSDictionary *firstDict = @{@"type":@(BroadcastSendType),@"msg":@"Broadcast Searching..."};
//    NSString *host = @"255.255.255.255";
//    [self sendUDPWithData:firstDict toHost:host];
//}

//- (void)sendUDPWithData:(NSDictionary *)data toHost:(NSString *)host{
//    if (!data) {
//        NSLog(@"data为空");
//        return;
//    }
//    NSError *error;
//    int tag = arc4random() % 1000;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
//    //发送数据（tag: 消息标记）
//    [self.udpSocket sendData:jsonData toHost:host port:MacPort withTimeout:-1 tag:tag];
//
//    [self.sendDatas setValue:data forKey:@(tag).stringValue];
//}

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
    
//    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
//    if (port != MacPort) {
//        return;
//    }
    
    if (!data) {
        return;
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *result = [self dictionaryWithJsonString:str];
    NSLog(@"mac=>iphone:%@",result);
    
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

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(NSString *)strFromJsonDict:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
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

- (NSMutableDictionary *)sendDatas{
    if (!_sendDatas) {
        _sendDatas = [NSMutableDictionary dictionary];
    }
    return _sendDatas;
}


@end
