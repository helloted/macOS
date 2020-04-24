//
//  WebPImage.m
//  WebP
//
//  Created by Dmitry Chestnykh on 5/3/11.
//  Copyright 2011 Coding Robots. All rights reserved.
//

#import "WebPImage.h"
#import "webp/decode.h"

static void FreeImageData(void *info, const void *data, size_t size) {
    free((void*)data);
}

CGImageRef CreateImageForData(NSData * fileData)
{

     WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config)) {
         NSLog(@"(WebPInitDecoderConfig) cannot get WebP image data for");
        return NULL;
    }

    if (WebPGetFeatures([fileData bytes], [fileData length], &config.input) != VP8_STATUS_OK) {
        NSLog(@"(WebPGetFeatures) cannot get WebP image data for");
        return NULL;
    }

    config.output.colorspace = MODE_rgbA; // premultiplied alpha
    config.options.use_threads = 1;

    if (WebPDecode([fileData bytes], [fileData length], &config) != VP8_STATUS_OK) {
        NSLog(@"(WebPDecode) cannot get WebP image data");
        return NULL;
    }
    
    int width = config.input.width;
    int height = config.input.height;
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba,
                                 config.output.u.RGBA.size, FreeImageData);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef =
    CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo,
                  provider, NULL, NO, renderingIntent);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return imageRef;
}

CGImageRef createCGImageRefFromNSImage(NSImage* image)
{
    NSData *imageData;
    CGImageRef imageRef;
    @try {
        imageData = [image TIFFRepresentation];
        if (imageData) {
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
            NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     (id)kCFBooleanFalse, (id)kCGImageSourceShouldCache,
                                     (id)kCFBooleanTrue, (id)kCGImageSourceShouldAllowFloat,
                                     nil];
            
            //要用这个带option的 kCGImageSourceShouldCache指出不需要系统做cache操作 默认是会做的
            imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)options);
            CFRelease(imageSource);
            return imageRef;
        }else{
            return NULL;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return NULL;
}

BOOL saveImagepng(CGImageRef imageRef, NSString *strpath)
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
