//
//  NJKWebViewProgress.m
//
//  Created by Satoshi Aasano on 4/20/13.
//  Copyright (c) 2013 Satoshi Asano. All rights reserved.
//

#import "NJKWebViewProgress.h"
NSString *completeRPCURLPath = @"/njkwebviewprogressproxy/complete";

const float NJKInitialProgressValue = 0.1f;
const float NJKInteractiveProgressValue = 0.5f;
const float NJKFinalProgressValue = 0.9f;

@implementation NJKWebViewProgress
{
    NSUInteger _loadingCount;//正在进行的请求数,不包括完成的
    NSUInteger _maxLoadCount;//同时进行的最高请求数
    NSURL *_currentURL;
    BOOL _interactive;
}

- (id)init
{
    self = [super init];
    if (self) {
        _maxLoadCount = _loadingCount = 0;
        _interactive = NO;
    }
    return self;
}

- (void)startProgress
{
    if (_progress < NJKInitialProgressValue) {
        [self setProgress:NJKInitialProgressValue];
    }
}

- (void)incrementProgress
{
    float progress = self.progress;
    float maxProgress = _interactive ? NJKFinalProgressValue : NJKInteractiveProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress
{
    [self setProgress:1.0];
}

- (void)setProgress:(float)progress
{
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        if ([_progressDelegate respondsToSelector:@selector(webViewProgress:updateProgress:)]) {
            [_progressDelegate webViewProgress:self updateProgress:progress];
        }
        if (_progressBlock) {
            _progressBlock(progress);
        }
    }
}

- (void)reset
{
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.0];
}

#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if ([_wKNavigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_wKNavigationDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
    [self reset];
    if(navigationAction.targetFrame == nil)
    {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
//-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
//    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:@"bob"
//                                                               password:@"pass"
//                                                            persistence:NSURLCredentialPersistenceNone];
//    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    if ([_wKNavigationDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [_wKNavigationDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    [self startProgress];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if ([_wKNavigationDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [_wKNavigationDelegate webView:webView didFinishNavigation:navigation];
    }
    _loadingCount--;
    [self incrementProgress];
    [self completeProgress];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    if ([_wKNavigationDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [_wKNavigationDelegate webView:webView didFailNavigation:navigation withError:error];
    }
    _loadingCount--;
    [self incrementProgress];
    [self completeProgress];
}
#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL ret = YES;
    //回调webView的代理方法
    if ([_webViewProxyDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        ret = [_webViewProxyDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    [self handleResetProgressWithWebView:webView request:request ret:ret];
    
    return ret;
}
- (void)handleResetProgressWithWebView:(UIWebView *)webView request:(NSURLRequest *)request ret:(BOOL)ret{
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if (ret && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_webViewProxyDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_webViewProxyDelegate webViewDidStartLoad:webView];
    }

    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);

    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([_webViewProxyDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_webViewProxyDelegate webViewDidFinishLoad:webView];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];

    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {//interactive - 已加载，文档与用户可以开始交互
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([_webViewProxyDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_webViewProxyDelegate webView:webView didFailLoadWithError:error];
    }
    
    _loadingCount--;
    [self incrementProgress];

    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];

    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}

#pragma mark - 
#pragma mark Method Forwarding
// for future UIWebViewDelegate impl

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ( [super respondsToSelector:aSelector] )
        return YES;
    if ([self.webViewProxyDelegate respondsToSelector:aSelector])
        return YES;
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if(!signature) {
        if([_webViewProxyDelegate respondsToSelector:selector]) {
            return [(NSObject *)_webViewProxyDelegate methodSignatureForSelector:selector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    if ([_webViewProxyDelegate respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:_webViewProxyDelegate];
    }
}

@end
