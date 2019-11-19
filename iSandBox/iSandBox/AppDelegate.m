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
#import "URLContent.h"
#import "AboutWindowController.h"

NSString *const mainMenuTitle = @"Main Menu";
NSInteger const recent_max = 10;

NSInteger const about_Tag = 990;

@interface AppDelegate () <NSMenuDelegate, ApplicationMenuItemDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (nonatomic, strong)NSMenuItem *ipMenuItem;

@property (nonatomic, strong) NSMenu *mainMenu;

@property (nonatomic, strong) AboutWindowController *aboutWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self customStatusItem];
    [self rebuildMenu];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)menuWillOpen:(NSMenu *)menu{
    NSLog(@"menu will open");
    [self rebuildMenu];
}

- (void)rebuildMenu{
    dispatch_async(dispatch_queue_create("SimulatorManagerQueue", DISPATCH_QUEUE_SERIAL), ^{
        NSString *jsonString = shell(@"/usr/bin/xcrun", @[@"simctl", @"list", @"-j", @"devices"]);
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([json isKindOfClass:[NSDictionary class]] == NO) {
            return;
        }
    
        NSMutableArray *recentList = [NSMutableArray array];
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
                    HTDevice *d = [[HTDevice alloc] initWithDictionary:sim osVersion:version];
                    [dataList addObject:d];
                    if (!d.isUnavailable) {
                        /** 可用模拟器才添加到最近列表 */
                        [recentList addObjectsFromArray:d.appList];
                    }
                }
            }
        }
        
        /** 筛选最近使用应用 */
        [recentList sortUsingComparator:^NSComparisonResult(HTAppInfo *  _Nonnull obj1, HTAppInfo *  _Nonnull obj2) {
            return obj1.sortDateTime < obj2.sortDateTime;
        }];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainMenu removeAllItems];
            [self buildAppMenuWith:recentList];
            [self mainMenuAppendNormalItem];
            [self.mainMenu update];
        });
        
    });
}


- (void)buildAppMenuWith:(NSArray *)recentList{
    NSMenu *menu = self.mainMenu;
    
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
        NSMenuItem *recentApps = [self createTipsItemWithTitle:@"最近使用"];
        [menu insertItem:recentApps atIndex:nextIndex++];
        /** 数据 */
        for (NSInteger i=0; i<recentList.count; i++) {
            if (i == recent_max) {
                break;
            }
            HTAppInfo *app = recentList[i];
            
            ApplicationMenuItem *appItem = [[ApplicationMenuItem alloc] initWithApp:app withDetailText:app.deviceName];
            appItem.action = @selector(openAppDocument:);
            appItem.target = self;
            appItem.representedObject = app;
            appItem.delegate = self;
            [menu insertItem:appItem atIndex:nextIndex++];
        }
        
        [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
        
    } else {
        /** 第一标题 */
        NSMenuItem *recentApps = [self createTipsItemWithTitle:@"NO Simulators"];
        [menu insertItem:recentApps atIndex:nextIndex++];
        [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
    }

}

- (void)mainMenuAppendNormalItem{
    /** 第三标题 */
    NSMenuItem *aboutItem  = [[NSMenuItem alloc] initWithTitle:@"关于iSandBox" action:@selector(appAbout) keyEquivalent:@""];
    aboutItem.tag = about_Tag;
    aboutItem.target = self;
    [self.mainMenu addItem:aboutItem];
    
//    NSMenuItem *prefeItem  = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(appPreferences:) keyEquivalent:@"p"];
//    prefeItem.target = self;
//    [self.mainMenu addItem:prefeItem];
//
    [self.mainMenu addItem:[NSMenuItem separatorItem]];
    
    /** 第四标题 */
    [self.mainMenu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@"q"];
}

- (void)appAbout{
    [NSApp activateIgnoringOtherApps:YES];
    if (_aboutWindowController == nil) {
        _aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    }
    [_aboutWindowController.window center];
    [_aboutWindowController.window orderFrontRegardless];
    
    [_aboutWindowController showWindow:self];
}


- (void)openAppDocument:(ApplicationMenuItem *)menu
{
    HTAppInfo *appInfo = menu.app;
    NSURL *appUrl = [self getAppDocumentUrl:appInfo];
    if (appUrl) {
        [[NSWorkspace sharedWorkspace] openURL:appUrl];
    }
}

- (NSURL *)getAppDocumentUrl:(HTAppInfo *)appInfo
{
    if (appInfo == nil) return nil;
    NSURL *url = applicationPathURL(appInfo.UDID);
    NSArray *dirEnumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    
    NSURL *appUrl = nil;
    for (NSURL *dirUrl in dirEnumerator) {
        NSDictionary *mobileContainerManager = [NSDictionary dictionaryWithContentsOfURL:mobileContainerManagerPlistURL(dirUrl)];
        if ([mobileContainerManager[mobileContainerManagerPlist_Identifier] isEqualToString:appInfo.bundleId]) {
            appUrl = dirUrl;
            break;
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:appUrl.path])
    {
        return appUrl;
    }
    return nil;
}


- (NSMenuItem *)createTipsItemWithTitle:(NSString *)title
{
    NSMenuItem * tips = [[NSMenuItem alloc] initWithTitle:title action:Nil keyEquivalent:@""];
    tips.enabled = NO;
    return tips;
}

- (void)customStatusItem{
    // info.plist里加LSUIElement为YES可以让App不出现在Dock栏，Main.storyboard的向右箭头删除不出现主窗口
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // status栏的图片，16*16pt
    _statusItem.button.image = [NSImage imageNamed:@"status_bar"];
    
    // 点击后的status栏的图片，一般用白色的
    _statusItem.button.alternateImage = [NSImage imageNamed:@"status_bar_white"];
    
    _statusItem.menu = self.mainMenu;
}

#pragma mark Getter&Setter

- (NSMenu *)mainMenu{
    if (!_mainMenu) {
        _mainMenu = [[NSMenu alloc] initWithTitle:mainMenuTitle];
        _mainMenu.delegate = self;
    }
    return _mainMenu;
}

- (NSMenuItem *)ipMenuItem{
    if (!_ipMenuItem) {
        _ipMenuItem = [[NSMenuItem alloc]initWithTitle:@"" action:nil keyEquivalent:@"A"];
        _ipMenuItem.enabled = YES;
        _ipMenuItem.alternate = YES;
    }
    return _ipMenuItem;
}



@end
