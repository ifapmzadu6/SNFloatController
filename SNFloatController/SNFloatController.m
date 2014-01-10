//
//  SNFloatController.m
//  SNFloatingViewSample
//
//  Created by nagatashin on 2013/10/22.
//  Copyright (c) 2013年 nagatashin. All rights reserved.
//

#import "SNFloatController.h"
#import "UIViewController+SNFloatController.h"

const CGFloat SNFloatControllerFloatPositionAspectRatio = 180.f/320.f;
const CGFloat SNFloatControllerBarPositionAspectRatio = 90.f/320.f;
const CGFloat SNFloatControllerDefaultAnimationVeocity = 840.0f;

const CGFloat SNFloatControllerPanVelocityXAnimationThreshold = 2000.0f;
const CGFloat SNFloatControllerPanVelocityYAnimationThreshold = 200.0f;


const NSTimeInterval SNFloatControllerMinimumAnimationDuration = 0.15f;


#pragma mark - SNFloatContentContainerView
@interface SNFloatContainerView : UIView
@property (nonatomic) SNFloatControllerFloatInteractionMode floatInteractionMode;
@property (nonatomic) SNFloatControllerPosition position;
@end

@implementation SNFloatContainerView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView && _position != SNFloatControllerPositionNone){
        if(self.floatInteractionMode == SNFloatControllerFloatInteractionModeNone){
            hitView = nil; //ViewのFloatViewの操作を無効にする
        }
    }
    return hitView;
}
@end


#pragma mark - SNMidleContentContainerView
@interface SNMidleContainerView : UIView
@end

@implementation SNMidleContainerView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView && hitView == self)
        hitView = nil;
    return hitView;
}
@end


#pragma mark - SNFloatContentContainerView
@interface SNBottomContainerView : UIView
@property (nonatomic, readwrite) SNFloatControllerPosition floatPosition;
@property (nonatomic, readwrite) SNFloatControllerPosition floatToPosition;
@property (nonatomic) SNFloatControllerBottomInteractionMode bottomInteractionMode;
@end

@implementation SNBottomContainerView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView){
        if(self.bottomInteractionMode == SNFloatControllerBottomInteractionModeNone){
            hitView = nil;
        }
    }
    return hitView;
}
@end


#pragma mark SNFloatController
@interface SNFloatController ()<UIGestureRecognizerDelegate>
@property (nonatomic, readwrite) SNFloatControllerPosition floatPosition;
@property (nonatomic, readwrite) SNFloatControllerPosition floatToPosition;
@property (nonatomic) BOOL isConstrainToVertical;
@property (nonatomic) BOOL isConstrainToHorizontal;
@property (nonatomic, readwrite) BOOL isAnimatingDrawerController;

@property (nonatomic, strong) UIView * childControllerContainerView;
@property (nonatomic, strong) UIView *floatContainerViewBackView;
@property (nonatomic, strong) SNFloatContainerView *floatContainerView;
@property (nonatomic, strong) SNBottomContainerView *bottomContainerView;

@property (nonatomic) SNFloatControllerPosition startingPanPosition;
@property (nonatomic) CGRect startingPanRect;
@property (nonatomic) SNFloatControllerPosition tmpPosition;
@end

@implementation SNFloatController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        [self commonSetup];
	}
	return self;
}

- (id)initWithFloatViewController:(UIViewController *)floatViewController BottomViewController:(UIViewController *)bottomViewController
{
    self = [super init];
    if (self) {
        [self setFloatViewController:floatViewController];
        [self setBottomViewController:bottomViewController];
    }
    return self;
}

-(void)commonSetup{
    [self setFloatControllerTopOriginPoint:CGPointMake(0.f, 20.f)];
    
    self.view.autoresizesSubviews = true;
    _isConstrainToHorizontal = false;
    _isConstrainToHorizontal = false;
    _isAnimatingDrawerController = false;
    
    _panProgress = 0.f;
    [self setAnimationVelocity:SNFloatControllerDefaultAnimationVeocity];
    
    [self setIsMoveWithAlpha:true];
    [self setAutoAdjustBottomViewController:true];
    [self setAutoAdjustBottomViewControllerTogether:false];
    [self setIsEnableMove:true];
    [self setIsEnableRotate:true];
    
    [self setFloatPosition:SNFloatControllerPositionNone];
    [self setFloatInteractionMode:SNFloatControllerFloatInteractionModeFull];
    [self setBottomInteractionMode:SNFloatControllerBottomInteractionModeFull];
    [self setMoveInteractionMode:SNFloatControllerMoveInteractionModeOnlyFloatView];
    [self setMoveInteractionSpeed:SNFloatControllerMoveInteractionSpeedFullScreenAdjust];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.bottomViewController beginAppearanceTransition:YES animated:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.bottomViewController endAppearanceTransition];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.bottomViewController beginAppearanceTransition:NO animated:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.bottomViewController endAppearanceTransition];
}

