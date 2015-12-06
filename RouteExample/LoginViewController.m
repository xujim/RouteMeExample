//
//  LoginViewController.m
//  RouteExample
//
//  Created by xujian on 15/12/5.
//  Copyright © 2015年 xujian. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 200, 200)];
    label.text = @"hello, login";
    [self.view addSubview:label];
}
@end
