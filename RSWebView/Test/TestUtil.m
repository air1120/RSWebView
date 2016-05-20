//
//  TestUtil.m
//  RSWebView
//
//  Created by rason on 16/3/21.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import "TestUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation TestUtil
static NSMutableArray*names;
+(void)loadMethod{
    unsigned int count;
    NSMutableArray *array = [NSMutableArray array];
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        //        if ([name hasPrefix:@"test"])
        NSLog(@"方法 名字 ==== %@",name);
        
        if ([name hasPrefix:@"Test"])
        {
            [array addObject:name];
            //avoid arc warning by using c runtime
            //            objc_msgSend(self, selector);
        }
        
        NSLog(@"Test '%@' completed successfuly", [name substringFromIndex:4]);
    }
    names = array;
}
-(NSArray *)methodNames{
    return names;
}
@end
