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




static NSString * const kRoute_vc_blue_userid   = @"/vc/blue/:userid/test";
static NSString * const kRoute_vc_userid        = @"/vc/red/:userid/ppp";

static NSString * const kRoute_redirection_test = @"/redirection/test";
static NSString * const kRoute_redirection_demo = @"/redirection/demo";
static NSString * const kRoute_redirection_blue = @"/red/blue/:userid";

static NSString * const kRoute_block_alert      = @"/block/alert";
static NSString * const kRoute_block_block      = @"/block/block";

@interface MKRouterHelper : NSObject

+ (instancetype)sharedInstance;

- (void)registerRoutes;

- (void)actionWithRoute:(NSString *)route
                  param:(id)param
                   onVC:(UIViewController *)currentVC
                  block:(MKBlock)block;
@end
