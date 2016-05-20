//
//  TestUtil.h
//  RSWebView
//
//  Created by rason on 16/3/21.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestUtil : NSObject
@property (nonatomic, strong) NSArray *methodNames;
+(void)loadMethod;
@end
