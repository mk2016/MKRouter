//
//  ViewController.m
//  MKRouterDemo
//
//  Created by xmk on 2017/6/28.
//  Copyright © 2017年 mk. All rights reserved.
//



#import "MKDemo_VC.h"
#import "MKConst.h"



@interface MKDemo_VC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *headTitles;
@end

@implementation MKDemo_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo";
    
    [[MKRouterHelper sharedInstance] registerRoutes];
    
    self.headTitles = @[].mutableCopy;
    
    {
        [self.headTitles addObject:@"simple route"];
        NSMutableArray *ary = @[].mutableCopy;
        [ary addObject:@"/vc/blue"];
        [ary addObject:@"/sb/Main/sbid_MKSBGreen_VC"];
        [ary addObject:@"MKRouterDemo://vc/red"];
        [ary addObject:@"MKRouterDemo://sb/Main/sbid_MKSBGray_VC"];
        [self.dataSource addObject:ary];
    }
    {
        [self.headTitles addObject:@"param route"];
        NSMutableArray *ary = @[].mutableCopy;
        [ary addObject:kRoute_vc_blue];
        [ary addObject:kRoute_vc_red];
        [ary addObject:kRoute_vc_green];
        [ary addObject:kRoute_vc_gray];
        [self.dataSource addObject:ary];
    }
    {
        [self.headTitles addObject:@"path param"];
        NSMutableArray *ary = @[].mutableCopy;
        [ary addObject:@"/vc/blue/1111"];
        [ary addObject:@"/vc/red/2222/xiaoming"];
        [ary addObject:@"/sb/Main/sbid_MKSBGreen_VC/3333/gogogo"];
        [ary addObject:@"/sb/Main/sbid_MKSBGray_VC/4444/first/小明/second"];
        [self.dataSource addObject:ary];
    }
    
    {
        [self.headTitles addObject:@"hybrid param"];
        NSMutableArray *ary = @[].mutableCopy;
        [ary addObject:@"/vc/blue/1111?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
        [ary addObject:@"/vc/red/2222/xiaoming?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
        [ary addObject:@"/sb/Main/sbid_MKSBGreen_VC/3333/gogogo?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
        [ary addObject:@"/sb/Main/sbid_MKSBGray_VC/4444/first/小明/second?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
        [self.dataSource addObject:ary];
    }
    {
        [self.headTitles addObject:@"vc action block"];
        NSMutableArray *ary = @[].mutableCopy;
        [ary addObject:kRoute_vc_blue];
        [ary addObject:kRoute_vc_red];
        [ary addObject:kRoute_vc_green];
        [ary addObject:kRoute_vc_gray];
        [self.dataSource addObject:ary];
    }
    {
        [self.headTitles addObject:@"block route"];
        NSMutableArray *ary = @[].mutableCopy;
        [ary addObject:@"/block/alert/7777"];
        [ary addObject:kRoute_block_nav];
        [ary addObject:@"/block/call/tel/10086"];
        [self.dataSource addObject:ary];
    }
    
//    [self.dataSource addObject:@"/vc/red?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
//    [self.dataSource addObject:@"/redirection/test"];
//    [self.dataSource addObject:@"/redirection/demo?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
//    [self.dataSource addObject:@"/block/alert/"];
//    [self.dataSource addObject:@"/block/block/"];
//    [self.dataSource addObject:@"/vc/red/7777/ppp"];
//    
//    [self.dataSource addObject:@"/vc/blue/987/test"];
//    [self.dataSource addObject:@"/red/blue/888?param=%7B%22id%22%3A%22118%22%2C%22trackValue%22%3A%22100002%22%7D"];
    
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
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *route = self.dataSource[indexPath.section][indexPath.row];
    
    if (indexPath.section == 1 || indexPath.section == 3) {
        id param = nil;
        if (indexPath.row == 0 || indexPath.row == 1) {
            NSDictionary *dic = @{
                                  @"key1" : @"value1",
                                  @"key2" : @(2),
                                  @"key3" : @3,
                                  @"id": @4
                                  };
            param = dic;
        }else{
            MKTestModel *model = [[MKTestModel alloc] init];
            model.name = @"小明";
            model.age = 14;
            model.sex = YES;
            model.height = 178.4f;
            param = model;
        }
        [[MKRouterHelper sharedInstance] actionWithRoute:route param:param onVC:self block:nil];

    }else if (indexPath.section == 4){
        [[MKRouterHelper sharedInstance] actionWithRoute:route param:nil onVC:self block:^(NSDictionary *result) {
            NSString *message = result ? result.description : @"no block param";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"block param" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }else if ([self.headTitles[indexPath.section] isEqualToString:@"block route"]){
        [[MKRouterHelper sharedInstance] actionWithRoute:route param:nil onVC:self block:^(id result) {
            NSLog(@"result : %@",result);
        }];
    }else{
        [[MKRouterHelper sharedInstance] actionWithRoute:route param:nil onVC:self block:nil];
    }
    
    
    
    
    
    
    
    
    
    
//    if (indexPath.row <= 3) {
//        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:nil onVC:self block:^(id result) {
//            NSString *message = [NSString stringWithFormat:@"msg:%@",result];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
//            [alert show];
//        }];
//        
//    }else if (indexPath.row == 4){
//        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:nil onVC:self block:^(id result) {
//            NSLog(@"result : %@", result);
////            NSString *message = [NSString stringWithFormat:@"msg:%@",result];
////            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
////            [alert show];
//        }];
////        MKRouterBlock block = [[MKRouter sharedInstance] matchBlock:self.dataSource[indexPath.row]];
////        if (block) {
////            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
////            [dic setValue:@"1" forKey:@"add"];
////            block(dic);
////        }
//    }else if (indexPath.row == 5){
//        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:nil onVC:self block:^(id result) {
//            NSLog(@"result : %@", result);
//        }];
//    }else{
//        NSDictionary *dic = @{
//                              @"key1" : @"value1",
//                              @"key2" : @(2),
//                              @"key3" : @3,
//                              @"id": @4
//                              };
//        [[MKRouterHelper sharedInstance] actionWithRoute:self.dataSource[indexPath.row] param:dic onVC:self block:^(id result) {
//            
//        }];
//    }
//    
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MKSCREEN_WIDTH, 30)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, MKSCREEN_WIDTH-32, 30)];
    lab.text = self.headTitles[section];
    lab.font = [UIFont systemFontOfSize:14];
    lab.textColor = [UIColor grayColor];
    [view addSubview:lab];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
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
