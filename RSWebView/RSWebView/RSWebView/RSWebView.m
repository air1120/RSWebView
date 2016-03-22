    //
//  RSWebView.m
//  RSWebView
//
//  Created by rason on 16/3/2.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import "RSWebView.h"
#import "NJKWebViewProgressView.h"

#import <WebKit/WKUserScript.h>
#import <WebKit/WKWebViewConfiguration.h>
#import <WebKit/WKUserContentController.h>
#import "BBWebViewSSLProtocol.h"
#define messengeAlert @""
#define boundsWidth self.superview.bounds.size.width
#define boundsHeight self.superview.bounds.size.height

@implementation RSWebSource
-(id)initWithUrl:(NSString *)url method:(NSString *)method headers:(NSDictionary *)headers body:(NSString *)body{
    if(self = [super init]){
        self.url = url;
        self.method = method;
        self.headers = headers;
        self.body = body;
    }
    return self;
}
-(id)initWithHtml:(NSString *)html baseURL:(NSString *)baseURL{
    if(self = [super init]){
        self.html = html;
        self.baseURL = baseURL;
    }
    return self;
}
@end

@interface RSWebView ()<UIGestureRecognizerDelegate>
#pragma mark - js交互
@property id bridge;
#pragma mark - 其它部分
@property (nonatomic)UIScreenEdgePanGestureRecognizer* swipePanGesture;
@property (nonatomic)UIBarButtonItem* closeButtonItem;
/**
 *  if is swiping now
 */
@property (nonatomic)BOOL isSwipingBack;
/**
 *  array that hold snapshots
 */
@property (nonatomic)NSMutableArray* snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic)UIView* currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic)UIView* prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic)UIView* swipingBackgoundView;
@end
@implementation RSWebView
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    UIWebView *_uIWebView;
    WKWebView *_wKWebView;
    WebViewJavascriptBridge *webViewJavascriptBridge;
    WKWebViewJavascriptBridge *wKWebViewJavascriptBridge;
}
@synthesize realWebView = _realWebView;
@synthesize scalesPageToFit = _scalesPageToFit;
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initWebViewWithFrame:self.frame];
        [self setupProgressViewAndJavascriptBridge];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWebViewWithFrame:self.frame];
        [self setupProgressViewAndJavascriptBridge];
    }
    return self;
}
-(void)initWebViewWithFrame:(CGRect)frame{
    //包括获取本地资源，所以file必须要加上
    self.trustedScheme = @[@"file",@"mqq"];
    BOOL isIOS8AndGreater = [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0;
    _isUsingUIWebView = !isIOS8AndGreater;
    switch (webViewType) {
        case RSWebViewTypeUIWebView:
        _isUsingUIWebView = YES;
        break;
        case RSWebViewTypeWkWebView:
        _isUsingUIWebView = NO;
        break;
        default:
        break;
    }
    if (_isUsingUIWebView) {
        [self initUIWebViewWithFrame:frame];
    }else{
        [self initWKWebViewWithFrame:frame];
    }
    self.scalesPageToFit = YES;
    [self addSubview:self.realWebView];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.realWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}
-(void)initUIWebViewWithFrame:(CGRect)frame{
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    UIWebView *webView =[[UIWebView alloc]initWithFrame:frame];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:self.swipePanGesture];
    self.swipePanGesture.delegate = self;
    _uIWebView = webView;
    self.realWebView = _uIWebView;
}

