//
//  AppDelegate.m
//  WebPConverter
//
//  Created by Haozhicao on 2020/4/23.
//  Copyright © 2020 Haozhicao. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "WebPImage.h"
#import "HTWindowsController.h"

@interface AppDelegate ()

@property(nonatomic,strong) NSWindow *window1;

@end

@implementation AppDelegate

-(BOOL)application:(NSApplication *)theApplication openFile:(NSString *)fileName{
    [self convertWithFile:fileName];
    return YES;
}

- (void)convertWithFile:(NSString *)filePath{
    NSString * exestr = [filePath lastPathComponent];
    NSString *fileName = [exestr stringByDeletingPathExtension];
    NSString * type = [filePath pathExtension];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData * imageData = [fileManager contentsAtPath:filePath];
    CGImageRef imageRef = nil;
    NSSize imageSize = NSMakeSize(0, 0);
    
    if (([type isEqualToString:@"png"]) || ([type isEqualToString:@"jpg"]) || ([type isEqualToString:@"jpeg"]) ) {
        NSImage * pendingImage = [[NSImage alloc]initWithData:imageData];
        imageSize = pendingImage.size;
        imageRef = createCGImageRefFromNSImage(pendingImage);
    }

    if (([type isEqualToString:@"webp"])) {
        imageRef = CreateImageForData(imageData);
        imageSize.height = CGImageGetHeight(imageRef);
        imageSize.width = CGImageGetWidth(imageRef);
    }
    
    if (imageRef == NULL) {
        return;
    }

    NSArray<NSString *> * arr = [filePath componentsSeparatedByString:@"/"];
    NSMutableString * address = [[NSMutableString alloc]init];
    for (int i = 0 ; i < arr.count - 1; i++) {
        [address appendFormat:@"%@/",arr[i]];
    }
    
    [fileManager createFileAtPath:address contents:nil attributes:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *pathOf3x = [NSString stringWithFormat:@"%@/%@.png",address,fileName];
       saveImagepng(imageRef, pathOf3x);
    });
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    HTWindowsController *windowController = [[HTWindowsController alloc]init];
    [windowController showWindow:nil];
    [windowController.window makeKeyAndOrderFront:nil];
//    NSApplication.sharedApplication.mainWindow = windowController.window;
//    window.titlebarAppearsTransparent= YES;
//    window.titleVisibility=NSWindowTitleHidden;
//    [window makeKeyAndOrderFront:self];
//    [window center];
//
//    ViewController *vc = (ViewController *)NSApplication.sharedApplication.mainWindow.windowController.contentViewController;


}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
