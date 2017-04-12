//
//  RSWebView.h
//  RSWebView
//
//  Created by rason on 16/3/2.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NJKWebViewProgress.h"
#import <WebKit/WKWebView.h>
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
NS_ASSUME_NONNULL_BEGIN
@protocol RSWebViewNavigationDelegate <NSObject>
- (void)webViewUpdateNavigation:(UIView *)webView;
- (void)webViewHandleForCapturedUrl:(NSString *)url withRegularExpression:(NSString *)urlRegularExpression;//捕获url
@end
@class RSWebView;
typedef enum {
    RSWebViewTypeDefault,//ios7及之前是UIWebView,ios8之后自动转WkWebView
    RSWebViewTypeUIWebView,//强制UIWebView
    RSWebViewTypeWkWebView//强制WkWebView
}RSWebViewType;
static RSWebViewType webViewType = RSWebViewTypeDefault;

@interface RSWebSource : NSObject
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *method;
@property(nonatomic, strong) NSDictionary *headers;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong) NSString *html;
@property(nonatomic, strong) NSString *baseURL;
-(id)initWithUrl:(NSString *)url method:(NSString *)method headers:(NSDictionary *)headers body:(id)body;
-(id)initWithHtml:(NSString *)html baseURL:(NSString *)baseURL;
@end

#pragma mark - 关于没有重写的方法会自动映射到相应的webView或者self.delegate直接调用，不过这时需要分别处理UIWebView和WKWebView的两种情况。
@interface RSWebView : UIView<NJKWebViewProgressDelegate,UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) id realWebView;

@property (nullable, nonatomic, weak) id <UIWebViewDelegate,WKNavigationDelegate,RSWebViewNavigationDelegate> delegate;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *trustedScheme;//白名单，就是只打开的scheme
@property (nonatomic, strong) NSArray *unTrustedScheme;//黑名单，就是不打开的scheme
@property (nonatomic, strong) NSArray *captureUrlRegularExpressions;//捕获事件不跳转,回调webViewActionForUrl方法

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

@property (nullable, nonatomic, readonly, strong) NSURLRequest *request;

- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler;

@property (nonatomic) BOOL scalesPageToFit;

#pragma mark - 扩展功能
+(void)setUserAgent:(NSString *)userAgent;//使用之后，需要通过[RSWebView setUserAgent:nil];来恢复
@property (nonatomic, strong) RSWebSource *webSource;
@property (nonatomic, assign,readonly) BOOL isUsingUIWebView;
-(void)loadLocalFile:(NSString *)fileName baseURL:(NSString *)baseURL;
-(void)loadLocalFile:(NSString *)fileName;
#pragma mark - 开关设置
@property(assign, nonatomic) BOOL closeGesture;
@property(assign, nonatomic) BOOL closeProgress;
//@property(assign, nonatomic) BOOL closeAdjustTitle;
@property(assign, nonatomic) BOOL closeAdjustViewport;
//@property(assign, nonatomic) BOOL closeUpdateNavigationItems;
#pragma mark - js交互部分
- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString *)handlerName;
- (void)callHandler:(NSString *)handlerName data:(id)data;
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
+(void)setWebViewType:(RSWebViewType )type;
-(void)updateNavigation;
@end
NS_ASSUME_NONNULL_END
