//
//  UDPEchoClient.h
//  ControMac
//
//  Created by iMac on 2019/11/5.
//  Copyright © 2019 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UDPEchoClient : NSObject

- (BOOL) sendData:(const char *)msg;

@end

NS_ASSUME_NONNULL_END
