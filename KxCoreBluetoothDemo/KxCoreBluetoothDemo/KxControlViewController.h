//
//  KxControlViewController.h
//  KxCoreBluetoothDemo
//
//  Created by FD on 2018/11/2.
//  Copyright © 2018 FD. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol KxControlViewControllerDelegate<NSObject>
- (void)sleep;

- (void)wakeUp;

- (void)back;
@end
NS_ASSUME_NONNULL_BEGIN

@interface KxControlViewController : UIViewController
@property (nonatomic, weak) id <KxControlViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
