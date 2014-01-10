//
//  FloatViewController.m
//  SNFloatControllerDemo
//
//  Created by nagatashin on 2014/01/08.
//  Copyright (c) 2014年 kokoro100. All rights reserved.
//

#import "FloatViewController.h"

@interface FloatViewController ()
@property UIImageView *imageView;
@end

@implementation FloatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _imageView = [[UIImageView alloc]init];
    _imageView.image = [UIImage imageNamed:@"Fujiyama"];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:_imageView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizesSubviews = true;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor blackColor];
    
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imageView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeImage:(UIImage *)image
{
    _imageView.image = image;
}
@end
