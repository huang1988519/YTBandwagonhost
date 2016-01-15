//
//  ViewController.m
//  HUDDemo
//
//  Created by Dong on 15/5/10.
//  Copyright (c) 2015年 MAGICALBOY. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showLoadingHud {
    [self showHUDWithMessage:@"Loading.."];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:3];
}

- (IBAction)showHintHud {
    [self showHintHudWithMessage:@"Please try again later."];
}


@end
