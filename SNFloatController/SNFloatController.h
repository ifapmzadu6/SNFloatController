//
//  SNFloatController.h
//  SNFloatingViewSample
//
//  Created by nagatashin on 2013/10/22.
//  Copyright (c) 2013年 nagatashin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNFloatControllerViewControllers)
{
    SNFloatControllerViewControllersFloat,
    SNFloatControllerViewControllersBottom
};

//FloatView's Position
typedef NS_ENUM(NSInteger, SNFloatControllerPosition) {
    SNFloatControllerPositionNone,
    SNFloatControllerPositionRightOutScreen,
    SNFloatControllerPositionLeftOutScreen,
    SNFloatControllerPositionTop,
    SNFloatControllerPositionBar,
    SNFloatControllerPositionFullScreen
};

typedef NS_ENUM(NSInteger, SNFloatControllerFloatInteractionMode) {
    SNFloatControllerFloatInteractionModeNone,
    SNFloatControllerFloatInteractionModeFull
};

typedef NS_ENUM(NSInteger, SNFloatControllerBottomInteractionMode) {
    SNFloatControllerBottomInteractionModeNone,
    SNFloatControllerBottomInteractionModeFull
};

typedef NS_ENUM(NSInteger, SNFloatControllerMoveInteractionMode) {
    SNFloatControllerMoveInteractionModeNone,
    SNFloatControllerMoveInteractionModeCustom,
    SNFloatControllerMoveInteractionModeOnlyFloatView,
    SNFloatControllerMoveInteractionModeFull
};

typedef NS_ENUM(NSInteger, SNFloatControllerMoveInteractionSpeed) {
    SNFloatControllerMoveInteractionSpeedFullScreenAdjust,
    SNFloatControllermoveInteractionSpeedTopViewControllerAdjust
};


@class SNFloatController;
typedef void (^SNFLoatControllerMovingStateBlock)(SNFloatController *floatController, SNFloatControllerPosition position, CGFloat percentMoving);
typedef BOOL (^SNFLoatControllerGestureShouldRecognizeTouchBlock)(SNFloatController *floatController, UIGestureRecognizer * gesture, UITouch * touch);
typedef void (^SNFLoatControllerGestureWillContplationBlock)(SNFloatController *floatController);
typedef void (^SNFLoatControllerGestureCompletionBlock)(SNFloatController *floatController, UIGestureRecognizer * gesture);


@interface SNFloatController : UIViewController

//Controller
@property (nonatomic, strong) UIViewController * floatViewController;
@property (nonatomic, strong) UIViewController * bottomViewController;

//View
@property (nonatomic, weak) UIView *customMoveInteractionView;
@property (nonatomic) UIView *adView;
@property (nonatomic, strong) UIView *statusBarView;

//Mode
@property (nonatomic, readonly) SNFloatControllerPosition floatPosition;
@property (nonatomic, readonly) SNFloatControllerPosition floatToPosition;
@property (nonatomic) SNFloatControllerFloatInteractionMode floatInteractionMode;
@property (nonatomic) SNFloatControllerBottomInteractionMode bottomInteractionMode;
@property (nonatomic) SNFloatControllerMoveInteractionMode moveInteractionMode;
@property (nonatomic) SNFloatControllerMoveInteractionSpeed moveInteractionSpeed;

//parameter
@property (nonatomic, readonly) BOOL isAppearingFloatView;
@property (nonatomic, readonly) BOOL isAnimatingDrawerController;

@property (nonatomic, readonly) CGFloat panProgress;
@property (nonatomic) CGFloat swipeLenghtFullToTop;
@property (nonatomic) CGFloat swipeLenghtTopToBar;

@property (nonatomic) CGPoint floatControllerTopOriginPoint;
@property (nonatomic) CGPoint floatControllerBottomOriginPoint;
@property (nonatomic) CGFloat animationVelocity;

//Views
@property (nonatomic, strong) UIView *middleContainerView;

//Flag
@property (nonatomic) BOOL isMoveWithAlpha;
@property (nonatomic) BOOL autoAdjustBottomViewController;
@property (nonatomic) BOOL autoAdjustBottomViewControllerTogether;
@property (nonatomic) BOOL isEnableMove;
@property (nonatomic) BOOL isEnableRotate;

//Block
@property (nonatomic, copy) SNFLoatControllerMovingStateBlock floatMovingStateBlock;
@property (nonatomic, copy) SNFLoatControllerGestureWillContplationBlock gestureWillCompletionBlock;
@property (nonatomic, copy) SNFLoatControllerGestureShouldRecognizeTouchBlock gestureShouldRecognizeTouchBlock;
@property (nonatomic, copy) SNFLoatControllerGestureCompletionBlock gestureCompletionBlock;

- (id)initWithFloatViewController:(UIViewController *)floatViewController BottomViewController:(UIViewController *)bottomViewController;

- (void)moveToPosition:(SNFloatControllerPosition)floatPosition animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;

- (void)setCustomMoveInteractionView:(UIView *)customMoveInteractionView;
- (void)setViewControllerFrame:(SNFloatControllerViewControllers)controller frame:(CGRect)frame animated:(bool)animated;

- (CGRect)frameForPosition:(SNFloatControllerPosition)position;

- (bool)isMovingBetweenPosition:(SNFloatControllerPosition)position1 andPosition:(SNFloatControllerPosition)position2;
@end
