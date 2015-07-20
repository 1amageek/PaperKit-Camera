//
//  STPCameraView.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPCameraView.h"

@interface STPCameraView ()

@property (nonatomic) UIButton *triggerButton;
@property (nonatomic) CGFloat optimizeProgress;

@end

@implementation STPCameraView

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.tintColor = [UIColor whiteColor];
}

- (void)buildSubviews
{
    [self.layer addSublayer:self.focusBox];
    [self.layer addSublayer:self.exposeBox];
    [self addSubview:self.triggerButton];
}

- (void)setOptimizeProgress:(CGFloat)optimizeProgress
{
    _optimizeProgress = optimizeProgress;
    
    CGFloat opacity = POPTransition(optimizeProgress, 0, 1);
    self.focusBox.opacity = opacity;
    
    CGFloat scale = POPTransition(opacity, 3, 1);
    self.focusBox.transform = CATransform3DMakeScale(scale, scale, 1);
    
    
}

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}


- (void)draw:(CALayer *)layer atPoint:(CGPoint)point remove:(BOOL)remove
{
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    [layer setPosition:point];
    [CATransaction commit];
    if (remove) {
        [layer pop_removeAllAnimations];
    }
    
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"inc.stamp.stp.camera.optimize" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj optimizeProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setOptimizeProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    
    animation.property = prop;
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {};
    animation.fromValue = @(0);
    animation.toValue = @(1);
    
    /*
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animation.fromValue = @(1);
    animation.toValue = @(0);
    [layer pop_addAnimation:animation forKey:@"inc.stamp.camera.layer.opacity"];
     */
}

- (UIButton *)triggerButton
{
    if (_triggerButton) {
        return _triggerButton;
    }
    
    _triggerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_triggerButton setBackgroundColor:self.tintColor];
    [_triggerButton setFrame:(CGRect){ 0, 0, 66, 66 }];
    [_triggerButton.layer setCornerRadius:33.0f];
    [_triggerButton setCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - 200 }];
    [_triggerButton addTarget:self action:@selector(triggerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return _triggerButton;
}

- (void)triggerAction:(UIButton *)button
{
    if ([self.controller respondsToSelector:@selector(cameraViewStartRecording)]) {
        [self.controller cameraViewStartRecording];
    }
}


#pragma mark - Focus / Expose Box

- (CALayer *)focusBox
{
    if (_focusBox) {
        return _focusBox;
    }
    
    _focusBox = [CALayer new];
    [_focusBox setCornerRadius:45.0f];
    [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
    [_focusBox setBorderWidth:5.f];
    [_focusBox setBorderColor:[[UIColor whiteColor] CGColor]];
    
    return _focusBox;
}

- (CALayer *)exposeBox
{
    if (_exposeBox) {
        return _exposeBox;
    }
    
    _exposeBox = [CALayer new];
    [_exposeBox setCornerRadius:55.0f];
    [_exposeBox setBounds:CGRectMake(0.0f, 0.0f, 110, 110)];
    [_exposeBox setBorderWidth:5.f];
    [_exposeBox setBorderColor:[[UIColor redColor] CGColor]];
    
    return _exposeBox;
}



@end
