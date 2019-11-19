//
//  ApplicationMenuItem.h
//  iSandBox
//
//  Created by iMac on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HTAppInfo, ApplicationMenuItem;

@protocol ApplicationMenuItemDelegate <NSObject>

/** 子菜单点击事件回调 */
@optional

- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem revealSandboxInFileViewer:(HTAppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem launchInSimulator:(HTAppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem copySandboxPathToPasteboard:(HTAppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem resetData:(HTAppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem uninstall:(HTAppInfo *)app;

@end

@interface ApplicationMenuItem : NSMenuItem

- (instancetype)initWithApp:(HTAppInfo *)app;
- (instancetype)initWithApp:(HTAppInfo *)app withDetailText:(NSString *)detailText;


@property (nonatomic, weak) id<ApplicationMenuItemDelegate> delegate;

@property (nonatomic, strong) HTAppInfo *app;

@end
