//
//  STPCameraManager.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/18.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

@import UIKit;
@import AVFoundation;
@import CoreMotion;
@import CoreLocation;
@import ImageIO;


@protocol STPCameraManagerDelegate;
@interface STPCameraManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <STPCameraManagerDelegate> delegate;

@property (nonatomic, readonly) UIDeviceOrientation deviceOrientation;
@property (nonatomic, readonly) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *deviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOut;


@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, readonly) BOOL isTraking;

@property (nonatomic) CMMotionManager* motionManager;



+ (instancetype)sharedManager;
- (void)start;
- (void)terminate;
- (void)captureImageWithCompletionHandler:(void (^)(UIImage *image, NSDictionary *metaData, NSError *error))handler;

- (CGPoint) convertToPointOfInterestFrom:(CGRect)frame coordinates:(CGPoint)viewCoordinates layer:(AVCaptureVideoPreviewLayer *)layer;

- (void)optimizeAtPoint:(CGPoint)point;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposureAtPoint:(CGPoint)point;

@end

@protocol STPCameraManagerDelegate <NSObject>

- (void)cameraManager:(STPCameraManager *)manager readyForLocationManager:(CLLocationManager *)locationManager;

@end