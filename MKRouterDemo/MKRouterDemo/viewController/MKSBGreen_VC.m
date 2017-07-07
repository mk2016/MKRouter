//
//  MKSBGreen_VC.m
//  MKRouterDemo
//
//  Created by xmk on 2017/7/5.
//  Copyright © 2017年 mk. All rights reserved.
//

#import "MKSBGreen_VC.h"

@interface MKSBGreen_VC ()

@end

@implementation MKSBGreen_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"green";

    if (self.routeParams) {
        if (self.routeParams[@"username"]) {
            self.title = self.routeParams[@"username"];
        }
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
