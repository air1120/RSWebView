//
//  SYViewTools.m
//  ZhiXingHCP
//
//  Created by rason on 5/8/15.
//  Copyright (c) 2015 suanya. All rights reserved.
//

#import "RSControllerTools.h"
@implementation RSControllerTools
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
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
+(id) VCByIndentifier:(NSString *)identifier{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller;
    @try {
        controller  = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    }
    @catch (NSException *exception) {
        controller  = [[UIViewController alloc]init];
        NSLog(@"storyBoard找不到%@",identifier);
    }
    return controller;
}
+(void)pushViewController:(UIViewController *)vc{
    UIViewController *controller = [self getCurrentVC];
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *barController = (UITabBarController *)controller;
        barController.tabBar.hidden = YES;
        [(UINavigationController *)barController.selectedViewController pushViewController:vc animated:YES];
    }
    else{
        controller.tabBarController.tabBar.hidden = YES;
        [(UINavigationController *)controller pushViewController:vc animated:YES];
    }
}
+(void)pushViewControllerWithIndentifier:(NSString *)indentifier{
    UIViewController *vc = [self VCByIndentifier:indentifier];
    UIViewController *controller = [self getCurrentVC];
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *barController = (UITabBarController *)controller;
        barController.tabBar.hidden = YES;
        [(UINavigationController *)barController.selectedViewController pushViewController:vc animated:YES];
    }
    else{
        controller.tabBarController.tabBar.hidden = YES;
        [(UINavigationController *)controller pushViewController:vc animated:YES];
    }
}
@end
