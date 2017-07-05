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
    MKRouteType_redirection             //重定向
};

typedef id (^MKRouterBlock)(id params);
typedef void (^MKBlock)(id result);


@interface MKRouter : NSObject
+ (instancetype)sharedInstance;

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
- (UIViewController *)matchController:(NSString *)route;

- (void)map:(NSString *)route toBlock:(MKRouterBlock)block;
- (MKRouterBlock)matchBlock:(NSString *)route;

- (void)map:(NSString *)route toRedirection:(NSString *)redirection;
- (id)matchRedirection:(NSString *)route;
- (MKRouteType)redirectionFinallyType:(NSString *)route finallyRoute:(NSString **)finallyRoute;

- (MKRouteType)canRoute:(NSString *)route;
@end



#pragma mark - ***** Category *****
/** UIViewController */
@interface UIViewController (MKRouter)
@property (nonatomic, strong) NSDictionary *mk_routeParams;
@property (nonatomic, copy) MKBlock mk_block;
@end

/** URL Encode Decode */
@interface NSString(MKRouter)
/** 对字符串进行URLEncode */
- (NSString *)mk_stringByURLEncode;
/** 对字符串进行URLDecode */
- (NSString *)mk_stringByURLDecode;
- (id)mk_jsonString2Dictionary;

@end

@interface NSDictionary (MKRouter)
+ (NSDictionary *)mk_dictionaryWithJson:(id)json;
@end


