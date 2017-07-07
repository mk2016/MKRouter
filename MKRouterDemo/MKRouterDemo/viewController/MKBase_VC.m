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

- (void)setMk_routeParams:(NSDictionary *)params{
    if (params) {
        NSLog(@"setParams : %@", params);
        
        self.routeParams = params;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labText = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, MKSCREEN_WIDTH-32, MKSCREEN_HEIGHT-64-60)];
    self.labText.font = [UIFont systemFontOfSize:16];
    self.labText.textColor = [UIColor whiteColor];
    self.labText.numberOfLines = 0;
    self.labText.text = @"无参数";
    [self.view addSubview:self.labText];
    
    if (self.routeParams) {
        self.labText.text = self.routeParams.description;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"back exec block" forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, MKSCREEN_HEIGHT-60, MKSCREEN_WIDTH, 60);
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)btnAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
    MKBlockExec(self.mk_block, self.routeParams);
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
