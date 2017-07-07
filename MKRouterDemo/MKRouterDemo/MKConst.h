//
//  MKConst.h
//  MKRouterDemo
//
//  Created by xmk on 2017/6/30.
//  Copyright © 2017年 mk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKUITools.h"
#import "MKRouter.h"
#import "MKRouterHelper.h"
#import "MJExtension.h"
#import "MKTestModel.h"
#import "NSObject+MKJsonAdd.h"

#define MKSCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define MKSCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height
#define MKSCREEN_SIZE       [UIScreen mainScreen].bounds.size
#define MKSCREEN_BOUNDS     [UIScreen mainScreen].bounds
#define MKBlockExec(block, ...) if (block) { block(__VA_ARGS__); };
