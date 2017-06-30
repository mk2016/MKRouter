//
//  ViewController.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/28.
//  Copyright © 2017年 mk. All rights reserved.
//



#import "ViewController.h"
#import "MKConst.h"
#import "MKRouter.h"
#import "MKBlue_VC.h"
#import "MKRed_VC.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo";
    
    [self loadRoute];
    
    [self.dataSource addObject:@"/vc/blue"];
    [self.dataSource addObject:@"/vc/red?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
    [self.dataSource addObject:@"/redirection/test"];
    [self.dataSource addObject:@"/redirection/demo"];
    [self.dataSource addObject:@"/block/alert/"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MKSCREEN_WIDTH, MKSCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
}

- (void)loadRoute{
    [[MKRouter sharedInstance] map:@"/vc/blue" toControllerClass:[MKBlue_VC class]];
    [[MKRouter sharedInstance] map:@"/vc/red" toControllerClass:[MKRed_VC class]];
    [[MKRouter sharedInstance] map:@"/redirection/test" toRedirection:@"/vc/red"];
    [[MKRouter sharedInstance] map:@"/redirection/demo" toRedirection:@"/redirection/test"];

    [[MKRouter sharedInstance] map:@"/block/alert/" toBlock:^id(NSDictionary *params) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:params.description delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        return params;
    }];

}


#pragma mark - ***** UITableView delegate *****
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UIViewController *vc = [[MKRouter sharedInstance] matchController:self.dataSource[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1){
        UIViewController *vc = [[MKRouter sharedInstance] matchController:self.dataSource[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2){
        UIViewController *vc = [[MKRouter sharedInstance] matchRedirection:self.dataSource[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3){
        UIViewController *vc = [[MKRouter sharedInstance] matchRedirection:self.dataSource[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 4){
        MKRouterBlock block = [[MKRouter sharedInstance] matchBlock:self.dataSource[indexPath.row]];
        if (block) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:@"1" forKey:@"add"];
            block(dic);
        }
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 16;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
