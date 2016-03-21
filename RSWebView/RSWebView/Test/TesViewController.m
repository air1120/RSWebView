//
//  TesViewController.m
//  RSWebView
//
//  Created by rason on 16/3/17.
//  Copyright © 2016年 RasonWu. All rights reserved.
//

#import "TesViewController.h"

@interface TesViewController ()

@end

@implementation TesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self
                                               action:@selector(dismissView:)];
    // Do any additional setup after loading the view from its nib.
}
- (void)dismissView:(id)sender {
    
    // Call the delegate to dismiss the modal view
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
