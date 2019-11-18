//
//  HTDevice.m
//  iSandBox
//
//  Created by Haozhicao on 2019/11/15.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import "HTDevice.h"
#import "URLContent.h"

@interface HTDevice ()

@property (nonatomic, strong) NSMutableArray<HTAppInfo *> *appInfoList;

@end

@implementation HTDevice

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        _appInfoList = [NSMutableArray array];
        
        NSString *state = dictionary[@"state"];
        if ([state isEqualToString:@"Booting"]) {
            _state = DeviceState_Booting;
        } else if ([state isEqualToString:@"Booted"]) {
            _state = DeviceState_Booted;
        } else {
            _state = DeviceState_Shutdown;
        }
        
        _isUnavailable = [dictionary[@"availability"] containsString:@"unavailable"];
        _name = dictionary[@"name"];
        _UDID = dictionary[@"udid"];
        
        /** 获取设备下的应用列表 */
        NSURL *applicationForDevicePath = applicationForDeviceURL(self.UDID);
        NSArray *dirEnumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:applicationForDevicePath includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLContentModificationDateKey] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        for (NSURL *fileURL in dirEnumerator) {
            id isDirectoryObj;
            if ([fileURL getResourceValue:&isDirectoryObj
                                   forKey:NSURLIsDirectoryKey
                                    error:NULL])
            {
                if ([isDirectoryObj boolValue]) {
                    HTAppInfo *app = [[HTAppInfo alloc] initWithURL:fileURL UDID:self.UDID deviceName:self.name];
                    if (app) {
                        [_appInfoList addObject:app];
                    }
                }
            }
        }
        
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary osVersion:(nonnull NSString *)osVersion{
    self = [super init];
    if (self) {
        _osVersion = osVersion;
        self = [self initWithDictionary:dictionary];
    }
    return self;
}

- (NSImage *)deviceIcon
{
    NSString *imageName = @"";
    switch (_state) {
        case DeviceState_Booting:
            imageName = [self.name containsString:@"iPad"] ? @"iPad-booting" : @"iPhone-booting";
            break;
        case DeviceState_Booted:
            imageName = [self.name containsString:@"iPad"] ? @"iPad-booted" : @"iPhone-booted";
            break;
        default:
            imageName = [self.name containsString:@"iPad"] ? @"iPad" : @"iPhone";
            break;
    }
    return [NSImage imageNamed:imageName];
}

- (NSArray<HTAppInfo *> *)appList
{
    return [self.appInfoList copy];
}

@end

