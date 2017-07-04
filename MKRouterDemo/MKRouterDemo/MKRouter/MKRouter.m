//  The MIT License (MIT)
//
//  Copyright (c) 2014 LIGHT lightory@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//================================================================================
//  MKRouter.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/28.
//  Copyright © 2017年 mk. All rights reserved.
//

#import "MKRouter.h"
#import <objc/runtime.h>

@interface MKRouter()
@property (nonatomic, strong) NSMutableDictionary *routes;
@end

static NSString * kMKRouterKeyVCClass       = @"controllerClass";
static NSString * kMKRouterKeyPath          = @"routePath";
static NSString * kMKRouterKeyRoute         = @"route";
static NSString * kMKRouterKeyOrginRoute    = @"orginRoute";
static NSString * kMKRouterKeyParam         = @"param";

static NSString * kMKRouterKeyRedirection   = @"redirectionRoute";
static NSString * kMKRouterKeyBlock         = @"block";
static NSString * kMKRouterKeyEnd           = @"_";

@implementation MKRouter

static MKRouter *sharedInstance = nil;
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


#pragma mark - ***** ControllerClass *****
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    subRoutes[kMKRouterKeyEnd] = controllerClass;
}

- (UIViewController *)matchController:(NSString *)route{
    return [self matchController:route orginRoute:nil];
}

#pragma mark - ***** block *****
- (void)map:(NSString *)route toBlock:(MKRouterBlock)block{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    subRoutes[kMKRouterKeyEnd] = [block copy];
}

- (MKRouterBlock)matchBlock:(NSString *)route{
    return [self matchBlock:route orginRoute:nil];
}

- (id)callBlock:(NSString *)route{
    NSDictionary *params = [self paramsInRoute:route];
    MKRouterBlock routerBlock = [params[kMKRouterKeyBlock] copy];
    
    if (routerBlock) {
        return routerBlock([params copy]);
    }
    return nil;
}

#pragma mark - ***** Redirection *****
- (void)map:(NSString *)route toRedirection:(NSString *)redirection{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    subRoutes[kMKRouterKeyEnd] = redirection;
}

- (id)matchRedirection:(NSString *)route{
    NSString *finallyRoute = nil;
    MKRouteType type = [self redirectionFinallyType:route finallyRoute:&finallyRoute];
    if (type == MKRouteType_block) {
        return [self matchBlock:route orginRoute:route];
    }else if (type == MKRouteType_viewController){
        return [self matchController:finallyRoute orginRoute:route];
    }
    return nil;
}

- (MKRouteType)redirectionFinallyType:(NSString *)route finallyRoute:(NSString **)finallyRoute{
    MKRouteType type = [self canRoute:route];
    if (type == MKRouteType_none || type == MKRouteType_block || type == MKRouteType_viewController) {
        return type;
    }else if (type == MKRouteType_redirection){
        NSString *nextRoute = [self matchNextRouteWith:route];
        *finallyRoute = nextRoute;
        return [self redirectionFinallyType:nextRoute finallyRoute:finallyRoute];
    }
    return MKRouteType_none;
}

#pragma mark - ***** other *****
- (MKRouteType)canRoute:(NSString *)route{
    NSDictionary *params = [self paramsInRoute:route];
    if (params[kMKRouterKeyVCClass]) {
        return MKRouteType_viewController;
    }
    if (params[kMKRouterKeyBlock]) {
        return MKRouteType_block;
    }
    if (params[kMKRouterKeyRedirection]) {
        return MKRouteType_redirection;
    }
    return MKRouteType_none;
}



#pragma mark - ========= private method =========
#pragma mark - ***** register *****
/** 以 NSDictionary 层级 保持 router */
- (NSMutableDictionary *)subRoutesToRoute:(NSString *)route{
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    NSInteger index = 0;
    NSMutableDictionary *subRoutes = self.routes;
    
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = @{}.mutableCopy;
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    return subRoutes;
}

