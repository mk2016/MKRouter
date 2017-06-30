//
//  MKBase_VC.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/30.
//  Copyright © 2017年 mk. All rights reserved.
//

#import "MKBase_VC.h"
#import "MKConst.h"

@interface MKBase_VC ()

@end

@implementation MKBase_VC

//- (void)setMk_routeParams:(NSDictionary *)params{
//    if (params) {
//        NSLog(@"setParams : %@", params);
//        
//        NSString *titleStr = params[@"title"];
//        if (titleStr && titleStr.length > 0) {
//            self.title = titleStr;
//        }
//        
//        if ([params objectForKey:@"param"]) {
//            NSString *jsonParam = [params objectForKey:@"param"];
//            NSDictionary *dic = [jsonParam mk_jsonString2Dictionary];
//            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
//                self.routeParamDic = dic;
//            }
//        }
//    }
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labText = [[UILabel alloc] initWithFrame:CGRectMake(16, 100, MKSCREEN_WIDTH-32, MKSCREEN_HEIGHT-100)];
    self.labText.font = [UIFont systemFontOfSize:16];
    self.labText.textColor = [UIColor whiteColor];
    self.labText.numberOfLines = 0;
    self.labText.text = @"无参数";
    [self.view addSubview:self.labText];
    
    if (self.mk_routeParams) {
        NSLog(@"%@",self.mk_routeParams.description);
        NSString *param = [self.mk_routeParams objectForKey:@"param"];
        self.labText.text = param;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
