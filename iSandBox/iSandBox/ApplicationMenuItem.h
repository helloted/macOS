//
//  ApplicationMenuItem.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/10.
//  Copyright © 2016年 GZMiracle. All rights reserved.
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