#pragma mark - ***** match *****
/** view controller */
- (UIViewController *)matchController:(NSString *)route orginRoute:(NSString *)orginRoute{
    NSMutableDictionary *params = [self paramsInRoute:route].mutableCopy;
    
    if (orginRoute && orginRoute.length > 0) {
        [params setValue:orginRoute forKey:kMKRouterKeyOrginRoute];
    }
    
    Class controllerClass = params[kMKRouterKeyVCClass];
    
    UIViewController *viewController = nil;
    
    NSArray *pathAry = [params[kMKRouterKeyPath] componentsSeparatedByString:@"/"];
    if (pathAry && pathAry.count >= 3 && [pathAry.firstObject isEqualToString:@"sb"]) {
        viewController = [[UIStoryboard storyboardWithName:pathAry[1] bundle:nil] instantiateViewControllerWithIdentifier:pathAry[2]];
    }else{
        viewController = [[controllerClass alloc] init];
    }
    
    if ([viewController respondsToSelector:@selector(setMk_routeParams:)]) {
        NSString *codeStr = params[kMKRouterKeyParam];
        NSRange range = [codeStr rangeOfString:@"%"];
        if (codeStr && range.location != NSNotFound) {
            NSString *json = [codeStr mk_stringByURLDecode];
            
            NSMutableDictionary *tempDic = [params mutableCopy];
            [tempDic setValue:json forKey:kMKRouterKeyParam];
            params = [tempDic mutableCopy];
        }
        [viewController performSelector:@selector(setMk_routeParams:) withObject:[params copy]];
    }
    return viewController;
}

/** block */
- (MKRouterBlock)matchBlock:(NSString *)route orginRoute:(NSString *)orginRoute{
    NSMutableDictionary *params = [self paramsInRoute:route].mutableCopy;
    if (!params){
        return nil;
    }
    if (orginRoute && orginRoute.length > 0) {
        [params setValue:orginRoute forKey:kMKRouterKeyOrginRoute];
    }
    
    MKRouterBlock routerBlock = [params[kMKRouterKeyBlock] copy];
    MKRouterBlock returnBlock = ^id(NSDictionary *aParams) {
        if (routerBlock) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
            [dic addEntriesFromDictionary:aParams];
            return routerBlock([NSDictionary dictionaryWithDictionary:dic].copy);
        }
        return nil;
    };
    return [returnBlock copy];
}


/** redirection */
- (NSString *)matchNextRouteWith:(NSString *)route{
    NSDictionary *params = [self paramsInRoute:route];
    if (!params) {
        return nil;
    }
    NSString *redirectionRoute = params[kMKRouterKeyRedirection];
    if (redirectionRoute) {
        NSMutableString *finallyRoute = [NSMutableString stringWithString:redirectionRoute];
        NSArray *paths = [finallyRoute componentsSeparatedByString:@"/"];
        for (NSString *str in paths) {
            if ([str hasPrefix:@":"]) {
                if ([params valueForKey:[str substringFromIndex:1]]) {
                    NSRange range = [finallyRoute rangeOfString:str];
                    if (range.location != NSNotFound) {
                        [finallyRoute replaceCharactersInRange:range withString:[params valueForKey:[str substringFromIndex:1]]];
                    }
                }
            }
        }
        if (route) {
            NSRange range = [route rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                NSMutableString *orginRoute = [NSMutableString stringWithString:route];
                [orginRoute replaceCharactersInRange:NSMakeRange(0, range.location) withString:finallyRoute];
                return orginRoute;
            }
        }
        return finallyRoute ;
    }
    
    return nil;
}


