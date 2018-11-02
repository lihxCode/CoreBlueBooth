//
//  KxControlViewController.m
//  KxCoreBluetoothDemo
//
//  Created by FD on 2018/11/2.
//  Copyright © 2018 FD. All rights reserved.
//

#import "KxControlViewController.h"

@interface KxControlViewController ()

@end

@implementation KxControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    UIButton *sleep = ({
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((w - 80)/2.0, (h - 80)/2.0, 80, 80)];
        [btn addTarget:self action:@selector(sleep) forControlEvents:UIControlEventTouchDown];
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:@"sleep" forState:UIControlStateNormal];
        btn;
    });
    [self.view addSubview:sleep];
    
    UIButton *wakeUp = ({
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((w - 80)/2.0, (h - 80)/2.0 + 100, 80, 80)];
        [btn addTarget:self action:@selector(wakeUp) forControlEvents:UIControlEventTouchDown];
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:@"wakeUp" forState:UIControlStateNormal];
        btn;
    });
    [self.view addSubview:wakeUp];
    
    UIButton *back = ({
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 24, 40, 20)];
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:@"back" forState:UIControlStateNormal];
        btn;
    });
    [self.view addSubview:back];
}

- (void)sleep {
    if ([self.delegate respondsToSelector:@selector(sleep)]) {
        [self.delegate sleep];
    }
}

- (void)wakeUp {
    if ([self.delegate respondsToSelector:@selector(wakeUp)]) {
        [self.delegate wakeUp];
    }
}

- (void)back {
    if ([self.delegate respondsToSelector:@selector(back)]) {
        [self.delegate back];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