-(void)initWKWebViewWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    WKWebViewConfiguration* configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.preferences = [NSClassFromString(@"WKPreferences") new];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    NSAssert(webView != nil, @"请导入WebKit.framework");
    _wKWebView = webView;
    [_wKWebView setFrame:frame];
    self.realWebView = _wKWebView;
}
#pragma mark - Add NJKWebViewProgress And WebViewJavascriptBridge ----------------------------------
-(void)setupProgressViewAndJavascriptBridge{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    //代理方法必须先设置，不然方法的转发无效
    _progressProxy.wKNavigationDelegate = self;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    if (_isUsingUIWebView) {
        webViewJavascriptBridge = [WebViewJavascriptBridge bridgeForWebView:_uIWebView];
        [webViewJavascriptBridge setWebViewDelegate:_progressProxy];
        self.bridge = webViewJavascriptBridge;
    }
    else{
        //delegate不能分开设置
        wKWebViewJavascriptBridge = [WKWebViewJavascriptBridge bridgeForWebView:_wKWebView webViewDelegate:_progressProxy];
        self.bridge = wKWebViewJavascriptBridge;
    }
    [self performSelector:@selector(setupProgressView2) withObject:nil afterDelay:0.1];
}
-(void)setupProgressView2{
    CGFloat progressBarHeight = 2.f;
    NSLog(@"%@",NSStringFromUIEdgeInsets(self.scrollView.contentInset));
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0,self.scrollView.contentInset.top, self.frame.size.width, progressBarHeight)];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_progressView];
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma mark- UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self callback_webViewDidFinishLoad];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self callback_webViewDidStartLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self callback_webViewDidFailLoadWithError:error];
    NSLog(@"请求失败:%@",error);
    if (error.code == -1009) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"请检查当前网络问题" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]show];
    }
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeBackForward: {
            break;
        }
        case UIWebViewNavigationTypeReload: {
            break;
        }
        case UIWebViewNavigationTypeFormResubmitted: {
            break;
        }
        case UIWebViewNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        default: {
            break;
        }
    }
    NSURL *url = request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    //判断scheme是不是可以访问
    if (![self validateHttpOrHttps:urlString]) {
        if (self.trustedScheme && ![self.trustedScheme containsObject:url.scheme]) {
            return NO;
        }
    }
    // iTunes: App Store link
    if ([self validateItunesUrl:urlString]) {
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
    
    return resultBOOL;
}
- (BOOL)validateItunesUrl:(NSString *) matchee
{
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"\\/\\/itunes\\.apple\\.com\\/"  options:0 error:nil];
    return [exp numberOfMatchesInString:matchee options:0 range:NSMakeRange(0, matchee.length)] > 0;
    
}
- (BOOL)validateHttpOrHttps:(NSString *) matchee
{
    NSString* reg = @"^https?:\\/\\/";
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:reg  options:0 error:nil];
    return [exp numberOfMatchesInString:matchee options:0 range:NSMakeRange(0, matchee.length)] > 0;
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    //    NSString *hostString = webView.URL.host;
    //    NSString *sender = [NSString stringWithFormat:messengeAlert, hostString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self.viewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    //    NSString *hostString = webView.URL.host;
    //    NSString *sender = [NSString stringWithFormat:messengeAlert, hostString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        //textField.placeholder = defaultText;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self.viewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    //    NSString *hostString = webView.URL.host;
    //    NSString *sender = [NSString stringWithFormat:messengeAlert, hostString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [self.viewController presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark- WKNavigationDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    
    // iTunes: App Store link
    if ([self validateItunesUrl:urlString]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // Protocol/URL-Scheme without http(s)
    else if (![self validateHttpOrHttps:urlString]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if (self.trustedScheme && ![self.trustedScheme containsObject:url.scheme]) {
            return;
        }
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(resultBOOL)
    {
        //        self.currentRequest = navigationAction.request;
        if(navigationAction.targetFrame == nil)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
//用于处理ssl的认证问题
-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:@"bob"
                                                               password:@"pass"
                                                            persistence:NSURLCredentialPersistenceNone];
    if (webView.URL.host&&[BBWebViewSSLProtocol isTrustedDomain:webView.URL.host]) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else{
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, credential);
    }
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self callback_webViewDidStartLoad];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self callback_webViewDidFinishLoad];
}
- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self callback_webViewDidFailLoadWithError:error];
}
- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error
{
    [self callback_webViewDidFailLoadWithError:error];
}


#pragma mark- 由于webView的回调,待测试

