//
//  HTAppInfo.h
//  iSandBox
//
//  Created by Haozhicao on 2019/11/15.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN


@interface HTAppInfo : NSObject

/** 应用标识boudleId */
@property (nonatomic, copy, readonly) NSString *bundleId;
/** 应用名称 */
@property (nonatomic, copy, readonly) NSString *bundleDisplayName;
/** 版本build */
@property (nonatomic, copy, readonly) NSString *bundleVersion;
/** 版本version */
@property (nonatomic, copy, readonly) NSString *bundleShortVersion;
/** 应用图标 */
@property (nonatomic, getter=appIcon) NSImage *appIcon;
/** 设备UDID */
@property (nonatomic, copy, readonly) NSString *UDID;
/** 设备名称 */
@property (nonatomic, copy, readonly) NSString *deviceName;
/** 修改时间 */
@property (nonatomic, readonly) long long sortDateTime;

@property (nonatomic, strong)NSString  *osVersion;

/** 异步获取应用大小 */
- (void)getAppSize:(void (^)(long long appSize))complete;

- (instancetype)initWithURL:(NSURL *)url UDID:(NSString *)UDID deviceName:(NSString *)deviceName;

@end

NS_ASSUME_NONNULL_END
