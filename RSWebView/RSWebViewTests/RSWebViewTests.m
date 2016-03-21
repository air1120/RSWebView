//
//  RSWebViewTests.m
//  RSWebViewTests
//
//  Created by rason on 16/3/2.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RSWebView.h"
@interface RSWebViewTests : XCTestCase

@end

@implementation RSWebViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
-(void)testyongli{
    RSWebView *webView = [[RSWebView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    webView.webSource = [[RSWebSource alloc] initWithUrl:@"http://192.168.8.131:8088/sdf" method:@"POST" headers:@{@"otherHeaders":@"ceshila",@"user-agent":@"Mozilla/6.4 (iPhone; CPU iPhone OS 9_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13C75"} body:@"sdfsd=2sdf"];
}
- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
