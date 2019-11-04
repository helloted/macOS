//
//  AppDelegate.m
//  iSandBox
//
//  Created by Haozhicao on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import "AppDelegate.h"
//#import "GCDAsyncUdpSocket.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (nonatomic, strong)NSMenuItem *ipMenuItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self customStatusItem];
    [self initUDPSocket];
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
//    [menu addItemWithTitle:[self getIPAddress] action:@selector(openFeedbin:) keyEquivalent:@""];
    
    [menu addItem:self.ipMenuItem];
    [menu addItemWithTitle:@"Refresh" action:@selector(openFeedbin:) keyEquivalent:@""];

    // 灰色分割线
    [menu addItem:[NSMenuItem separatorItem]];
    
    // 退出
    [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
}

- (void)initUDPSocket{
    self.ipMenuItem.title = [self getIPAddress];
}

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


#pragma mark Getter&Setter

- (NSMenuItem *)ipMenuItem{
    if (!_ipMenuItem) {
        _ipMenuItem = [[NSMenuItem alloc]initWithTitle:@"" action:nil keyEquivalent:@"A"];
        _ipMenuItem.enabled = YES;
        _ipMenuItem.alternate = YES;
    }
    return _ipMenuItem;
}

@end
