//
//  BBWebViewSSLProtocol.h
//  BBUIExample
//
//  Created by Arron Zhang on 15/3/16.
//  Copyright (c) 2015年 Arron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBWebViewSSLProtocol : NSURLProtocol

@property (retain,nonatomic) NSURLConnection *connection;
+ (void)addTrustedDomain:(id)domain;
+ (BOOL)isTrustedDomain:(NSString *)domain;
@end
