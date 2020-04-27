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

@end

@implementation AppDelegate

-(BOOL)application:(NSApplication *)theApplication openFile:(NSString *)fileName{
    [self convertWithFile:fileName];
    ViewController *vc = (ViewController *)self.mainWindow.contentViewController;
    [vc actionFromClicked:fileName];
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
    [self.mainWindow center];
    [self.mainWindow orderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(NSWindow *)mainWindow{
    if (!_mainWindow) {
        NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable ;
        _mainWindow = [[NSWindow alloc]initWithContentRect:CGRectMake(0, 0, 200, 300) styleMask:style backing:NSBackingStoreBuffered defer:YES];
        _mainWindow.contentViewController = [[ViewController alloc]init];
    }
    return _mainWindow;
}

@end
