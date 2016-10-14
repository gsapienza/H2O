//
//  ToastNotificationManager.m
//  BakingKit
//
//  Created by Gregory Sapienza on 3/12/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

#import "ToastNotificationManager.h"
#import "H2O-Swift.h"

@implementation ToastNotificationManager

+ (void)postToastNotification:(NSString *)text color:(UIColor *)color image:(UIImage *)image completionBlock:(void (^)())completionBlock {
    NSDictionary *options = @{
                              kCRToastTextKey : text,
                              kCRToastBackgroundColorKey : color,
                              kCRToastFontKey : [StandardFonts regularFontWithSize:20],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationInTypeKey :@(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey :@(CRToastAnimationTypeGravity),
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastAnimationInTimeIntervalKey : @0.2,
                              kCRToastAnimationOutTimeIntervalKey : @0.2,
                              kCRToastTextAlignmentKey :@(NSTextAlignmentCenter),
                              kCRToastTimeIntervalKey : @1.0,
                              };
    
    NSMutableDictionary *mutableOptions = options.mutableCopy;
    if (image != nil) {
        [mutableOptions addEntriesFromDictionary:@{
                                                   kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                                                   kCRToastImageKey :image,
                                                   kCRToastImageContentModeKey :@(UIViewContentModeCenter),
                                                   kCRToastImageAlignmentKey :@(CRToastAccessoryViewAlignmentLeft)
                                                   
                                                   }];
    }
         
    [CRToastManager showNotificationWithOptions:mutableOptions completionBlock:^{
        completionBlock();
    }];
}

@end
