//
//  UIViewController+SNFloatController.m
//  SNFloatingViewSample
//
//  Created by nagatashin on 2013/10/22.
//  Copyright (c) 2013年 nagatashin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNFloatController.h"

@interface UIViewController (SNFloatController)

@property(nonatomic, strong, readonly)  SNFloatController *sn_floatController;

@property(nonatomic, assign, readonly) CGRect sn_visibleDrawerFrame;

@end