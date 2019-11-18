//
//  AppDelegate.m
//  iSandBox
//
//  Created by Haozhicao on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import "AppDelegate.h"
#import "Shell.h"
#import "HTDevice.h"
#import "ApplicationMenuItem.h"

NSString *const mainMenuTitle = @"Main Menu";
NSInteger const recent_max = 5;

NSInteger const about_Tag = 990;

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (nonatomic, strong)NSMenuItem *ipMenuItem;

@property (nonatomic, strong) NSMenu *menu_main;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self customStatusItem];
    [self buildUI];
    [self loadData:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)buildUI
{
    if (self.menu_main == nil) {
        NSMenu *menu = [[NSMenu alloc] initWithTitle:mainMenuTitle];
        
        /** 菊花加载 */
//        NSMenuItem * recentLoaded = [MainMenu createTipsItemWithTitle:@""];
//        iActivityIndicatorView *indicator = [[iActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, menu.size.width, 20)];
//        recentLoaded.view = indicator;
//        [menu addItem:recentLoaded];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        /** 第三标题 */
        NSMenuItem *aboutItem  = [[NSMenuItem alloc] initWithTitle:@"About iSimulator" action:@selector(appAbout:) keyEquivalent:@""];
        aboutItem.tag = about_Tag;
        aboutItem.target = self;
        [menu addItem:aboutItem];
        
        NSMenuItem *prefeItem  = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(appPreferences:) keyEquivalent:@","];
        prefeItem.target = self;
        [menu addItem:prefeItem];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        /** 第四标题 */
        NSMenuItem *quitItem  = [[NSMenuItem alloc] initWithTitle:@"Quit iSimulator" action:@selector(appQuit:) keyEquivalent:@"q"];
        quitItem.target = self;
        [menu addItem:quitItem];
        
        self.statusItem.menu = menu;
        menu.delegate = self;
        self.menu_main = menu;
        
        _statusItem.menu = self.menu_main;
    }
}

- (void)loadData:(void (^)(void))complete
{
    
    
    [self loadDevicesJson_async:^(NSDictionary *json) {
//        if ([json isKindOfClass:[NSDictionary class]] == NO) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.resultBlock(@[], @[]);
//                if (complete) complete();
//            });
//            return;
//        }
        /** 数据源容器 */
        NSMutableArray *container = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *recentList = [NSMutableArray arrayWithCapacity:8];
        /** 获取设备 */
        NSDictionary *devices = json[@"devices"];
        /** 设备版本 */
        for (NSString *version in devices) {
            /** 筛选iOS模拟器 */
            if ([version containsString:@"iOS"]) {
                /** 筛选可利用的模拟器 */
                NSMutableArray *dataList = [NSMutableArray array];
                NSArray *simulators = devices[version];
                for (NSDictionary *sim in simulators) {
                    NSLog(@"sim=%@",sim);
                    HTDevice *d = [[HTDevice alloc] initWithDictionary:sim];
                    [dataList addObject:d];
                    if (!d.isUnavailable) {
                        /** 可用模拟器才添加到最近列表 */
                        [recentList addObjectsFromArray:d.appList];
                    }
                }
                if (dataList.count) {
                    /** 过滤历史模拟器 */
                    NSString *key = version;
                    NSString *oldVersion = @"com.apple.CoreSimulator.SimRuntime.";
                    if ([key containsString:oldVersion]) {
                        key = [[key stringByReplacingOccurrencesOfString:oldVersion withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
                        key = [key stringByReplacingCharactersInRange:[key rangeOfString:@"."] withString:@" "];
                    }
                    [container addObject:@{key:dataList}];
                }
            }
        }
        /** 筛选最近使用应用 */
        [recentList sortUsingComparator:^NSComparisonResult(HTAppInfo *  _Nonnull obj1, HTAppInfo *  _Nonnull obj2) {
            return obj1.sortDateTime < obj2.sortDateTime;
        }];
        
        
        NSMenu *menu = self.menu_main;
        
        /** 删除旧数据 直到about_Tag */
        for (NSMenuItem *item in menu.itemArray) {
            if (item.tag == about_Tag) {
                break;
            }
            if (item.menu) {
                [menu removeItem:item];
            }
        }
        
        NSInteger nextIndex = 0;
        
        if (recentList.count) {
            /** 第一标题 */
            NSMenuItem *recentApps = [self createTipsItemWithTitle:@"Recent Apps"];
            [menu insertItem:recentApps atIndex:nextIndex++];
            /** 数据 */
            for (NSInteger i=0; i<recentList.count; i++) {
                if (i == recent_max) {
                    break;
                }
                HTAppInfo *app = recentList[i];
                NSMenuItem *appItem = [self createTipsItemWithTitle:app.bundleDisplayName];
//                ApplicationMenuItem *appItem = [[ApplicationMenuItem alloc] initWithApp:app withDetailText:app.deviceName];
//                appItem.action = @selector(appOnClickInMenu:);
//                appItem.target = self;
//                appItem.representedObject = app;
//                appItem.delegate = self;
                [menu insertItem:appItem atIndex:nextIndex++];
            }
            
            [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
            /** 数据 */
            [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
            
        } else {
            /** 第一标题 */
            NSMenuItem *recentApps = [self createTipsItemWithTitle:@"NO Simulators"];
            [menu insertItem:recentApps atIndex:nextIndex++];
            [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
        }
        
        [menu update];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.container = [container copy];
//            self.resultBlock(self.container, [appList copy]);
//            /** 开启监视 */
//            [self startMointor];
//            if (complete) complete();
//        });
    }];
}

- (NSMenuItem *)createTipsItemWithTitle:(NSString *)title
{
    NSMenuItem * tips = [[NSMenuItem alloc] initWithTitle:title action:Nil keyEquivalent:@""];
    tips.enabled = NO;
    return tips;
}


- (void)loadDevicesJson_async:(void (^)(NSDictionary *json))complete
{
    dispatch_async(dispatch_queue_create("SimulatorManagerQueue", DISPATCH_QUEUE_SERIAL), ^{
        NSString *jsonString = shell(@"/usr/bin/xcrun", @[@"simctl", @"list", @"-j", @"devices"]);
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([json isKindOfClass:[NSDictionary class]] == NO) {
            if (complete) complete(nil);
        } else {
            if (complete) complete(json);
        }
    });
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];

    NSFileHandle *file = [pipe fileHandleForReading];

    [task launch];

    NSData *data = [file readDataToEndOfFile];

    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}


- (void)customStatusItem{
    // info.plist里加LSUIElement为YES可以让App不出现在Dock栏，Main.storyboard的向右箭头删除不出现主窗口
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // status栏的图片，16*16pt
    _statusItem.button.image = [NSImage imageNamed:@"status_bar"];
    
    // 点击后的status栏的图片，一般用白色的
    _statusItem.button.alternateImage = [NSImage imageNamed:@"status_bar_white"];
    
    
//    NSMenu *menu = [[NSMenu alloc] init];
//
////    NSString *ip = [self getIPAddress];
//
//
////    [menu addItem:self.ipMenuItem];
//    [menu addItemWithTitle:@"Refresh" action:@selector(openFeedbin:) keyEquivalent:@""];
//
//    // 灰色分割线
//    [menu addItem:[NSMenuItem separatorItem]];
//
//    // 退出
//    [menu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@"q"];
//    _statusItem.menu = menu;
}


- (void)openFeedbin:(id)sender{
    NSLog(@"openFeedbin clicked =");
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
