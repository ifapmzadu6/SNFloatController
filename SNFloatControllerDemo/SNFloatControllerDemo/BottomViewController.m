//
//  BottomViewController.m
//  SNFloatControllerDemo
//
//  Created by nagatashin on 2014/01/08.
//  Copyright (c) 2014年 kokoro100. All rights reserved.
//

#import "BottomViewController.h"

#import "UIViewController+SNFloatController.h"
#import "FloatViewController.h"

@interface BottomViewController ()
@property (nonatomic) NSArray *items;
@property (nonatomic) NSArray *controls;
@end

@implementation BottomViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizesSubviews = true;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    
    self.tableView.autoresizesSubviews = true;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _items = @[
               @"Fujiyama",
               @"Mountain Range",
               @"Beach",
               @"Galaxy",
               @"Lake"];
    _controls = @[
                   @"Top",
                   @"Bar",
                   @"Full",
                   ];
    
    [self.tableView  registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0)?@"Photos":@"controls";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0)?_items.count:_controls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = (indexPath.section == 0)
    ?_items[indexPath.row]:_controls[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSInteger floatPosition = indexPath.row + 3;
        [self.sn_floatController moveToPosition:floatPosition animated:true completion:nil];
    }
    else if (indexPath.section == 0)
    {
        NSString *s = _items[indexPath.row];
        UIImage *image = [UIImage imageNamed:s];
        
        SNFloatController *sn_floatController = self.sn_floatController;
        UIViewController *viewController = sn_floatController.floatViewController;
        
        if ([[viewController class]isSubclassOfClass:[FloatViewController class]]) {
            FloatViewController *floatViewController = (FloatViewController *)viewController;
            [floatViewController changeImage:image];
            [sn_floatController moveToPosition:SNFloatControllerPositionTop animated:true completion:nil];
        }
    }
}

@end
