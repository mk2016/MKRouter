//
//  ViewController.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/28.
//  Copyright © 2017年 mk. All rights reserved.
//



#import "ViewController.h"
#import "MKConst.h"



@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo";
    
    [[MKRouterHelper sharedInstance] registerRoutes];
    
    [self.dataSource addObject:@"MKRouterDemo://vc/blue"];
    [self.dataSource addObject:@"/vc/red?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
    [self.dataSource addObject:@"/redirection/test"];
    [self.dataSource addObject:@"/redirection/demo?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
    [self.dataSource addObject:@"/block/alert/"];
    [self.dataSource addObject:@"/block/block/"];
    [self.dataSource addObject:@"/vc/red/7777/ppp"];
    
    [self.dataSource addObject:@"/vc/blue/987/test"];
    [self.dataSource addObject:@"/red/blue/888?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MKSCREEN_WIDTH, MKSCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
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
    
    
    if (indexPath.row <= 3) {
        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:nil onVC:self block:^(id result) {
            NSString *message = [NSString stringWithFormat:@"msg:%@",result];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
        }];
        
    }else if (indexPath.row == 4){
        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:nil onVC:self block:^(id result) {
            NSLog(@"result : %@", result);
//            NSString *message = [NSString stringWithFormat:@"msg:%@",result];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
//            [alert show];
        }];
//        MKRouterBlock block = [[MKRouter sharedInstance] matchBlock:self.dataSource[indexPath.row]];
//        if (block) {
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            [dic setValue:@"1" forKey:@"add"];
//            block(dic);
//        }
    }else if (indexPath.row == 5){
        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:nil onVC:self block:^(id result) {
            NSLog(@"result : %@", result);
        }];
    }else{
        NSDictionary *dic = @{
                              @"key1" : @"value1",
                              @"key2" : @(2),
                              @"key3" : @3,
                              @"id": @4
                              };
        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:dic onVC:self block:^(id result) {
            
        }];
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
