//
//  ViewController.m
//  WebPConverter
//
//  Created by Haozhicao on 2020/4/23.
//  Copyright © 2020 Haozhicao. All rights reserved.
//

#import "ViewController.h"
#import "WebPImage.h"
#import "NSProgressIndicator+ESSProgressIndicatorCategory.h"

@interface ViewController()

@property (nonatomic, strong)NSText     *showText;
@property (nonatomic, strong)NSImageView     *imageView;
@property (nonatomic, strong)NSProgressIndicator      *indicator;

@end

@implementation ViewController

- (void)loadView{
    self.view = [[NSView alloc]initWithFrame:CGRectMake(0, 0, 440, 50)];
    self.view.wantsLayer = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    _showText = [[NSText alloc]initWithFrame:CGRectMake(20, 0, 400, 40)];
    _showText.alignment = NSTextAlignmentCenter;
    _showText.editable = NO;
    [self.view addSubview:_showText];
    
//    [self logSome:@"/Users/haozhicao/Downloads/1667c35f570ad22a.webp"];
    
//    [self logSome:@"/Users/haozhicao/Downloads/ab.jpeg"];
    
    
    _imageView = [[NSImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_imageView];
    
    
    NSProgressIndicator  *indicator = [[NSProgressIndicator alloc]initWithFrame:CGRectMake(20, 5, 400, 10)];
    [self.view addSubview:indicator];
    
    indicator.indeterminate = NO;  // isIndeterminate 不确定的, 为false则可以精准显示进度
    indicator.minValue = 0;
    indicator.maxValue = 1000;
    indicator.style = NSProgressIndicatorStyleBar;
    [indicator sizeToFit];
    
    self.indicator = indicator;
    [self.indicator animateToDoubleValue:1000];
    
}


- (void)convertFrom:(NSString *)str{
    _showText.string = str;
    NSString * filePath = str;
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
    
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    imageRect.size.height = CGImageGetHeight(imageRef);
    imageRect.size.width = CGImageGetWidth(imageRef);
    
    [fileManager createFileAtPath:address contents:nil attributes:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *pathOf3x = [NSString stringWithFormat:@"%@/%@.png",address,fileName];
       saveImagepng(imageRef, pathOf3x);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSApp terminate:self];
        });
    });
    
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