#pragma mark - ***** 返回 route 字典 *****
- (NSDictionary *)paramsInRoute:(NSString *)route{
    if (!route) {
        return nil;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kMKRouterKeyRoute] = [MKRouter filterAppUrlScheme:route];
    
    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromRoute:params[kMKRouterKeyRoute]];
    params[kMKRouterKeyPath] = [pathComponents componentsJoinedByString:@"/"];
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        NSArray *subRoutesKeys = subRoutes.allKeys;
        for (NSString *key in subRoutesKeys) {
            if ([subRoutesKeys containsObject:pathComponent]) {
                found = YES;
                subRoutes = subRoutes[pathComponent];
                break;
            }else if ([key hasPrefix:@":"]){
                found = YES;
                subRoutes = subRoutes[key];
                params[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        if (!found) {
            return nil;
        }
    }
    // Extract Params From Query.
    NSRange firstRange = [route rangeOfString:@"?"];
    if (firstRange.location != NSNotFound && route.length > firstRange.location + firstRange.length) {
        NSString *paramsString = [route substringFromIndex:firstRange.location + firstRange.length];
        NSArray *paramStringArr = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *paramString in paramStringArr) {
            NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count == 2) {
                NSString *key = [paramArr objectAtIndex:0];
                NSString *value = [[paramArr objectAtIndex:1] mk_stringByURLDecode];
                params[key] = value;
            }else if (paramArr.count > 2){
                NSString *key = [paramArr objectAtIndex:0];
                NSString *value = [paramArr objectAtIndex:1];
                for (NSInteger i = 2; i < paramArr.count; i++) {
                    value = [value stringByAppendingString:[NSString stringWithFormat:@"=%@",[paramArr objectAtIndex:i]]];
                }
                params[key] = [value mk_stringByURLDecode];
            }
        }
    }
    
    Class class = subRoutes[kMKRouterKeyEnd];
    if (class_isMetaClass(object_getClass(class))) {
        if ([class isSubclassOfClass:[UIViewController class]]) {
            params[kMKRouterKeyVCClass] = subRoutes[kMKRouterKeyEnd];
        } else {
            return nil;
        }
    }else {
        if (subRoutes[kMKRouterKeyEnd]) {
            if ([subRoutes[kMKRouterKeyEnd] isKindOfClass:[NSString class]]) {
                params[kMKRouterKeyRedirection] = subRoutes[kMKRouterKeyEnd];
            }else{
                params[kMKRouterKeyBlock] = [subRoutes[kMKRouterKeyEnd] copy];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

/** 以/分割 返回路径数组 */
- (NSArray *)pathComponentsFromRoute:(NSString *)route{
    NSMutableArray *pathComponents = [NSMutableArray array];
    NSURL *url = [NSURL URLWithString:[route stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    for (NSString *pathComponent in url.path.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:[pathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return [pathComponents copy];
}


#pragma mark - ***** filter out the app URL compontents *****
+ (NSString *)filterAppUrlScheme:(NSString *)route{
    for (NSString *appUrlScheme in [self appUrlSchemes]) {
        if ([route hasPrefix:[NSString stringWithFormat:@"%@:", appUrlScheme]]) {
            return [route substringFromIndex:appUrlScheme.length + 2];
        }
    }
    return route;
}

/** app URL schemes */
+ (NSArray *)appUrlSchemes{
    NSMutableArray *appUrlSchemes = [NSMutableArray array];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    for (NSDictionary *dic in infoDictionary[@"CFBundleURLTypes"]) {
        NSString *appUrlScheme = dic[@"CFBundleURLSchemes"][0];
        [appUrlSchemes addObject:appUrlScheme];
    }
    return [appUrlSchemes copy];
}

#pragma mark - ***** lazy *****
- (NSMutableDictionary *)routes{
    if (!_routes) {
        _routes = @{}.mutableCopy;
    }
    return _routes;
}
@end


#pragma mark - UIViewController Category
@implementation UIViewController (MKRouter)

static char kAssociatedParamsObjectKey;
static char kAssociatedBlockKey;

- (void)setMk_routeParams:(NSDictionary *)paramsDictionary{
    objc_setAssociatedObject(self, &kAssociatedParamsObjectKey, paramsDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)mk_routeParams{
    return objc_getAssociatedObject(self, &kAssociatedParamsObjectKey);
}

- (void)setMk_block:(MKBlock)mk_block{
    objc_setAssociatedObject(self, &kAssociatedBlockKey, mk_block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MKBlock)mk_block{
    return objc_getAssociatedObject(self, &kAssociatedBlockKey);
}
@end


@implementation NSString(MKAdd)

/** 对字符串进行URLEncode */
- (NSString *)mk_stringByURLEncode{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

/** 对字符串进行URLDecode */
- (NSString *)mk_stringByURLDecode{
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
        NSString *decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                (__bridge CFStringRef)self,
                                                                CFSTR(""),
                                                                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        return decoded;
    }
}


- (id)mk_jsonString2Dictionary{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"json解析失败:%@",error);
        return nil;
    }
    return dic;
}
@end
