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
#import "MKSBGreen_VC.h"
#import "MKSBGray_VC.h"



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
    [[MKRouter sharedInstance] map:kRoute_vc_red toControllerClass:[MKRed_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_green toControllerClass:[MKSBGreen_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_gray toControllerClass:[MKSBGray_VC class]];
    
    [[MKRouter sharedInstance] map:kRoute_vc_path_blue toControllerClass:[MKBlue_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_path_red toControllerClass:[MKRed_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_path_green toControllerClass:[MKSBGreen_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_path_gray toControllerClass:[MKSBGray_VC class]];
    

    [[MKRouter sharedInstance] map:kRoute_block_alert toBlock:^id(id params) {
        NSLog(@"params: %@", params);
        NSString *message = @"message";
        if ([params objectForKey:@"userid"]) {
            message = [NSString stringWithFormat:@"userid : %@", [params objectForKey:@"userid"]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        MKBlock customBlock = [params objectForKey:kMKRouteCustomBlockKey];
        MKBlockExec(customBlock, @"block success");
        return params;
    }];

    [[MKRouter sharedInstance] map:kRoute_block_nav toBlock:^id(id params) {
        NSLog(@"params: %@", params);
        MKBlock customBlock = [params objectForKey:kMKRouteCustomBlockKey];
        [self presentRedVCWitBlock:^(id result) {
            MKBlockExec(customBlock, result);
        }];
        return params;
    }];
    
    [[MKRouter sharedInstance] map:kRoute_block_tel toBlock:^id(id params) {
        NSLog(@"params: %@", params);
        if ([params objectForKey:@"number"]) {
            NSString *phone = [params objectForKey:@"number"];
            NSString *str = [NSString stringWithFormat:@"tel://%@", phone];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
        MKBlock customBlock = [params objectForKey:kMKRouteCustomBlockKey];
        MKBlockExec(customBlock, params);
        return params;
    }];
    
    [[MKRouter sharedInstance] map:kRoute_redirection_blue toRedirection:kRoute_vc_blue];
    [[MKRouter sharedInstance] map:kRoute_redirection_alert toRedirection:kRoute_block_alert];
    
}


- (void)presentRedVCWitBlock:(MKBlock)block{
    MKRed_VC *vc = [[MKRed_VC alloc] init];
    vc.present = YES;
    vc.mk_block = block;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController *currentVC = [MKUITools getCurrentViewController];
    [currentVC presentViewController:nav animated:YES completion:nil];
}



- (void)actionWithRoute:(NSString *)route param:(id)param onVC:(UIViewController *)currentVC block:(MKBlock)block{
    BOOL transitionMode = route.mk_transitionModePresent;
    if (route == nil || route.length == 0) {
        return;
    }
    if (param) {
        route = [self route:route appendParam:param];
    }
    
    MKRouteType type = [[MKRouter sharedInstance] canRoute:route];
    if (type == MKRouteType_none) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此版本不支持该功能，请升级到最新版本！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    id ret = nil;
    if (type == MKRouteType_redirection){
        ret = [[MKRouter sharedInstance] matchRedirection:route];
    }else if (type == MKRouteType_viewController) {
        ret = [[MKRouter sharedInstance] matchController:route];
        ((UIViewController *)ret).mk_block = block;
    }else if (type == MKRouteType_block){
        ret = [[MKRouter sharedInstance] matchBlock:route];
    }
    
    if (ret) {
        if ([ret isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)ret;
            vc.mk_block = block;
            if (transitionMode){
                [currentVC presentViewController:vc animated:YES completion:nil];
                NSLog(@"transition mode present");
            }else{
                [currentVC.navigationController pushViewController:vc animated:YES];
            }
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
    if (route && param) {
        NSDictionary *paramDic = [NSDictionary mk_dictionaryWithJson:param];
        NSAssert(paramDic, @"param 转 dictionary error");
        
        NSRange range = [route rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            NSString *routeParamStr = [route substringFromIndex:range.location+range.length];
            NSArray *ary = [routeParamStr componentsSeparatedByString:@"="];
            if (ary && ary.count == 2) {
                NSString *routeParamValue = [ary.lastObject mk_stringByURLDecode];
                NSDictionary *dic = [routeParamValue mk_jsonString2Dictionary];
                if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [tempDic addEntriesFromDictionary:paramDic];
                    NSString *encodeStr = [[tempDic mj_JSONString] mk_stringByURLEncode];
                    if (encodeStr) {
                        route = [NSString stringWithFormat:@"%@?param=%@", [route substringToIndex:range.location], encodeStr];
                    }
                }
            }
        }else{
            NSString *encodeStr = [[param mj_JSONString] mk_stringByURLEncode];
            if (encodeStr) {
                NSString *paramStr = [NSString stringWithFormat:@"?param=%@",encodeStr];
                route = [route stringByAppendingString:paramStr];
            }
        }
    }
    return route;
}

@end
