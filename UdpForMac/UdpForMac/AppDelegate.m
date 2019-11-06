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


#define BindPort 31243

@interface AppDelegate ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (nonatomic, strong) NSMenuItem *ipMenuItem;
@property (nonatomic, strong) NSMenuItem *titleMenuItem;

@property (nonatomic, strong)GCDAsyncUdpSocket  *udpSocket;

@property (nonatomic, strong)NSMutableDictionary   *sendDatas;

@property (nonatomic, strong) NSString   *echoIP;
@property (nonatomic, assign) NSUInteger  echoPort;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // sudo lsof -i -n -P | grep UDP
    [self customStatusItem];
    [self createClientUdpSocket];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


-(void)createClientUdpSocket{
    //创建udp socket
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //banding一个端口(可选),如果不绑定端口,那么就会随机产生一个随机的电脑唯一的端口
    NSError * error = nil;
    [self.udpSocket bindToPort:31243 interface:nil error:&error];
    
    //启用广播
    [self.udpSocket enableBroadcast:YES error:&error];
    
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {//监听成功则开始接收信息
        NSLog(@"UDP创建成功");
        [self.udpSocket beginReceiving:&error];
    }
}


- (void)echoWithDictionary:(NSDictionary *)dic{
    [self sendUDPWithData:dic toHost:self.echoIP port:self.echoPort];
}

- (void)sendUDPWithData:(NSDictionary *)data toHost:(NSString *)host port:(NSUInteger)port{
    if (!data) {
        NSLog(@"data为空");
        return;
    }
    NSError *error;
    int tag = arc4random() % 1000;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    //发送数据（tag: 消息标记）
    [self.udpSocket sendData:jsonData toHost:host port:port withTimeout:-1 tag:tag];

    [self.sendDatas setValue:data forKey:@(tag).stringValue];
}

#pragma mark GCDAsyncUdpSocketDelegate


//发送数据成功
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSDictionary *send = [self.sendDatas valueForKey:@(tag).stringValue];
    NSLog(@"mac=>iphone:%@",send);
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
    
    if (result) {
        NSInteger type = 0;
        NSNumber *typeNum = [result objectForKey:@"type"];
        if (typeNum && [typeNum respondsToSelector:@selector(integerValue)]) {
            type = typeNum.integerValue;
        }

        if (type == 1) { // 手机向外广播搜索时
            self.echoIP = [GCDAsyncUdpSocket hostFromAddress:address];
            self.echoPort = [GCDAsyncUdpSocket portFromAddress:address];
            
            NSDictionary *dic = @{@"type":@(2),@"hostname":@"MyMac"};
            [self echoWithDictionary:dic];
        }
        
        
        if (type == 3) {
            NSNumber *mediaNum = [result valueForKey:@"inputKey"];
            if ([mediaNum respondsToSelector:@selector(intValue)]) {
                [self sendMediaKey:mediaNum.intValue];
            }
        }

    }
    
}

- (void)customStatusItem{
    // info.plist里加LSUIElement为YES可以让App不出现在Dock栏，Main.storyboard的向右箭头删除不出现主窗口
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // status栏的图片，16*16pt
    _statusItem.button.image = [NSImage imageNamed:@"status_bar"];
    
    // 点击后的status栏的图片，一般用白色的
    _statusItem.button.alternateImage = [NSImage imageNamed:@"status_bar_white"];
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    [menu addItemWithTitle:@"Mac遥控器" action:nil keyEquivalent:@""];
    NSString *title = [NSString stringWithFormat:@"%@:%d",[HTHandler getIPAddress],BindPort];
    [menu addItemWithTitle:title action:nil keyEquivalent:@""];
    
//    [menu addItemWithTitle:@"Refresh" action:@selector(openFeedbin:) keyEquivalent:@""];
//    [menu addItemWithTitle:@"Refresh" action:@selector(openFeedbin:) keyEquivalent:@""];
    
    [menu addItem:self.ipMenuItem];
    
    // 灰色分割线
    [menu addItem:[NSMenuItem separatorItem]];
    
    // 退出
    [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
}


- (void)openFeedbin:(id)sender{
    NSLog(@"openFeedbin clicked ==%@",[HTHandler getIPAddress]);
    
    int key = 7;
    [self sendMediaKey:17];
}

-(void)sendMediaKey:(int)key{
    NSEvent *key_event = [[NSEvent alloc]init];
    // create and send down key event
    key_event = [NSEvent otherEventWithType:NSSystemDefined location:CGPointZero modifierFlags:0xa00 timestamp:0 windowNumber:0 context:0 subtype:8 data1:((key << 16) | (0xa << 8)) data2:-1];
    CGEventPost(0, key_event.CGEvent);
    NSLog(@"%d keycode (down) sent",key);
    
    // create and send up key event
    key_event = [NSEvent otherEventWithType:NSSystemDefined location:CGPointZero modifierFlags:0xb00 timestamp:0 windowNumber:0 context:0 subtype:8 data1:((key << 16) | (0xb << 8)) data2:-1];
    CGEventPost(0, key_event.CGEvent);
    NSLog(@"%d keycode (up) sent",key);
}


#pragma mark Getter&Setter

- (NSMenuItem *)ipMenuItem{
    if (!_ipMenuItem) {
        NSString *title = [NSString stringWithFormat:@"%@:%d",[HTHandler getIPAddress],BindPort];
        
        NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithString:title];
        [mAttribute addAttribute:NSForegroundColorAttributeName
                           value:[NSColor redColor]
                           range:NSMakeRange(0, 5)];
        _ipMenuItem = [[NSMenuItem alloc]initWithTitle:@"Mac遥控器" action:nil keyEquivalent:@""];
        _ipMenuItem.enabled = YES;
        _ipMenuItem.alternate = YES;
        _ipMenuItem.attributedTitle = mAttribute;
    }
    return _ipMenuItem;
}

- (NSMenuItem *)titleMenuItem{
    if (!_titleMenuItem) {
        NSString *title = [NSString stringWithFormat:@"Mac遥控器"];
        
        NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithString:title];
        [mAttribute addAttribute:NSForegroundColorAttributeName
                           value:[NSColor redColor]
                           range:NSMakeRange(0, 2)];
        _titleMenuItem = [[NSMenuItem alloc]initWithTitle:@"" action:nil keyEquivalent:@""];
        _titleMenuItem.enabled = YES;
        _titleMenuItem.alternate = YES;
        _titleMenuItem.attributedTitle = mAttribute;
    }
    return _titleMenuItem;
}

#pragma mark Getter&Setter

- (NSMutableDictionary *)sendDatas{
    if (!_sendDatas) {
        _sendDatas = [NSMutableDictionary dictionary];
    }
    return _sendDatas;
}


@end
