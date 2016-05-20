//
//  SYViewTools.h
//  ZhiXingHCP
//
//  Created by rason on 5/8/15.
//  Copyright (c) 2015 suanya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface RSControllerTools : UIView
+ (UIViewController *)getCurrentVC;
+(id) VCByIndentifier:(NSString *)identifier;
+(void)pushViewController:(UIViewController *)vc;
+(void)pushViewControllerWithIndentifier:(NSString *)indentifier;

@end
