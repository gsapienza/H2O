//
//  CENTextUtilities.h
//  CenifyUtilities
//
//  Created by Gregory Sapienza on 1/27/16.
//  Copyright © 2016 Cenify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface CENTextUtilities : NSObject

+ (UIFont *)lightFont:(CGFloat)size;
+ (UIFont *)systemFont:(CGFloat)size;
+ (UIFont *)boldFont:(CGFloat)size;
+ (UIFont *)thinFont:(CGFloat)size;

@end

static NSString *const _lightFontName = @"Bariol-Light";
static NSString *const _thinFontName = @"Bariol-Thin";
static NSString *const _regularFontName = @"Bariol-Regular";
static NSString *const _boldFontName = @"Bariol-Bold";

static NSString *const _fontExtension = @"otf";