//
//  AAViewController.m
//  RSWebView
//
//  Created by rason on 16/4/6.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import "AAViewController.h"
#import "TestWebView.h"
@interface AAViewController (){
    TestWebView *webView;
}

@end

@implementation AAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webView = [[TestWebView alloc]initWithFrame:self.view.frame];
    //    webView.delegate = self;
    [self.view addSubview:webView];
    [self.view sendSubviewToBack:webView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)open:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"setupWebViewJavascriptBridge(function(bridge){bridge.callHandler('ObjC Echo',function responseCallback(responseData){console.log(\"JS received response:\",responseData)})})"];
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
