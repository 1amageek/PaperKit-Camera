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
@property (nonatomic) CALayer *triggerButtonOutline;
@property (nonatomic) CGFloat optimizeProgress;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation STPCameraView

static CGFloat triggerButtonRadius = 24;
static CGFloat triggerButtonOutlineRadius = 32;

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
    _triggerButtonCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height - triggerButtonOutlineRadius * 2 - 25 );
    self.tintColor = [UIColor whiteColor];
    [self.layer addSublayer:self.triggerButtonOutline];
    [self.layer addSublayer:self.focusBox];
    //[self.layer addSublayer:self.exposeBox];
    [self addSubview:self.triggerButton];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    [self draw:self.focusBox atPoint:[recognizer locationInView:self] remove:YES];
    if ([self.delegate respondsToSelector:@selector(cameraView:optimizeAtPoint:)]) {
        [self.delegate cameraView:self optimizeAtPoint:[recognizer locationInView:self]];
    }
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
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"inc.stamp.stp.camera.optimize.property" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj optimizeProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setOptimizeProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    
    animation.property = prop;
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
    
        if (finished) {
            POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
            animation.duration = 0.5f;
            animation.fromValue = @(1);
            animation.toValue = @(0);
            [layer pop_addAnimation:animation forKey:@"inc.stamp.camera.layer.opacity"];
        }
        
    };
    animation.fromValue = @(0);
    animation.toValue = @(1);
    [self pop_addAnimation:animation forKey:@"inc.stamp.stp.camera.optimize"];

}

- (UIButton *)triggerButton
{
    if (_triggerButton) {
        return _triggerButton;
    }
    
    _triggerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_triggerButton setBackgroundColor:self.tintColor];
    [_triggerButton setFrame:(CGRect){ 0, 0, triggerButtonRadius * 2, triggerButtonRadius * 2}];
    [_triggerButton.layer setCornerRadius:triggerButtonRadius];
    [_triggerButton setCenter:self.triggerButtonCenter];
    [_triggerButton addTarget:self action:@selector(triggerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return _triggerButton;
}

- (void)triggerAction:(UIButton *)button
{
    
    POPBasicAnimation *animation = [self.triggerButton.layer pop_animationForKey:@"inc.stamp.stp.camera.trigger"];
    if (!animation) {
        animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        animation.duration = 0.25;
        [self.triggerButton.layer pop_addAnimation:animation forKey:@"inc.stamp.stp.camera.trigger"];
    }
    animation.fromValue = @(0);
    animation.toValue = @(1);
    
    
    if ([self.delegate respondsToSelector:@selector(cameraViewStartRecording)]) {
        [self.delegate cameraViewStartRecording];
    }
}


#pragma mark - Focus / Expose Box

- (CALayer *)triggerButtonOutline
{
    if (_triggerButtonOutline) {
        return _triggerButtonOutline;
    }
    
    _triggerButtonOutline = [CALayer layer];
    [_triggerButtonOutline setCornerRadius:triggerButtonOutlineRadius];
    [_triggerButtonOutline setBounds:CGRectMake(0.0f, 0.0f, triggerButtonOutlineRadius * 2, triggerButtonOutlineRadius * 2)];
    [_triggerButtonOutline setBorderWidth:5.0f];
    [_triggerButtonOutline setPosition:self.triggerButtonCenter];
    [_triggerButtonOutline setBorderColor:[[UIColor whiteColor] CGColor]];
    
    return _triggerButtonOutline;
}

- (CALayer *)focusBox
{
    if (_focusBox) {
        return _focusBox;
    }
    
    _focusBox = [CALayer layer];
    [_focusBox setCornerRadius:45.0f];
    [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
    [_focusBox setBorderWidth:1.f];
    [_focusBox setBorderColor:[[UIColor whiteColor] CGColor]];
    
    return _focusBox;
}

- (CALayer *)exposeBox
{
    if (_exposeBox) {
        return _exposeBox;
    }
    
    _exposeBox = [CALayer layer];
    [_exposeBox setCornerRadius:55.0f];
    [_exposeBox setBounds:CGRectMake(0.0f, 0.0f, 110, 110)];
    [_exposeBox setBorderWidth:5.f];
    [_exposeBox setBorderColor:[[UIColor redColor] CGColor]];
    
    return _exposeBox;
}



@end
