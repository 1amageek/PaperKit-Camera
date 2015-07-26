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

@interface STPCameraManager : NSObject

@property (nonatomic, readonly) UIDeviceOrientation deviceOrientation;
@property (nonatomic, readonly) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOut;

+ (instancetype)sharedManager;
- (void)terminate;
- (void)captureImageWithCompletionHandler:(void (^)(UIImage *image, NSDictionary *metaData, NSError *error))handler;

@end
