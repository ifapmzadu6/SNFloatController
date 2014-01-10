//
//  AppDelegate.m
//  NSFLoatControllerDemo
//
//  Created by nagatashin on 2014/01/08.
//  Copyright (c) 2014年 kokoro100. All rights reserved.
//

#import "AppDelegate.h"

#import "SNFloatController.h"
#import "FloatViewController.h"
#import "BottomViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    
    UIViewController *floatViewController = [FloatViewController new];
    floatViewController.view.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 180);
    
    UIViewController *bottomViewController = [[BottomViewController alloc]initWithStyle:UITableViewStyleGrouped];
    bottomViewController.view.frame = CGRectMake(rect.origin.x, CGRectGetMaxY(floatViewController.view.frame), rect.size.width, CGRectGetMaxY(rect)-CGRectGetMaxY(floatViewController.view.frame));
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:bottomViewController];
    navigationController.navigationBar.translucent = false;
    navigationController.navigationBar.autoresizingMask = UIViewAutoresizingNone;
    navigationController.title = @"Photos";
    
    SNFloatController *sn_floatController = [[SNFloatController alloc]initWithFloatViewController:floatViewController BottomViewController:navigationController];
    sn_floatController.view.backgroundColor = [UIColor whiteColor];
    sn_floatController.autoAdjustBottomViewControllerTogether = true;
    sn_floatController.moveInteractionSpeed = SNFloatControllerMoveInteractionSpeedFullScreenAdjust;
    
    self.window.rootViewController = sn_floatController;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
