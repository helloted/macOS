//
//  ViewController.m
//  WebPConverter
//
//  Created by Haozhicao on 2020/4/23.
//  Copyright © 2020 Haozhicao. All rights reserved.
//

#import "ViewController.h"
#import "WebPImage.h"

@interface ViewController()

@property (nonatomic, strong)NSText     *showText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showText = [[NSText alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    [self.view addSubview:_showText];
    
    [self logSome:@"/Users/haozhicao/Downloads/1667c35f570ad22a.webp"];

}


- (void)logSome:(NSString *)str{
    _showText.string = str;
    NSString * filePath = str;
    NSString * exestr = [filePath lastPathComponent];
    NSString *fileName = [exestr stringByDeletingPathExtension];
    NSString * type = [filePath pathExtension];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData * imageData = [fileManager contentsAtPath:filePath];
    CGImageRef imageRef3x = nil;
    NSSize imageSize = NSMakeSize(0, 0);

    if (([type isEqualToString:@"webp"])) {
        imageRef3x = CreateImageForData(imageData);
        imageSize.height = CGImageGetHeight(imageRef3x);
        imageSize.width = CGImageGetWidth(imageRef3x);
    }

    NSArray<NSString *> * arr = [filePath componentsSeparatedByString:@"/"];
    NSMutableString * address = [[NSMutableString alloc]init];
    for (int i = 0 ; i < arr.count - 1; i++) {
        [address appendFormat:@"%@/",arr[i]];
    }
    
    [fileManager createFileAtPath:address contents:nil attributes:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *pathOf3x = [NSString stringWithFormat:@"%@/%@.png",address,fileName];
       saveImagePngToFile(imageRef3x, pathOf3x);
    });
}

BOOL saveImagePngToFile(CGImageRef imageRef, NSString *strpath)
{
    NSString *finalPath = [NSString stringWithString:strpath];
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)finalPath,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, CFSTR("public.png"), 1,NULL);
    assert(dest);
    CGImageDestinationAddImage(dest, imageRef, NULL);
    assert(dest);
    if (dest == NULL) {
        NSLog(@"CGImageDestinationCreateWithURL failed");
    }
    //NSLog(@"%@", dest);
    assert(CGImageDestinationFinalize(dest));
    
    //这三句话用来释放对象
    CFRelease(dest);
    //CGImageRelease(imageRef);
    CFRelease(url);
    return YES;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end