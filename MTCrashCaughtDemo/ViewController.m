//
//  ViewController.m
//  MTCrashCaughtDemo
//
//  Created by zhourongqing on 15/12/30.
//  Copyright © 2015年 mtry. All rights reserved.
//

#import "ViewController.h"
#import "MTCrashCaught.h"

@implementation ViewController

+ (void)load
{
    [MTCrashCaught installCompletionHandler:^(NSString *exceptionDescription, MTResponseCallback responseCallback) {
        NSLog(@"\n%@", exceptionDescription);
        responseCallback();
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    button.center = self.view.center;
    button.backgroundColor = [UIColor brownColor];
    [button setTitle:@"start test" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)touchUpInsideButton:(UIButton *)button
{
    [self test3];
}

- (void)test1
{
    int *s = malloc(10 * sizeof(int));
    free(s);
    free(s);
}

- (void)test2
{
    int a = 1;
    int b = 0;
    b = a / b;
}


- (void)test3
{
    NSArray *array = @[@(1)];
    [array objectAtIndex:1];
}

@end
