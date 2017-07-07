//
//  MKWebView_VC.m
//  MKRouterDemo
//
//  Created by xmk on 2017/7/7.
//  Copyright © 2017年 mk. All rights reserved.
//

#import "MKWebView_VC.h"
#import "MKConst.h"
#import "MKRouterHelper.h"

@interface MKWebView_VC ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *urlStr;              /*!< 访问的URL */
@end

@implementation MKWebView_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.routeParams) {
        if ([self.routeParams objectForKey:@"url"]) {
            self.urlStr = [self.routeParams objectForKey:@"url"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
            
            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, MKSCREEN_WIDTH, MKSCREEN_HEIGHT-64)];
            self.webView.delegate = self;
            [self.view addSubview:self.webView];

            [self.webView loadRequest:request];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestUrl = request.URL.absoluteString;
    NSLog(@"requestUrl : %@", requestUrl);
    
    if ([requestUrl hasPrefix:@"MKRouterDemo"]) {
        [[MKRouterHelper sharedInstance] actionWithRoute:requestUrl param:nil onVC:self block:^(id result) {
            NSLog(@"back result : %@", result);
        }];
        return NO;
    }
    return YES;
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