- (void)callback_webViewDidFinishLoad
{
    [self fixViewport];
    [self setNavigationTitle];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
    if([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.delegate webViewDidFinishLoad:self.realWebView];
    }
}
- (void)fixViewport{
    CGFloat width = self.bounds.size.width;
    
    if (width != [[UIScreen mainScreen] bounds].size.width) {
        [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var __viewport = document.querySelector('meta[name=viewport]'); if(__viewport){__viewport.setAttribute('content', __viewport.getAttribute('content').replace(/width=[^,]+/i,'width=%f'))};", width, nil]];
    }
}
- (void)callback_webViewDidStartLoad
{
    if([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.delegate webViewDidStartLoad:self.realWebView];
    }
}
- (void)callback_webViewDidFailLoadWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.delegate webView:self.realWebView didFailLoadWithError:error];
    }
}
-(BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    BOOL resultBOOL = YES;
    if([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if(navigationType == -1) {
            navigationType = UIWebViewNavigationTypeOther;
        }
        resultBOOL = [self.delegate webView:self.realWebView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    [self updateNavigationItems];
    return resultBOOL;
}
#pragma mark - logic of push and pop snap shot views
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        //        NSLog(@"about blank!! return");
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    UIView* currentSnapShotView = [self.realWebView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{
       @"request":request,
       @"snapShotView":currentSnapShotView
       }
     ];
}
#pragma mark - update nav items

-(void)updateNavigationItems{
    //config navigation item
    self.viewController.navigationItem.leftItemsSupplementBackButton = YES;
    if (self.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.viewController.navigationItem setLeftBarButtonItems:@[self.closeButtonItem] animated:NO];
        
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationController.navigationItem setLeftBarButtonItems:nil];
    }
}

#pragma mark - UIWebView和WKWebView公有部分处理
-(UIScrollView *)scrollView{
    return [self.realWebView scrollView];
}
- (id)loadRequest:(NSURLRequest *)request{
    if(_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView loadRequest:request];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView loadRequest:request];
    }
}
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if(_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView loadHTMLString:string baseURL:baseURL];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView loadHTMLString:string baseURL:baseURL];
    }
}
-(NSURLRequest *)request{
    return [self.realWebView request];
}
- (id)reload
{
    if(_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView reload];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView reload];
    }
}
- (void)stopLoading
{
    [self.realWebView stopLoading];
}

- (id)goBack
{
    if(_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView goBack];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView goBack];
    }
}
- (id)goForward
{
    if(_isUsingUIWebView)
    {
        [(UIWebView*)self.realWebView goForward];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView goForward];
    }
}
-(BOOL)canGoBack
{
    return [self.realWebView canGoBack];
}
-(BOOL)canGoForward
{
    return [self.realWebView canGoForward];
}
-(BOOL)isLoading
{
    return [self.realWebView isLoading];
}

-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    if(_isUsingUIWebView)
    {
        return [self stringByEvaluatingJavaScriptFromStringForUIWebView:javaScriptString];
    }
    else
    {
        __block NSString* result = nil;
        __block BOOL isRunning = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [(WKWebView*)self.realWebView evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
                result = obj;
                isRunning = YES;
            }];
        });
        NSRunLoop *runLoop = [[NSRunLoop alloc]init];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        while (isRunning==YES) {
            @autoreleasepool {
                //            NSLog(@"开始");
                
                [runLoop runUntilDate:[NSDate distantFuture]];
                //            NSLog(@"结束");
            }
        }
        return result;
    }
}

