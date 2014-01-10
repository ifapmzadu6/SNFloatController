//
//  UIViewController+SNFloatController.h
//  SNFloatingViewSample
//
//  Created by nagatashin on 2013/10/22.
//  Copyright (c) 2013年 nagatashin. All rights reserved.
//

#import "UIViewController+SNFloatController.h"

@implementation UIViewController (SNFloatController)

- (SNFloatController *)sn_floatController {
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[SNFloatController class]]){
            return (SNFloatController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

-(CGRect)sn_visibleDrawerFrame {
    if([self isEqual:self.sn_floatController.floatViewController] ||
       [self.navigationController isEqual:self.sn_floatController.floatViewController]){
        CGRect rect = self.sn_floatController.view.bounds;
        //        rect.size.width = self.sn_floatController.maximumLeftDrawerWidth;
        return rect;
    }
    else {
        return CGRectNull;
    }
}

@end
