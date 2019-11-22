//
//  ApplicationMenuItem.m
//  iSandBox
//
//  Created by iMac on 2019/11/4.
//  Copyright © 2019 Haozhicao. All rights reserved.
//

#import "ApplicationMenuItem.h"
#import "HTAppInfo.h"

//#import "SimulatorManager.h"

@interface ApplicationMenuItem () <NSMenuDelegate>


@property (nonatomic, strong) NSString *detailText;

/** 是否需要更新信息 */
@property (nonatomic, assign) BOOL isNeedUpdateAPPInfo;

@end

@implementation ApplicationMenuItem

- (instancetype)initWithApp:(HTAppInfo *)app
{
    return [self initWithApp:app withDetailText:nil];
}

- (instancetype)initWithApp:(HTAppInfo *)app withDetailText:(NSString *)detailText
{
    self = [super initWithTitle:@"" action:Nil keyEquivalent:@""];
    if (self) {
        _app = app;
        _detailText = detailText;
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    NSFont *font = [NSFont systemFontOfSize:14.f];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@ (%@)", self.app.bundleDisplayName,self.app.bundleShortVersion] attributes:@{NSFontAttributeName:font}];
    if (self.detailText.length) {
        font = [NSFont systemFontOfSize:11.f];

        NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n  %@-%@", self.detailText,self.app.osVersion] attributes:@{NSFontAttributeName:font}];
        [title appendAttributedString:detail];
    }
    self.attributedTitle = title;
    
    self.image = [self imageWithCornerRadius:self.app.appIcon :6 size:NSMakeSize(30, 30)] ?: [NSImage imageNamed:@"DefaultAppIcon"];
}


- (NSImage *)imageWithCornerRadius:(NSImage *)image :(CGFloat)cornerRadius size:(NSSize)size
{
    if (image.isValid == NO) return nil;
    NSImage *newImage = [[NSImage alloc] initWithSize:size];
    [newImage lockFocus];
    image.size = size;
    [NSGraphicsContext currentContext].imageInterpolation = NSImageInterpolationHigh;
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:(NSRect){NSZeroPoint, size} xRadius:cornerRadius yRadius:cornerRadius];
    [bezierPath addClip];
    [image drawAtPoint:NSZeroPoint fromRect:(NSRect){NSZeroPoint, size} operation:NSCompositingOperationCopy fraction:1.f];
    [NSGraphicsContext restoreGraphicsState];
    
    [newImage unlockFocus];
    
    return newImage;
}

@end
