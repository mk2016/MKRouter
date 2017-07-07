//
//  MKRed_VC.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/30.
//  Copyright © 2017年 mk. All rights reserved.
//

#import "MKRed_VC.h"
#import "MKConst.h"

@interface MKRed_VC ()

@end

@implementation MKRed_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"red";
    self.view.backgroundColor = [UIColor redColor];
}

- (void)btnAction:(UIButton *)sender{
    if (self.present) {
        [self dismissViewControllerAnimated:YES completion:nil];
        MKBlockExec(self.mk_block, @"back success");
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        MKBlockExec(self.mk_block, self.routeParams);
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
