//
//  STPCameraView.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>

@protocol STPCameraViewDelegate;
@interface STPCameraView : UIView

@property (nonatomic) CALayer *focusBox;
@property (nonatomic) CALayer *exposeBox;

@property (nonatomic) id <STPCameraViewDelegate> delegate;

- (void)draw:(CALayer *)layer atPoint:(CGPoint)point remove:(BOOL)remove;

@end

@protocol STPCameraViewDelegate <NSObject>


- (void)cameraViewStartRecording;

@optional
- (void)cameraView:(STPCameraView *)cameraView focusAtPoint:(CGPoint)point;
- (void)cameraView:(STPCameraView *)cameraView exposeAtPoint:(CGPoint)point;
- (void)cameraView:(STPCameraView *)cameraView optimizeAtPoint:(CGPoint)point;

@end