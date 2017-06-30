//
//  MKRouter.h
//  MKRouterDemo
//
//  Created by xmk on 2017/6/28.
//  Copyright © 2017年 mk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, MKRouteType) {
    MKRouteType_none            = 0,
    MKRouteType_viewController,
    MKRouteType_block,
    MKRouteType_redirection
};

typedef id (^MKRouterBlock)(id params);


@interface MKRouter : NSObject
+ (instancetype)sharedInstance;

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
- (UIViewController *)matchController:(NSString *)route;

- (void)map:(NSString *)route toBlock:(MKRouterBlock)block;
- (MKRouterBlock)matchBlock:(NSString *)route;

- (void)map:(NSString *)route toRedirection:(NSString *)redirection;
- (id)matchRedirection:(NSString *)route;
@end



#pragma mark - ***** UIViewController Category *****
@interface UIViewController (MKRouter)
@property (nonatomic, strong) NSDictionary *mk_routeParams;
@property (nonatomic, copy) MKRouterBlock mk_block;
@end
