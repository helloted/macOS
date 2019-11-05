//
//  HTHandler.h
//  iSandBox
//
//  Created by iMac on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTHandler : NSObject

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString *)strFromJsonDict:(NSDictionary *)dict;
+ (NSString *)getIPAddress;

@end

NS_ASSUME_NONNULL_END
