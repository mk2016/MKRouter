//
//  MKRouterHelper.h
//  MKRouterDemo
//
//  Created by xmk on 2017/6/30.
//  Copyright © 2017年 mk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MKConst.h"


static NSString * const kRoute_vc_blue          = @"/vc/blue";
static NSString * const kRoute_vc_red           = @"/vc/red";
static NSString * const kRoute_vc_green         = @"/sb/Main/sbid_MKSBGreen_VC";
static NSString * const kRoute_vc_gray          = @"/sb/Main/sbid_MKSBGray_VC";

static NSString * const kRoute_vc_path_blue     = @"/vc/blue/:userid";
static NSString * const kRoute_vc_path_red      = @"/vc/red/:userid/:userName";
static NSString * const kRoute_vc_path_green    = @"/sb/Main/sbid_MKSBGreen_VC/:userid/gogogo";
static NSString * const kRoute_vc_path_gray     = @"/sb/Main/sbid_MKSBGray_VC/:userid/first/:username/second";



static NSString * const kRoute_block_alert      = @"/block/alert/:userid";
static NSString * const kRoute_block_nav        = @"/block/present/nav";
static NSString * const kRoute_block_tel        = @"/block/call/tel/:number";



static NSString * const kRoute_redirection_blue = @"/redirection/to/vc/blueeee";
static NSString * const kRoute_redirection_alert = @"/redirection/block/alert/:userid/aaa";




@interface MKRouterHelper : NSObject

+ (instancetype)sharedInstance;

- (void)registerRoutes;

- (void)actionWithRoute:(NSString *)route
                  param:(id)param
                   onVC:(UIViewController *)currentVC
                  block:(MKBlock)block;
@end
