//
//  Example.h
//  RSWebView
//
//  Created by rason on 16/3/21.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import "TestUtil.h"
#import "RSWebView.h"
@interface Example : TestUtil<WKNavigationDelegate,WKUIDelegate,UIWebViewDelegate>
@property(strong,nonatomic)RSWebView *webView;
@property(strong,nonatomic)UIViewController *viewController;
@end
