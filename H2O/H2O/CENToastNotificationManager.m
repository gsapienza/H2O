//
//  CENToastNotificationManager.m
//  CenifyKit
//
//  Created by Gregory Sapienza on 3/12/16.
//  Copyright © 2016 Cenify. All rights reserved.
//

#import "CENToastNotificationManager.h"
#import "H2O-Swift.h"

@implementation CENToastNotificationManager

+ (void)postToastNotification:(NSString *)text color:(UIColor *)color image:(UIImage *)image completionBlock:(void (^)())completionBlock {
    NSDictionary *options = @{
                              kCRToastTextKey : text,
                              kCRToastBackgroundColorKey : color,
                              kCRToastFontKey : [StandardFonts regularFont:20],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastAnimationInTimeIntervalKey : @0.5,
                              kCRToastAnimationOutTimeIntervalKey : @0.5,
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
