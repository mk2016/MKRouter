//
//  NSString+MKAdd.h
//  MKToolsKit
//
//  Created by xiaomk on 16/9/9.
//  Copyright © 2016年 xiaomk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString(MKAdd)

#pragma mark - ***** URL Encode Decode *****
/** 对字符串进行URLEncode */
- (NSString *)mk_stringByURLEncode;

/** 对字符串进行URLDecode */
- (NSString *)mk_stringByURLDecode;


- (id)mk_jsonString2Dictionary;

@end

