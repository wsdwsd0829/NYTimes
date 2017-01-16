//
//  DetailController.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "DetailController.h"
#import <WebKit/WebKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface DetailController () <WKNavigationDelegate>
@property (nonatomic) Article* article;
@property (nonatomic) WKWebView* webView;
@end

@implementation DetailController

-(instancetype)initWithArticle:(Article*)article {
    self = [super init];
    if(self) {
        self.article = article;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview: self.webView];
    self.webView.navigationDelegate = self;
    NSURL* url = [NSURL URLWithString: self.article.articleUrl];
    if(url) {
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest: request];
        [SVProgressHUD show];
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.webView stopLoading];
//    self.webView.navigationDelegate = nil;
    [SVProgressHUD dismiss];
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
   [SVProgressHUD dismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
