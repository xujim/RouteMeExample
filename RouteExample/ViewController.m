//
//  ViewController.m
//  RouteExample
//
//  Created by xujian on 15/12/5.
//  Copyright © 2015年 xujian. All rights reserved.
//

#import "ViewController.h"
#import "UIWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor greenColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(50, 150, 300, 60);
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"helloworld" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickMe:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickMe:(id)sender{
    UIWebViewController *view = [[UIWebViewController alloc]init];
    view.htmlFileName = @"index.html";
//    UIViewController *tabCtrl= (UIViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [self presentViewController:view animated:YES completion:nil];
//    [tabCtrl.navigationController pushViewController:view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
