//
//  CENTextUtilities.m
//  CenifyUtilities
//
//  Created by Gregory Sapienza on 1/27/16.
//  Copyright © 2016 Cenify. All rights reserved.
//

#import "CENTextUtilities.h"

@interface CENTextUtilities ()

@end

@implementation CENTextUtilities

+ (UIFont *)systemFont:(CGFloat)size {
    [CENTextUtilities loadMyCustomFont:_regularFontName];
    return [UIFont fontWithName:_regularFontName size:size];
}

+ (UIFont *)boldFont:(CGFloat)size {
    [CENTextUtilities loadMyCustomFont:_boldFontName];
    return [UIFont fontWithName:_boldFontName size:size];
}

+ (UIFont *)lightFont:(CGFloat)size {
    [CENTextUtilities loadMyCustomFont:_lightFontName];
    return [UIFont fontWithName:_lightFontName size:size];
}

+ (UIFont *)thinFont:(CGFloat)size {
    [CENTextUtilities loadMyCustomFont:_thinFontName];
    return [UIFont fontWithName:_thinFontName size:size];
}

+ (void)loadMyCustomFont:(NSString *)name {
    NSString *fontPath = [[CENTextUtilities frameworkBundle] pathForResource:name ofType:_fontExtension];
    NSData *inData = [NSData dataWithContentsOfFile:fontPath];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        //NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);
}

+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
        //NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"/Frameworks/CenifyKitObjectiveC.framework/"];
        frameworkBundle = [NSBundle bundleWithPath:mainBundlePath];
    });
    
    return frameworkBundle;
}

@end
