//
//  ViewController.m
//  BlocBrowser
//
//  Created by Carlos Calderon on 10/20/15.
//  Copyright (c) 2015 Carlos Calderon. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)loadView {
    UIView *mainView = [UIView new];
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    [mainView addSubview: self.webView];
    self.view = mainView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.webView.frame = self.view.frame;
}



@end