#pragma mark - Rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        _isEnableMove = false;
        _tmpPosition = _floatPosition;
        [self moveToPosition:SNFloatControllerPositionFullScreen animated:false completion:nil];
    }
    else
        _isEnableMove = true;
    
    [self.floatContainerView layoutSubviews];
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self moveToPosition:_tmpPosition animated:true completion:nil];
    }
}

- (BOOL)shouldAutorotate
{
    if (_isAnimatingDrawerController || !_isEnableRotate)
        return false;
    return [_floatViewController shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [_floatViewController preferredInterfaceOrientationForPresentation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [_floatViewController supportedInterfaceOrientations];
}

#pragma mark - Updating the Bottom View Controller
-(void)setBottomViewController:(UIViewController *)bottomViewController{
    [self setBottomViewController:bottomViewController animated:NO];
}

-(void)setBottomViewController:(UIViewController *)bottomViewController animated:(BOOL)animated{
    UIViewController * oldBottomViewController = self.bottomViewController;
    if(oldBottomViewController){
        if(animated == NO){
            [oldBottomViewController beginAppearanceTransition:NO animated:NO];
        }
        [oldBottomViewController removeFromParentViewController];
        [oldBottomViewController.view removeFromSuperview];
        if(animated == NO){
            [oldBottomViewController endAppearanceTransition];
        }
    }
    
    _bottomViewController = bottomViewController;
    
    [self addChildViewController:self.bottomViewController];
    
    [self.bottomViewController.view setFrame:self.childControllerContainerView.bounds];
    [self.bottomContainerView addSubview:bottomViewController.view];
    [self.bottomViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    if(animated == NO){
        [self.bottomViewController beginAppearanceTransition:YES animated:NO];
        [self.bottomViewController endAppearanceTransition];
        [self.bottomViewController didMoveToParentViewController:self];
    }
    
    //画面のサイズの初期化
    CGRect frame = [UIScreen mainScreen].bounds;
    [self setViewControllerFrame:SNFloatControllerViewControllersBottom frame:frame animated:NO];
}

#pragma mark - Setters

- (SNFloatContainerView *)floatContainerView
{
    if(_floatContainerView == nil){
        self.floatContainerViewBackView = [[UIView alloc]initWithFrame:[self frameForPosition:self.floatPosition]];
        [self.floatContainerViewBackView setAutoresizesSubviews:true];
        self.floatContainerViewBackView.clipsToBounds = true;
        [self.floatContainerViewBackView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
        self.floatContainerViewBackView.opaque = YES;
        self.floatContainerViewBackView.backgroundColor = [UIColor whiteColor];
        
        _floatContainerView = [[SNFloatContainerView alloc] initWithFrame:self.floatContainerViewBackView.bounds];
        [_floatContainerView setAutoresizesSubviews:true];
        _floatContainerView.clipsToBounds = true;
        [_floatContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];

        _floatContainerView.opaque = YES;
        _floatContainerView.backgroundColor = [UIColor whiteColor];
        [_floatContainerView setFloatInteractionMode:self.floatInteractionMode];
        [self.childControllerContainerView addSubview:self.floatContainerViewBackView];
        [self.floatContainerViewBackView addSubview:_floatContainerView];
    }
    return _floatContainerView;
}

- (SNBottomContainerView *)bottomContainerView
{
    if(_bottomContainerView == nil){
        _bottomContainerView = [[SNBottomContainerView alloc] initWithFrame:self.childControllerContainerView.bounds];
        _bottomContainerView.autoresizesSubviews = true;
        [_bottomContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
        //背景をopaqueに。狩宿
        _bottomContainerView.opaque = YES;
        _bottomContainerView.backgroundColor = [UIColor whiteColor];
        [_bottomContainerView setBottomInteractionMode:self.bottomInteractionMode];
        (_floatContainerView)
        ?[self.childControllerContainerView insertSubview:_bottomContainerView belowSubview:self.floatContainerViewBackView]
        :[self.childControllerContainerView addSubview:_bottomContainerView];
    }
    return _bottomContainerView;
}

- (void)setViewControllerFrame:(SNFloatControllerViewControllers)controller frame:(CGRect)frame animated:(bool)animated
{
    UIView *view = [self contentViewForVC:controller];
    if (animated)
    {
        [UIView animateWithDuration:0.333f delay:0.0f options:(7 << 16) animations:^{
            view.frame = frame;
        } completion:nil];
    }
    else
        view.frame = frame;
}

- (void)setMoveInteractionMode:(SNFloatControllerMoveInteractionMode)moveInteractionMode
{
    if (moveInteractionMode == _moveInteractionMode)
        return;
    
    UIView *oldView = [self viewForSNFloatControllerMoveInteractionMode:_moveInteractionMode];
    if (oldView) {
        for (UIGestureRecognizer *recognizer in oldView.gestureRecognizers) {
            [oldView removeGestureRecognizer:recognizer];
        }
    }
    
    UIView *newView = [self viewForSNFloatControllerMoveInteractionMode:moveInteractionMode];
    if (newView) {
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
        [pan setDelegate:self];
        [newView addGestureRecognizer:pan];
    }
    
    _moveInteractionMode = moveInteractionMode;
}

- (void)setCustomMoveInteractionView:(UIView *)customMoveInteractionView
{
    if (self.customMoveInteractionView)
        for (UIGestureRecognizer *gesture in self.customMoveInteractionView.gestureRecognizers)
            [self.customMoveInteractionView removeGestureRecognizer:gesture];
    
    if (customMoveInteractionView) {
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
        [pan setDelegate:self];
        [customMoveInteractionView addGestureRecognizer:pan];
    }
    
    _customMoveInteractionView = customMoveInteractionView;
    _moveInteractionMode = SNFloatControllerMoveInteractionModeCustom;
}

#pragma mark - Updating the Float View Controller
- (void)setFloatViewController:(UIViewController *)floatViewController
{
    [self setFloatViewController:floatViewController withPosition:SNFloatControllerPositionTop];
}

- (void)setFloatViewController:(UIViewController *)floatViewController withPosition:(SNFloatControllerPosition)position
{
    [self setFloatViewController:floatViewController withPosition:position animated:NO];
}

- (void)setFloatViewController:(UIViewController *)viewController withPosition:(SNFloatControllerPosition)position animated:(BOOL)animated
{
    [self.floatContainerView setPosition:position];
    
    UIViewController * oldFloatViewController = self.floatViewController;
    if(oldFloatViewController){
        if(animated == NO){
            [oldFloatViewController beginAppearanceTransition:NO animated:NO];
        }
        [oldFloatViewController removeFromParentViewController];
        [oldFloatViewController.view removeFromSuperview];
        if(animated == NO){
            [oldFloatViewController endAppearanceTransition];
        }
    }
    
    _floatViewController = viewController;
    
    [self addChildViewController:self.floatViewController];
    [self.floatViewController.view setFrame:self.floatContainerViewBackView.bounds];
    [self.floatContainerView addSubview:self.floatViewController.view];
    [self.childControllerContainerView bringSubviewToFront:self.floatContainerView];
    [self.floatViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    if(animated == NO){
        [self.floatViewController beginAppearanceTransition:YES animated:NO];
        [self.floatViewController endAppearanceTransition];
        [self.floatViewController didMoveToParentViewController:self];
    }
}

-(UIView*)childControllerContainerView{
    if(_childControllerContainerView == nil){
        _childControllerContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
        //背景をopaqueに。狩宿
        _childControllerContainerView.opaque = YES;
        _childControllerContainerView.backgroundColor = [UIColor whiteColor];
        [_childControllerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.view addSubview:_childControllerContainerView];
    }
    return _childControllerContainerView;
}

#pragma mark - Helper
- (UIView *)contentViewForVC:(SNFloatControllerViewControllers)controller
{
    switch (controller) {
        case SNFloatControllerViewControllersFloat:
            return _floatContainerView;
        case SNFloatControllerViewControllersBottom:
            return _bottomContainerView;
        default:
            return nil;
    }
}

- (CGRect)frameForPosition:(SNFloatControllerPosition)position
{
    CGRect frame = _childControllerContainerView.bounds;
    
    CGFloat w = CGRectGetWidth(frame);
    CGFloat mw = w;// MIN(w, CGRectGetHeight(frame));
    CGFloat h = ceilf(mw * SNFloatControllerFloatPositionAspectRatio);
    
    switch (position) {
        case SNFloatControllerPositionNone:
            return CGRectMake(w, 0, w, h);
        case SNFloatControllerPositionTop:
            return CGRectMake(0, 20, w, h);
        case SNFloatControllerPositionBar:
            return CGRectMake(0, 20, w, ceilf(mw*SNFloatControllerBarPositionAspectRatio));
        case SNFloatControllerPositionFullScreen:
        {
            return CGRectMake(0, 0, w, CGRectGetHeight(frame));
        }
        case SNFloatControllerPositionRightOutScreen:
            return CGRectMake(w, 20, w, h);
        case SNFloatControllerPositionLeftOutScreen:
            return CGRectMake(-w, 20, w, h);
        default:
            return CGRectZero;
    }
}

-(CGPoint)roundedOriginWithProgress:(CGFloat)progress{
    CGPoint origin;
    
    CGRect fromFrame = [self frameForPosition:self.floatPosition];
    CGRect toFrame = [self frameForPosition:self.floatToPosition];
    
    CGFloat fromX = fromFrame.origin.x;
    CGFloat toX = toFrame.origin.x;
    CGFloat fromY = fromFrame.origin.y;
    CGFloat toY = toFrame.origin.y;
    
    origin.y = fromY + (toY - fromY)*progress;
    origin.x = fromX + (toX - fromX)*progress;
    
    return origin;
}

-(CGSize)roundedSizeWithProgress:(CGFloat)progress
{
    CGSize size;
    
    CGRect fromFrame = [self frameForPosition:self.floatPosition];
    CGRect toFrame = [self frameForPosition:self.floatToPosition];
    
    CGFloat fromW = fromFrame.size.width;
    CGFloat toW = toFrame.size.width;
    CGFloat fromH = fromFrame.size.height;
    CGFloat toH = toFrame.size.height;
    
    size.height = fromH + (toH - fromH)*progress;
    size.width = fromW + (toW - fromW)*progress;
    
    return size;
}

- (CGFloat)alphaForMovingWithProgress:(CGFloat)progress fromPosition:(SNFloatControllerPosition)fromPosition toPosition:(SNFloatControllerPosition)toPosition
{
    if (toPosition == SNFloatControllerPositionNone
        || toPosition == SNFloatControllerPositionLeftOutScreen
        || toPosition == SNFloatControllerPositionRightOutScreen)
    {
        return 1.f-progress;
    }
    else
        return 1.f;
}

- (CGFloat)lenghtBetweenPositionWithFomPosotion:(SNFloatControllerPosition)fromPosotion toPosition:(SNFloatControllerPosition)toPosition
{
    CGRect fromFrame = [self frameForPosition:fromPosotion];
    CGRect toFrame = [self frameForPosition:toPosition];
    if (toPosition == SNFloatControllerPositionRightOutScreen || toPosition == SNFloatControllerPositionLeftOutScreen) {
        return ABS(toFrame.origin.x - fromFrame.origin.x);
    }
    else
    {
        CGFloat x = (CGRectGetMaxX(toFrame)-CGRectGetMinX(toFrame)) - CGRectGetMaxX(fromFrame)-CGRectGetMinX(fromFrame);
        CGFloat y = (CGRectGetMaxY(toFrame)-CGRectGetMinY(toFrame)) - CGRectGetMaxY(fromFrame)-CGRectGetMinY(fromFrame);
        return MAX(ABS(x), ABS(y));
    }
}

- (CGFloat)movingProgressWithTransition:(CGPoint)transition
{
    CGFloat distance = [self lenghtBetweenPositionWithFomPosotion:self.floatPosition toPosition:self.floatToPosition];
    
    CGFloat coefficient = 1.f;
    if (_moveInteractionSpeed == SNFloatControllermoveInteractionSpeedTopViewControllerAdjust) {
        CGFloat fullH = [self frameForPosition:SNFloatControllerPositionFullScreen].size.height;
        CGFloat h = [self frameForPosition:SNFloatControllerPositionTop].size.height;
        coefficient = fullH/h;
    }
    
    switch (self.floatPosition) {
        case SNFloatControllerPositionTop:
        {
            switch (self.floatToPosition) {
                case SNFloatControllerPositionBar:
                    return -transition.y / distance;
                case SNFloatControllerPositionFullScreen:
                    return transition.y*coefficient / distance;
                case SNFloatControllerPositionRightOutScreen:
                    return transition.x / distance;
                case SNFloatControllerPositionLeftOutScreen:
                    return -transition.x / distance;
                default:
                    return 0.f;
            }
        }break;
        case SNFloatControllerPositionFullScreen:
        {
            if (self.floatToPosition == SNFloatControllerPositionTop) {
                return -transition.y*coefficient / distance;
            }
            else if (self.floatToPosition == SNFloatControllerPositionFullScreen) {
                return 1.f +transition.y*coefficient / [self frameForPosition:SNFloatControllerPositionFullScreen].size.height;
            }
        }break;
        case SNFloatControllerPositionBar:
        {
            if (self.floatToPosition == SNFloatControllerPositionTop) {
                return transition.y / distance;
            }
        }break;
        default:
            return 0.f;
    }
    return 0.f;
}

- (UIView *)viewForSNFloatControllerMoveInteractionMode:(SNFloatControllerMoveInteractionMode)moveInteractionMode
{
    switch (moveInteractionMode) {
        case SNFloatControllerMoveInteractionModeNone:
            return nil;
        case SNFloatControllerMoveInteractionModeOnlyFloatView:
            return self.floatContainerView;
        case SNFloatControllerMoveInteractionModeCustom:
            return self.customMoveInteractionView;
        case SNFloatControllerMoveInteractionModeFull:
            return self.view;
    }
}

- (BOOL)isAppearingFloatView
{
    return (self.floatPosition == SNFloatControllerPositionTop ||
            self.floatPosition == SNFloatControllerPositionBar ||
            self.floatPosition == SNFloatControllerPositionFullScreen);
}

- (bool)isMovingBetweenPosition:(SNFloatControllerPosition)position1 andPosition:(SNFloatControllerPosition)position2
{
    return ((self.floatPosition == position1) && (self.floatToPosition == position2))
    || ((self.floatPosition == position2) && (self.floatToPosition == position1));
}

- (BOOL)prefersStatusBarHidden
{
    return (self.floatPosition == SNFloatControllerPositionFullScreen || self.floatToPosition == SNFloatControllerPositionFullScreen);
}

#pragma mark - UINavigationController Helper
- (void)adjustNavigationController
{
    if ([[_bottomViewController class]isSubclassOfClass:[UINavigationController class]]) {
        CGFloat w = self.childControllerContainerView.bounds.size.width;
        UINavigationController *navigationController = (UINavigationController *)_bottomViewController;
        
        switch (self.floatPosition) {
            case SNFloatControllerPositionNone:
            case SNFloatControllerPositionLeftOutScreen:
            case SNFloatControllerPositionRightOutScreen:
            {
                navigationController.navigationBar.frame = (self.floatToPosition != SNFloatControllerPositionTop)
                ? CGRectMake(0, 0, w, 64) : CGRectMake(0, -20, w, 64);
                break;
            }
            default:
                navigationController.navigationBar.frame = CGRectMake(0, -20, w, 64);
                break;
        }
    }
}

#pragma mark - Animation Helper
-(void)finishAnimationForPanGestureWithVelocity:(CGPoint)velocity progress:(CGFloat)progress completion:(void(^)(BOOL finished))completion{
    CGFloat animationVelocityX = MAX(ABS(velocity.x),SNFloatControllerPanVelocityYAnimationThreshold*2);
    CGFloat animationVelocityY = MAX(ABS(velocity.y),SNFloatControllerPanVelocityYAnimationThreshold*2);
    UIViewAnimationOptions animationOption = 7<<16;
    
    if (self.floatToPosition == SNFloatControllerPositionNone) {
        [self moveToPosition:self.floatPosition animated:YES completion:completion];
    }
    else if(self.floatPosition == SNFloatControllerPositionTop) {
        if (self.floatToPosition == SNFloatControllerPositionFullScreen) {
            if(velocity.y > SNFloatControllerPanVelocityYAnimationThreshold){
                [self moveToPosition:self.floatToPosition animated:YES velocity:animationVelocityY animationOptions:animationOption completion:completion];
                
            }
            else if(progress > 0.5){
                [self moveToPosition:SNFloatControllerPositionFullScreen animated:YES completion:completion];
            }
            
            else {
                [self moveToPosition:SNFloatControllerPositionTop animated:YES completion:completion];
            }
        }
        else if (self.floatToPosition == SNFloatControllerPositionBar) {
            if(velocity.y < -SNFloatControllerPanVelocityYAnimationThreshold){
                [self moveToPosition:self.floatToPosition animated:YES velocity:animationVelocityY animationOptions:animationOption completion:completion];
                
            }
            else if(progress > 0.5){
                [self moveToPosition:SNFloatControllerPositionBar animated:YES completion:completion];
            }
            
            else {
                [self moveToPosition:SNFloatControllerPositionTop animated:YES completion:completion];
            }
        }
        
        else if(self.floatToPosition == SNFloatControllerPositionRightOutScreen)
        {
            if(velocity.x > SNFloatControllerPanVelocityXAnimationThreshold){
                [self moveToPosition:self.floatToPosition animated:YES velocity:animationVelocityX animationOptions:animationOption completion:completion];
            }
            else if(progress > 0.5){
                [self moveToPosition:SNFloatControllerPositionRightOutScreen animated:YES completion:completion];
            }
            else {
                [self moveToPosition:SNFloatControllerPositionTop animated:YES completion:completion];
            }
        }
        
        else if(self.floatToPosition == SNFloatControllerPositionLeftOutScreen)
        {
            if(velocity.x < -SNFloatControllerPanVelocityXAnimationThreshold){
                [self moveToPosition:self.floatToPosition animated:YES velocity:animationVelocityX animationOptions:animationOption completion:completion];
            }
            else if(progress > 0.5){
                [self moveToPosition:SNFloatControllerPositionLeftOutScreen animated:YES completion:completion];
            }
            else {
                [self moveToPosition:SNFloatControllerPositionTop animated:YES completion:completion];
            }
        }
    }
    else if(self.floatPosition == SNFloatControllerPositionFullScreen){
        if (self.floatToPosition == SNFloatControllerPositionTop) {
            if(velocity.y < -SNFloatControllerPanVelocityYAnimationThreshold){
                [self moveToPosition:self.floatToPosition animated:YES velocity:animationVelocityY animationOptions:animationOption completion:completion];
            }
            else if (progress > 0.5)
                [self moveToPosition:self.floatToPosition animated:YES completion:completion];
            else {
                [self moveToPosition:SNFloatControllerPositionFullScreen animated:YES completion:completion];
            }
        }
        else if(self.floatToPosition == SNFloatControllerPositionFullScreen)
        {
            [self moveToPosition:SNFloatControllerPositionFullScreen animated:YES completion:completion];
        }
    }
    else if(self.floatPosition == SNFloatControllerPositionBar)
    {
        if (self.floatToPosition == SNFloatControllerPositionTop) {
            if(velocity.y > SNFloatControllerPanVelocityYAnimationThreshold){
                [self moveToPosition:self.floatToPosition animated:YES velocity:animationVelocityY animationOptions:animationOption completion:completion];
                
            }
            else if(progress > 0.5){
                [self moveToPosition:SNFloatControllerPositionTop animated:YES completion:completion];
            }
            
            else {
                [self moveToPosition:SNFloatControllerPositionBar animated:YES completion:completion];
            }
        }
        else if(self.floatToPosition == SNFloatControllerPositionBar)
        {
            [self moveToPosition:SNFloatControllerPositionBar animated:YES completion:completion];
        }
    }
    else {
        if(completion){
            completion(NO);
        }
    }
}

-(void)updateFloatViewWithPercentMoving:(CGFloat)percentMoving{
    if(self.floatMovingStateBlock){
        self.floatMovingStateBlock(self, self.floatPosition, percentMoving);
    }
}

- (void)adjustBottomViewControllerWithAnimated:(BOOL)animated floatPosition:(SNFloatControllerPosition)position
{
    CGRect frame = _childControllerContainerView.bounds;
    CGRect bottomFrame = frame;
    CGRect floatFrame = [self frameForPosition:position];
    
    switch (position) {
        case SNFloatControllerPositionNone:
            [self setViewControllerFrame:SNFloatControllerViewControllersBottom frame:frame animated:animated];
            break;
        case SNFloatControllerPositionTop:
        case SNFloatControllerPositionBar:
        {
            bottomFrame.origin.y = CGRectGetMaxY(floatFrame) ;
            bottomFrame.size.height = frame.size.height - CGRectGetMaxY(floatFrame);
            [self setViewControllerFrame:SNFloatControllerViewControllersBottom frame:bottomFrame animated:animated];
        }break;
        case SNFloatControllerPositionFullScreen:
        case SNFloatControllerPositionLeftOutScreen:
        case SNFloatControllerPositionRightOutScreen:
        {
            [self setViewControllerFrame:SNFloatControllerViewControllersBottom frame:frame animated:animated];
        }break;
        default:
            break;
    }
}

#pragma mark - Gesture Handlers
-(void)panGestureCallback:(UIPanGestureRecognizer *)panGesture
{
    if (!_isEnableMove)
        return;
    
    _isAnimatingDrawerController = true;
    CGPoint translatedPoint = [panGesture translationInView:self.floatContainerView];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            _isAnimatingDrawerController = true;
            _panProgress = 0.f;
            self.startingPanRect = self.floatContainerViewBackView.bounds;
            self.startingPanPosition = self.floatPosition;
            self.floatToPosition = [self toMovePosotionWithoutoutConstrain:CGSizeMake(translatedPoint.x, translatedPoint.y)];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            
        case UIGestureRecognizerStateChanged:{
            CGPoint translatedPoint = [panGesture translationInView:self.floatContainerViewBackView];
            _floatToPosition = [self toMovePosotionWithConstrain:CGSizeMake(translatedPoint.x, translatedPoint.y)];
            
            if (_floatToPosition == SNFloatControllerPositionNone) {
                return;
            }
            CGFloat progress = [self movingProgressWithTransition:translatedPoint];
            
            progress = (progress > 1.f) ?  1.f : progress;
            progress = (progress < 0.f) ?  0.f : progress;
            
            _panProgress = progress;
            
            CGRect newFrame = self.startingPanRect;
            
            newFrame.origin = [self roundedOriginWithProgress:progress];
            newFrame.size = [self roundedSizeWithProgress:progress];
            
            
            self.floatContainerView.alpha = [self alphaForMovingWithProgress:progress fromPosition:self.floatPosition toPosition:self.floatToPosition];
            self.floatContainerViewBackView.frame = CGRectIntegral(newFrame);// newFrame;
            
            CGRect appFrame = self.view.bounds;
            
            if ( ((self.floatPosition == SNFloatControllerPositionTop) && (self.floatToPosition == SNFloatControllerPositionBar)) ||
                ((self.floatPosition == SNFloatControllerPositionBar) && (self.floatToPosition == SNFloatControllerPositionTop)))
                self.bottomContainerView.frame = CGRectMake(0, CGRectGetMaxY(newFrame), newFrame.size.width, CGRectGetHeight(appFrame)-CGRectGetMaxY(newFrame));
            [self updateFloatViewWithPercentMoving:progress];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        {
            _isAnimatingDrawerController = false;
            self.startingPanRect = CGRectNull;
            CGPoint translatedPoint = [panGesture translationInView:self.floatContainerViewBackView];
            CGPoint velocity = [panGesture velocityInView:self.floatContainerViewBackView];
            CGFloat progress = [self movingProgressWithTransition:translatedPoint];
            progress = (progress > 1.f) ?  1.f : progress;
            progress = (progress < 0.f) ?  0.f : progress;
            [self finishAnimationForPanGestureWithVelocity:velocity progress:progress completion:^(BOOL finished) {
                _isAnimatingDrawerController = false;
                if(self.gestureCompletionBlock){
                    self.gestureCompletionBlock(self, panGesture);
                }
                _panProgress = 0.f;
            }];
            break;
        }
        default:break;
    }
}

- (SNFloatControllerPosition)toMovePosotionWithConstrain:(CGSize)translationSize
{
    SNFloatControllerPosition toMovePosition = SNFloatControllerPositionNone;
    CGFloat xOffset = translationSize.width;
    CGFloat yOffset = translationSize.height;
    
    if (self.floatToPosition == SNFloatControllerPositionNone) {
        return [self toMovePosotionWithoutoutConstrain:translationSize];
    }
    
    switch (self.floatPosition) {
        case SNFloatControllerPositionTop:
        {
            if (self.floatToPosition == SNFloatControllerPositionLeftOutScreen
                | self.floatToPosition == SNFloatControllerPositionRightOutScreen)
            {
                if(xOffset > 0)
                {
                    toMovePosition = SNFloatControllerPositionRightOutScreen;
                }
                else {
                    toMovePosition = SNFloatControllerPositionLeftOutScreen;
                }
            }
            else if(self.floatToPosition == SNFloatControllerPositionFullScreen)
            {
                if(yOffset > 0){
                    toMovePosition = SNFloatControllerPositionFullScreen;
                }
                else {
                    toMovePosition = SNFloatControllerPositionBar;
                }
            }
            else if (self.floatToPosition == SNFloatControllerPositionBar)
            {
                if(yOffset < 0){
                    toMovePosition = SNFloatControllerPositionBar;
                }
                else {
                    toMovePosition = SNFloatControllerPositionFullScreen;
                }
            }
        }break;
        case SNFloatControllerPositionFullScreen:
        {
            if (self.floatToPosition == SNFloatControllerPositionTop) {
                if(yOffset > 0){
                    toMovePosition = SNFloatControllerPositionNone;
                }
                else if(yOffset < 0){
                    toMovePosition = SNFloatControllerPositionTop;
                }
            }
            else if(self.floatToPosition == SNFloatControllerPositionFullScreen)
            {
                if (yOffset > 0) {
                    toMovePosition = SNFloatControllerPositionFullScreen;
                }
                else {
                    toMovePosition = SNFloatControllerPositionTop;
                }
            }
        }break;
        case SNFloatControllerPositionBar:
        {
            if (self.floatToPosition == SNFloatControllerPositionTop) {
                if(yOffset > 0){
                    toMovePosition = SNFloatControllerPositionTop;
                }
                else if(yOffset < 0){
                    toMovePosition = SNFloatControllerPositionNone;
                }
            }
        }break;
        default:
            break;
    }
    return toMovePosition;
}

- (SNFloatControllerPosition)toMovePosotionWithoutoutConstrain:(CGSize)translationSize
{
    SNFloatControllerPosition toMovePosition = SNFloatControllerPositionNone;
    CGFloat xOffset = translationSize.width;
    CGFloat yOffset = translationSize.height;
    
    CGFloat xOffsetAbs = abs(xOffset);
    CGFloat yOffsetAbs = abs(yOffset);
    //移動量が小さすぎたら無視
    if (xOffsetAbs < 1.f && yOffsetAbs < 1.f) {
        _isConstrainToHorizontal = false;
        _isConstrainToVertical = false;
        return toMovePosition;
    }
    
    switch (self.floatPosition) {
        case SNFloatControllerPositionTop:
            if ((yOffsetAbs > xOffsetAbs)) {
                if(yOffset > 0){
                    toMovePosition = SNFloatControllerPositionFullScreen;
                }
                else {
                    toMovePosition = SNFloatControllerPositionBar;
                }
            }
            else
            {
                if(xOffset > 0){
                    toMovePosition = SNFloatControllerPositionRightOutScreen;
                }
                else {
                    toMovePosition = SNFloatControllerPositionLeftOutScreen;
                }
            }
            break;
        case SNFloatControllerPositionFullScreen:
            if(yOffset > 0){
                toMovePosition = SNFloatControllerPositionFullScreen;
            }
            else if(yOffset < 0){
                toMovePosition = SNFloatControllerPositionTop;
            }
            break;
        case SNFloatControllerPositionBar:
            if (yOffset > 0) {
                toMovePosition = SNFloatControllerPositionTop;
            }
            break;
        default:
            break;
    }
    return toMovePosition;
}

#pragma mark - Open/Close methods
-(void)moveToPosition:(SNFloatControllerPosition)floatPosition animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    [self moveToPosition:floatPosition animated:animated velocity:self.animationVelocity animationOptions:7<<16 completion:completion];
}

-(void)moveToPosition:(SNFloatControllerPosition)floatPosition  animated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion
{
    _isAnimatingDrawerController = animated;
    
    if(self.floatViewController){
        CGRect newFrame = [self frameForPosition:floatPosition];
        CGRect oldFrame = self.floatContainerViewBackView.bounds;
        
        CGFloat distance = 100.f;
        
        if( self.floatPosition == SNFloatControllerPositionTop)
        {
            if (floatPosition == SNFloatControllerPositionFullScreen)
                distance = (ABS(oldFrame.size.height-newFrame.size.height));
            else if (floatPosition == SNFloatControllerPositionLeftOutScreen | floatPosition == SNFloatControllerPositionRightOutScreen)
            {
                distance = ABS(oldFrame.origin.x-newFrame.origin.x);
            }
        }
        else if (self.floatPosition == SNFloatControllerPositionFullScreen)
        {
            if (floatPosition == SNFloatControllerPositionTop) {
                distance = (ABS(oldFrame.size.height-newFrame.size.height));
            }
        }
        
        CGFloat alpha = (_isMoveWithAlpha)
        ?[self alphaForMovingWithProgress:1.f fromPosition:self.floatPosition toPosition:floatPosition]
        :1.f;
        
        NSTimeInterval duration = MAX(distance/ABS(velocity),SNFloatControllerMinimumAnimationDuration);
        
        bool moveTogether = (self.autoAdjustBottomViewControllerTogether &&
                             (floatPosition != SNFloatControllerPositionLeftOutScreen &&
                              floatPosition != SNFloatControllerPositionRightOutScreen &&
                              floatPosition != SNFloatControllerPositionFullScreen) &&
                             !(floatPosition == SNFloatControllerPositionTop && self.floatPosition == SNFloatControllerPositionFullScreen)
                             );
        
        _floatToPosition = floatPosition;
        if (animated) {
            [UIView
             animateWithDuration:(duration)
             delay:0.0
             options:options
             animations:^{
                 self.floatContainerView.alpha = alpha;
                 [self.floatContainerViewBackView setFrame:newFrame];
                 if (self.autoAdjustBottomViewController && moveTogether) {
                     [self adjustBottomViewControllerWithAnimated:false floatPosition:self.floatToPosition];
                 }
                 if (self.gestureWillCompletionBlock) {
                     self.gestureWillCompletionBlock(self);
                 }
                 [self adjustNavigationController];
             }
             completion:^(BOOL finished) {
                 [self setFloatPosition:floatPosition];
                 [self setFloatToPosition:SNFloatControllerPositionNone];
                 [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                 [self adjustNavigationController];
                 _isAnimatingDrawerController = false;
                 if (self.autoAdjustBottomViewController && !moveTogether) {
                     [self adjustBottomViewControllerWithAnimated:true floatPosition:self.floatPosition];
                 }
                 [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                 if(completion){
                     completion(finished);
                 }
             }];
        }
        else
        {
            [self setFloatPosition:floatPosition];
            [self setFloatToPosition:SNFloatControllerPositionNone];
            
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            self.floatContainerView.alpha = alpha;
            [self.floatContainerViewBackView setFrame:newFrame];
            [self updateFloatViewWithPercentMoving:1.f];
            
            if (self.autoAdjustBottomViewController && moveTogether) {
                [self adjustBottomViewControllerWithAnimated:false floatPosition:self.floatToPosition];
            }
            
            _isAnimatingDrawerController = false;
            if (self.autoAdjustBottomViewController && !moveTogether) {
                [self adjustBottomViewControllerWithAnimated:false floatPosition:self.floatToPosition];
            }
            if(completion){
                completion(true);
            }
        }
    }
}

- (UIView *)middleContainerView
{
    if (!_middleContainerView) {
        _middleContainerView = [[SNMidleContainerView alloc] initWithFrame:self.childControllerContainerView.bounds];
        _middleContainerView.autoresizesSubviews = true;
        [_middleContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        _middleContainerView.opaque = YES;
        _middleContainerView.backgroundColor = [UIColor clearColor];
        [self.childControllerContainerView insertSubview:_middleContainerView belowSubview:self.floatContainerViewBackView];
    }
    return _middleContainerView;
}
@end
