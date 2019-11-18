//
//  HTDevice.h
//  iSandBox
//
//  Created by Haozhicao on 2019/11/15.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTAppInfo.h"

typedef NS_ENUM(NSUInteger, DeviceState) {
    DeviceState_Shutdown,
    DeviceState_Booted,
    DeviceState_Booting,
};

NS_ASSUME_NONNULL_BEGIN

@interface HTDevice : NSObject

/** 应用列表 */
@property (nonatomic, readonly) NSArray<HTAppInfo *> *appList;
/** 是否正在使用 */
@property (nonatomic, readonly) DeviceState state;
/** 是否不可使用 */
@property (nonatomic, readonly) BOOL isUnavailable;
/** 设备名称 */
@property (nonatomic, copy, readonly) NSString *name;
/** 图标 */
@property (nonatomic, getter=deviceIcon) NSImage *deviceIcon;
/** 设备标识 */
@property (nonatomic, copy, readonly) NSString *UDID;

@property (nonatomic, strong) NSString  *osVersion;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary osVersion:(NSString *)osVersion;

@end

NS_ASSUME_NONNULL_END
