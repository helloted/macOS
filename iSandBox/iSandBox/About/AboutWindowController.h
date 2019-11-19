//
//  AboutWindowController.h
//  iSandBox
//
//  Created by iMac on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController
// Properties are used by bindings
@property (copy) NSString *appName;
@property (copy) NSString *version;
@property (copy) NSString *desc;
@end
