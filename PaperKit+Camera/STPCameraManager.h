//
//  STPCameraManager.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/18.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

@import UIKit;
@import AVFoundation;


@interface STPCameraManager : NSObject

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOut;
@property (nonatomic) UIDeviceOrientation deviceOrientation;

+ (instancetype)sharedManager;
- (void)startRecording;
- (void)startRecordingWithCompletionHandler:(void (^)(UIImage *image, NSDictionary *metaData, NSError *error))handler;

@end
