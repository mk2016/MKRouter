//
//  MKRouter.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/28.
//  Copyright © 2017年 mk. All rights reserved.
//

#import "MKRouter.h"
#import "NSString+MKAdd.h"
#import "MKUITools.h"
#import <objc/runtime.h>

@interface MKRouter()
@property (nonatomic, strong) NSMutableDictionary *routes;
@end

static NSString * kMKRouterKeyVCClass       = @"controllerClass";
static NSString * kMKRouterKeyRedirection   = @"redirectionRouter";

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
    return [self matchRedirection:route orgin:YES];
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










#pragma mark - ***** private method match*****
- (UIViewController *)matchController:(NSString *)route orginRoute:(NSString *)orginRoute{
    NSMutableDictionary *params = [self paramsInRoute:route].mutableCopy;
    
    if (orginRoute && orginRoute.length > 0) {
        [params setValue:orginRoute forKey:@"orginRoute"];
    }
    
    Class controllerClass = params[kMKRouterKeyVCClass];
    
    UIViewController *viewController = nil;
    
    NSArray *pathAry = params[@"routePath"];
    if (pathAry && pathAry.count >= 3 && [pathAry.firstObject isEqualToString:@"sb"]) {
        viewController = [MKUITools getVCFromStoryboard:pathAry[1] identify:pathAry[2]];
    }else{
        viewController = [[controllerClass alloc] init];
    }
    
    if ([viewController respondsToSelector:@selector(setMk_routeParams:)]) {
        NSString *codeStr = params[@"param"];
        NSRange range = [codeStr rangeOfString:@"%"];
        if (codeStr && range.location != NSNotFound) {
            NSString *json = [codeStr mk_stringByURLDecode];
            
            NSMutableDictionary *tempDic = [params mutableCopy];
            [tempDic setValue:json forKey:@"param"];
            params = [tempDic mutableCopy];
        }
        [viewController performSelector:@selector(setMk_routeParams:) withObject:[params copy]];
    }
    return viewController;
}

- (MKRouterBlock)matchBlock:(NSString *)route orginRoute:(NSString *)orginRoute{
    NSMutableDictionary *params = [self paramsInRoute:route].mutableCopy;
    if (!params){
        return nil;
    }
    if (orginRoute && orginRoute.length > 0) {
        [params setValue:orginRoute forKey:@"orginRoute"];
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


static NSString * _orginRoute = nil;
- (id)matchRedirection:(NSString *)route orgin:(BOOL)orgin{
    if (orgin) {
        _orginRoute = route;
    }
    MKRouteType type = [self canRoute:route];
    if (type == MKRouteType_block) {
        return [self matchBlock:route orginRoute:_orginRoute];
    }else if (type == MKRouteType_viewController){
        return [self matchController:route orginRoute:_orginRoute];
    }else if (type == MKRouteType_redirection){
        NSString *nextRoute = [self matchNextRouteWith:route];
        return [self matchRedirection:nextRoute orgin:NO];
    }
    return nil;
}

- (NSString *)matchNextRouteWith:(NSString *)route{
    NSDictionary *params = [self paramsInRoute:route];
    if (!params) {
        return nil;
    }
    NSString *finallyRoute = params[kMKRouterKeyRedirection];
    if (finallyRoute) {
        return finallyRoute;
    }
    return nil;
}




#pragma mark - ***** private method *****
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



/** filter out the app URL compontents */
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

#pragma mark - ***** 返回 route 字典 *****
- (NSDictionary *)paramsInRoute:(NSString *)route{
    if (!route) {
        return nil;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"route"] = [MKRouter filterAppUrlScheme:route];
    
    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromRoute:params[@"route"]];
    params[@"routePath"] = pathComponents;
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

- (void)setMk_block:(MKRouterBlock)mk_block{
    objc_setAssociatedObject(self, &kAssociatedBlockKey, mk_block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MKRouterBlock)mk_block{
    return objc_getAssociatedObject(self, &kAssociatedBlockKey);
}
@end