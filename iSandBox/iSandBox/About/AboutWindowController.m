//
//  AboutWindowController.m
//  iSandBox
//
//  Created by iMac on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import "AboutWindowController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
//    [self.window setFrameOrigin:NSMakePoint(0, [NSScreen mainScreen].frame.size.height)];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(id)kCFBundleNameKey];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(id)kCFBundleVersionKey];
    self.appName = appName;
    self.version = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    
    self.desc = @"一键直达Simulator沙盒文件夹位置";
}
- (IBAction)linAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.helloted.com"]];
}

@end
