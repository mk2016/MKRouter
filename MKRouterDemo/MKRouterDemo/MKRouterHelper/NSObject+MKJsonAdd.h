//
//  NSString+MKJsonAdd.h
//  MKKit
//
//  Created by xmk on 2017/2/10.
//  Copyright © 2017年 mk. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (MKJsonAdd)
+ (NSDictionary *)mk_dictionaryWithJson:(id)json;
@end


@interface NSObject (MKJsonAdd);

/** model -> jsonString */
- (NSString *)mk_jsonString;
- (NSString *)mk_jsonStringWithPrettyPrint:(BOOL)pretty;

/** model -> jsonData */
- (NSData *)mk_jsonData;
- (NSData *)mk_jsonDataWithPrettyPrint:(BOOL)pretty;

/** model -> jsonObject */
- (id)mk_jsonObject;

@end


@interface NSString (MKAdd)
@property (nonatomic, assign) BOOL mk_transitionModePresent;
@end

