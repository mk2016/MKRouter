//
//  MKRouterHelper.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/30.
//  Copyright © 2017年 mk. All rights reserved.
//

#import "MKRouterHelper.h"
#import "MKRouter.h"
#import "MKConst.h"
#import "MKRed_VC.h"
#import "MKBlue_VC.h"


#define MKBlockExec(block, ...) if (block) { block(__VA_ARGS__); };

@implementation MKRouterHelper
static const NSString * kMKRouteCustomBlockKey = @"customBlock";

static MKRouterHelper *sharedInstance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}


- (void)registerRoutes{
    [[MKRouter sharedInstance] map:kRoute_vc_blue toControllerClass:[MKBlue_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_blue_userid toControllerClass:[MKBlue_VC class]];

    [[MKRouter sharedInstance] map:kRoute_vc_red toControllerClass:[MKRed_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_userid toControllerClass:[MKRed_VC class]];

    
    [[MKRouter sharedInstance] map:kRoute_redirection_test toRedirection:kRoute_vc_red];
    [[MKRouter sharedInstance] map:kRoute_redirection_demo toRedirection:kRoute_redirection_test];
    [[MKRouter sharedInstance] map:kRoute_redirection_blue toRedirection:kRoute_vc_blue_userid];
    
    [[MKRouter sharedInstance] map:kRoute_block_alert toBlock:^id(id params) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:[params description] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        return params;
    }];
    
    [[MKRouter sharedInstance] map:kRoute_block_block toBlock:^id(id params) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:[params description] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        MKBlock customBlock = [params objectForKey:kMKRouteCustomBlockKey];
        MKBlockExec(customBlock, @"block success");
        return params;
    }];
}



- (void)actionWithRoute:(NSString *)route param:(id)param onVC:(UIViewController *)currentVC block:(MKBlock)block{
    if (route == nil || route.length == 0) {
        return;
    }
    if (param) {
        route = [self route:route appendParam:param];
    }
    
    MKRouteType type = [[MKRouter sharedInstance] canRoute:route];
    if (type == MKRouteType_none) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此版本不支持该功能，请升级到最新版本！" delegate:nil cancelButtonTitle:@"狠心拒绝" otherButtonTitles:@"马上更新", nil];
        [alert show];
        return;
    }
    
    id ret = nil;
    if (type == MKRouteType_redirection){
        ret = [[MKRouter sharedInstance] matchRedirection:route];
    }else if (type == MKRouteType_viewController) {
        ret = [[MKRouter sharedInstance] matchController:route];
    }else if (type == MKRouteType_block){
        ret = [[MKRouter sharedInstance] matchBlock:route];
    }
    
    if (ret) {
        if ([ret isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)ret;
            vc.mk_block = block;
            if (param[@"transitionMode"]) {
                if ([param[@"transitionMode"] isEqualToString:@"present"]) {
                    [currentVC presentViewController:vc animated:YES completion:nil];
                }
            }
            [currentVC.navigationController pushViewController:vc animated:YES];
        }else{
            MKRouterBlock routeBlock = ret;
            if (block) {
                NSDictionary *dic = @{kMKRouteCustomBlockKey: [block copy]};
                MKBlockExec(routeBlock, dic);
            }else{
                MKBlockExec(routeBlock, nil);
            }
        }
    }
}


- (NSString *)route:(NSString *)route appendParam:(id)param{
    //    NSDictionary *params = [[MKRouter sharedInstance] paramsInRoute:route];
    if (route && param) {
        NSString *encodeStr = [[param mj_JSONString] mk_stringByURLEncode];
        if (encodeStr) {
            NSString *paramStr = [NSString stringWithFormat:@"?param=%@",encodeStr];
            route = [route stringByAppendingString:paramStr];
        }
    }
    return route;
}

@end
