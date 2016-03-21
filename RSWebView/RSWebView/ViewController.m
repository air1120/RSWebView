//
//  ViewController.m
//  RSWebView
//
//  Created by rason on 16/3/2.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import "ViewController.h"
#import "RSWebView.h"
#import <WebKit/WebKit.h>
#import "BBWebViewSSLProtocol.h"
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,UIWebViewDelegate>{
    RSWebView *webView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webView = [self iniWebView];
    [self.view addSubview:webView];
    [self.view sendSubviewToBack:webView];
    [self Test2];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@",@"shouldStartLoadWithRequest");
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%@",@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%@",@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",@"didFailLoadWithError");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)yongli{
    RSWebView *webView = [[RSWebView alloc]initWithFrame:self.view.frame];
    webView.webSource = [[RSWebSource alloc] initWithUrl:@"http://192.168.8.131:8088/sdf" method:@"POST" headers:@{@"otherHeaders":@"ceshila",@"user-agent":@"Mozilla/6.4 (iPhone; CPU iPhone OS 9_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13C75"} body:@"sdfsd=2sdf"];
}
-(void)test2{
    [webView callHandler:@"JS Echo" data:@"success"];
}
-(void)Test0{
    [self pushView];
    [self doSomeThing:^{
        NSLog(@"是否主线程：%d",[NSThread isMainThread]);
        NSString *haha = [webView stringByEvaluatingJavaScriptFromString:@"alert(3+2)"];
        NSLog(@"haha:%@",haha);
    }];
}
-(void)doSomeThing:(void (^)())block{
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        block();
    });
}
-(void)Test1{
    //    [self pushView];
    NSString *urlString = @"http://www.meituan.com";
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [webView loadRequest:req];
}
-(void)Test2{
    //    UIWebView *view = [[UIWebView alloc]initWithFrame:self.view.frame];
    //    [self pushView:view];
    //    [self doSomeThing:^{
    //        [view stringByEvaluatingJavaScriptFromString:@"alert(3+2)"];
    //    }];
    //    self.tableView.hidden = YES;
    NSLog(@"是否主线程：%d",[NSThread isMainThread]);
//    webView.isUsingUIWebView = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *haha = [webView stringByEvaluatingJavaScriptFromString:@"alert(3+2)"];
        NSLog(@"haha:%@",haha);
    });

    
}
-(RSWebView *)iniWebView{
    webView = [[RSWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    webView.delegate = self;
    return webView;
}
-(void)pushView{
    [self pushView:[self iniWebView]];
}
-(void)pushView:(UIView *)view{
    UIViewController *vc = [[UIViewController alloc]init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [vc.view addSubview:view];
    [self.navigationController pushViewController:vc animated:NO];
}


- (IBAction)open:(id)sender {
    [self Test2];
}
-(void)openQQ{
    NSString *urlString = @"http://www.meituan.com";
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [webView loadRequest:req];
}

//UIViewController *viewController = [[UIViewController alloc]init];
////    [BBWebViewSSLProtocol addTrustedDomain:@"booking.cn.fcm.travel"];
//webView = [[RSWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
//webView.delegate = self;
////    [webView registerHandler:@"getScreenHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
////        responseCallback([NSNumber numberWithInt:[UIScreen mainScreen].bounds.size.height]);
////    }];
//[webView registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
//    NSLog(@"Log: %@", data);
//    responseCallback(data);
//}];

//    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
//    webView.source = [[RSSource alloc] initWithUrl:""];
//NSString *filePath = [[NSBundle mainBundle]pathForResource:@"index" ofType:@"html"];
//NSURL *url = [NSURL fileURLWithPath:filePath];
//NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.8.111:8088/"]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://booking.cn.fcm.travel/img/200049324/144799957714318319/20151120140610983315.png"]];
//[webView loadRequest:request];
//[self.view addSubview:webView];
//    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('rsspan').innerHTML = 'Fred Flinstone';"];
//
//[self.view sendSubviewToBack:webView];
//    webView.webSource = [[RSWebSource alloc] initWithUrl:@"http://192.168.8.131:8088/sdf" method:@"POST" headers:@{@"otherHeaders":@"ceshila",@"user-agent":@"Mozilla/6.4 (iPhone; CPU iPhone OS 9_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13C75"} body:@"sdfsd=2sdf"];
//    webView.webSource = [[RSWebSource alloc] initWithUrl:@"https://booking.cn.fcm.travel/img/200049324/144799957714318319/20151120140610983315.png" method:@"get" headers:@{@"otherHeaders":@"ceshila",@"user-agent":@"Mozilla/6.4 (iPhone; CPU iPhone OS 9_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13C75"} body:@""];
//    [webView loadLocalFile:@"index.html" baseURL:@"http://www.baidu.com"];
//    webView.webSource = [[RSWebSource alloc]initWithUrl:@"http://192.168.8.111:8088/" method:@"GET" headers:nil body:nil];

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{

//    });

//    [webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:@"3+3;" waitUntilDone:NO];


//    [webView evaluateJavaScript:@"document.getElementById('rsspan').innerHTML = 'Fred Flinstone';" completionHandler:^(id  _Nonnull result, NSError * _Nonnull error) {
//        NSLog(@"evaluateJavaScript:%@-------%@",result,error);
//    }];
// Do any additional setup after loading the view, typically from a nib.
@end