// 如果在WebView初始化的时候调用该方法，涉及界面修改的话会出错。
-(id)stringByEvaluatingJavaScriptFromStringForUIWebView:(NSString *)script{
    //UI run main thread
    ////    stringify()用于从一个对象解析出字符串
    //    script = [NSString stringWithFormat:@"JSON.stringify(%@);", script];
    if ([NSThread isMainThread]) {
        script = [_uIWebView stringByEvaluatingJavaScriptFromString:script];
    } else {
        NSString *isRunning = @"Y";
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"isRunning":isRunning,@"result":@"",@"script":script}];
        [self performSelectorOnMainThread:@selector(handleStringByEvaluatingJavaScriptFromString:) withObject:dic waitUntilDone:NO];
        NSRunLoop *runLoop = [[NSRunLoop alloc]init];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        while ([[dic valueForKey:@"isRunning"] isEqualToString:@"Y"]) {
            @autoreleasepool {
                //            NSLog(@"开始");
                [runLoop runUntilDate:[NSDate distantFuture]];
                //            NSLog(@"结束");
            }
        }
        
        return [dic valueForKey:@"result"];
    }
    return script;
}
-(void)handleStringByEvaluatingJavaScriptFromString:(NSMutableDictionary *)dic{
    NSString *script = [dic valueForKey:@"script"];
    NSString *isRunning = [dic valueForKey:@"isRunning"];
    NSString *result = [_uIWebView stringByEvaluatingJavaScriptFromString:script];
    isRunning = @"N";
    [dic setObject:result forKey:@"result"];
    [dic setObject:isRunning forKey:@"isRunning"];
}
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if(_isUsingUIWebView)
    {
        
        NSString* result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
        if(completionHandler)
        {
            completionHandler(result,nil);
        }
    }
    else
    {
        return [(WKWebView*)self.realWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

-(BOOL)scalesPageToFit
{
    if(_isUsingUIWebView)
    {
        return [_uIWebView scalesPageToFit];
    }
    else
    {
        return _scalesPageToFit;
    }
}
-(void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if(_isUsingUIWebView)
    {
        _uIWebView.scalesPageToFit = scalesPageToFit;
    }
    else
    {
        if(_scalesPageToFit == scalesPageToFit)
        {
            return;
        }

        WKWebView* webView = _wKWebView;

        NSString *jScript = @"var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";

        if(scalesPageToFit)
        {
            //WKUserScriptInjectionTimeAtDocumentEnd说明是加载完后执行，还有WKUserScriptInjectionTimeAtDocumentStart可用
            WKUserScript *wkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [webView.configuration.userContentController addUserScript:wkUScript];
        }
        else
        {
            NSMutableArray* array = [NSMutableArray arrayWithArray:webView.configuration.userContentController.userScripts];
            for (WKUserScript *wkUScript in array)
            {
                if([wkUScript.source isEqual:jScript])
                {
                    [array removeObject:wkUScript];
                    break;
                }
            }
            for (WKUserScript *wkUScript in array)
            {
                [webView.configuration.userContentController addUserScript:wkUScript];
            }
        }
        _scalesPageToFit = scalesPageToFit;
    }
}
#pragma mark-  如果没有找到方法 去realWebView 中调用，http://www.cnblogs.com/biosli/p/NSObject_inherit_2.html
-(BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if(hasResponds == NO)
    {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    if(hasResponds == NO)
    {
        hasResponds = [self.realWebView respondsToSelector:aSelector];
    }
    return hasResponds;
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* methodSign = [super methodSignatureForSelector:selector];
    if(methodSign == nil)
    {
        if([self.realWebView respondsToSelector:selector])
        {
            methodSign = [self.realWebView methodSignatureForSelector:selector];
        }
        else
        {
            methodSign = [(id)self.delegate methodSignatureForSelector:selector];
        }
    }
    return methodSign;
}
- (void)forwardInvocation:(NSInvocation*)invocation
{
    if([self.realWebView respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.realWebView];
    }
    else
    {
        [invocation invokeWithTarget:self.delegate];
    }
}
#pragma mark - 支持手势滑动后退，后退时显示上个页面截图（类似safari，wechat）
-(UIScreenEdgePanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
        _swipePanGesture.edges = UIRectEdgeLeft;
    }
    return _swipePanGesture;
}
#pragma mark - js交互部分
- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    [self.bridge registerHandler:handlerName handler:handler];
}
- (void)callHandler:(NSString *)handlerName {
    [self.bridge callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self.bridge callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [self.bridge callHandler:handlerName data:data responseCallback:responseCallback];
}

#pragma mark - events handler
-(void)closeItemClicked{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)swipePanGestureHandler:(UIScreenEdgePanGestureRecognizer*)gesture{
    
    CGPoint translation = [gesture translationInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self startPopSnapshotView];
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        [self endPopSnapShotView];
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

-(void)startPopSnapshotView{
    if (self.isSwipingBack) {
        return;
    }
    if (![self.realWebView canGoBack]) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.superview.bounds.size.width/2, self.superview.bounds.size.height/2);
    
    //move to center of screen
    self.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.superview.backgroundColor = [UIColor blackColor];
    
    [self.superview addSubview:self.prevSnapShotView];
    [self.superview addSubview:self.swipingBackgoundView];
    [self.superview bringSubviewToFront:self];
    [self endEditing:NO];
}
-(void)endPopSnapShotView{
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.superview.userInteractionEnabled = NO;
    
    if (self.center.x >= boundsWidth) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.center = CGPointMake(boundsWidth*3/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.swipingBackgoundView.alpha = 0;
        }completion:^(BOOL finished) {
            self.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            //            [self.currentSnapShotView removeFromSuperview];
            
            [self goBack];
            [self.snapShotsArray removeLastObject];
            self.superview.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2-60, boundsHeight/2);
            self.prevSnapShotView.alpha = 1;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            //            [self.currentSnapShotView removeFromSuperview];
            self.superview.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    prevSnapshotViewCenter.x -= (boundsWidth - distance)*60/boundsWidth;
    //    NSLog(@"prev center x%f",prevSnapshotViewCenter.x);
    
    self.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (boundsWidth - distance)/boundsWidth;
}

-(BOOL)isSwipingBack{
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}
-(UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.superview.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}
#pragma mark - setters and getters
-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    }
    return _closeButtonItem;
}
- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
-(UINavigationController *)navigationController{
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)self.viewController;
    }
    else{
        return self.viewController.navigationController;
    }
}
-(void)setWebSource:(RSWebSource *)webSource{
    _webSource = webSource;
    //GET方法的时候，不能设置BODY
    if (webSource) {
        if (webSource.html) {
            [self loadHTMLString:webSource.html baseURL:[NSURL URLWithString:webSource.baseURL]];
        }
        else{
            NSLog(@"the url is +++---+++ %@",webSource.url);
            NSURL * _url = [NSURL URLWithString:webSource.url];
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
            [request setAllHTTPHeaderFields:webSource.headers];
            if(webSource.headers && [webSource.headers valueForKey:@"user-agent"]){
                NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:[webSource.headers valueForKey:@"user-agent"], @"UserAgent", nil];
                [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
            }
            [request setHTTPMethod:webSource.method];
            [request setHTTPBody:[webSource.body dataUsingEncoding:NSUTF8StringEncoding]];
            [self loadRequest:request];
        }
    }
    
}
-(void)setNavigationTitle{
    NSString *theTitle=[self stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (theTitle.length > 10) {
        theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
    }
    self.viewController.title = theTitle;
}
-(void)loadLocalFile:(NSString *)fileName baseURL:(NSString *)baseURL{
    NSString *fullPath = [self fullPathWithFileName:fileName];
    NSString *data = [[NSString alloc]initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
    [self loadHTMLString:data baseURL:[NSURL URLWithString:baseURL]];
}
-(void)loadLocalFile:(NSString *)fileName{
    NSString *fullPath = [self fullPathWithFileName:fileName];
    NSString *ext = [fileName pathExtension];
    if ([ext isEqualToString:@"js"]) {
        NSString *js = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
        [self stringByEvaluatingJavaScriptFromString:js];
    }else{
        NSURL* url = [NSURL fileURLWithPath:fullPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
        [self loadRequest:request];
    }
}
-(NSString *)fullPathWithFileName:(NSString *)fileName{
    NSString *ext = [fileName pathExtension];
    NSString *name = [fileName stringByDeletingPathExtension];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    return fullPath;
}
+(void)setWebViewType:(RSWebViewType)type{
    webViewType = type;
}
@end
#pragma mark - 其它类
@implementation UIWebView (JavaScriptAlert)

static BOOL diagStat = NO;
static BOOL isRuning;
-(void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame{
    isRuning = YES;
    
    NSLog(@"webView是否主线程：%d",[NSThread isMainThread]);
    UIAlertView* dialogue = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [dialogue show];
    while (isRuning==YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

-(BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame{
    isRuning = YES;
    UIAlertView* dialogue = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [dialogue show];
    
    while (isRuning==YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    
    
    return diagStat;
}
- (NSString *)webView:(UIWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame
{
    isRuning = YES;
    //    NSString *hostString = webView.URL.host;
    //    NSString *sender = [NSString stringWithFormat:messengeAlert, hostString];
    __block NSString *result ;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        //textField.placeholder = defaultText;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        //        completionHandler(input);
        result = input;
        isRuning = NO;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //        completionHandler(nil);
        result = nil;
        isRuning = NO;
    }]];
    [[self viewController] presentViewController:alertController animated:YES completion:^{}];
    while (isRuning==YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    }
    
    return result;
}
//获取当前屏幕显示的viewcontroller
- (UIViewController *)viewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] firstObject];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==0) {
        diagStat=NO;
    }else if(buttonIndex==1){
        diagStat=YES;
    }
    isRuning = NO;
}
@end
