//
//  MKUITools.h
//  MKToolsKit
//
//  Created by xmk on 16/9/23.
//  Copyright © 2016年 mk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MKUITools : NSObject

#pragma mark - ***** top View ******
+ (UIView *)getTopView;

#pragma mark - ***** top window *****
+ (UIWindow *)getCurrentWindow;
+ (UIWindow *)getCurrentWindowByLevel:(CGFloat)windowLevel;

#pragma mark - ***** current ViewController ******
+ (UIViewController *)getCurrentViewController;
+ (UIViewController *)getCurrentViewControllerIsIncludePresentedVC:(BOOL)isIncludePVC;
+ (UIViewController *)getCurrentViewControllerWithWindowLevel:(CGFloat)windowLevel includePresentedVC:(BOOL)isIncludePVC;
+ (UIViewController *)getPresentedViewController;



@end
