//
//  ToastNotificationManager.h
//  BakingKit
//
//  Created by Gregory Sapienza on 3/12/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CRToast/CRToast.h>

@interface ToastNotificationManager : NSObject

/**
 *  Posts Standard Toast Notification to Top of Screen
 *
 *  @param text            Text to display
 *  @param color           Color of notification
 *  @param image           Left side image
 *  @param completionBlock Block to execute when toast animation completed
 */
+ (void)postToastNotification:(NSString *)text color:(UIColor *)color image:(UIImage *)image completionBlock:(void (^)()) completionBlock;

@end
