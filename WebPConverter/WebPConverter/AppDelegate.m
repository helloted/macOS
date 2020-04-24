//
//  AppDelegate.m
//  WebPConverter
//
//  Created by Haozhicao on 2020/4/23.
//  Copyright © 2020 Haozhicao. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(NSApplication *)theApplication openFile:(NSString *)fileName{
    ViewController *vc = (ViewController *)NSApplication.sharedApplication.mainWindow.windowController.contentViewController;
    [vc logSome:fileName];
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
