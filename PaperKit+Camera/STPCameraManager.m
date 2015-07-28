//
//  STPCameraManager.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/18.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPCameraManager.h"

@interface STPCameraManager ()

@property (nonatomic, getter=isProcessing) BOOL processing;
@property (strong) CMMotionManager* motionManager;
@property (strong) NSOperationQueue* operationQueue;

@end


static STPCameraManager  *sharedManager = nil;

@implementation STPCameraManager

+ (instancetype)sharedManager
{
    if (sharedManager) {
        return sharedManager;
    }
    sharedManager = [STPCameraManager new];
    return sharedManager;
}

- (instancetype)init
{
    @synchronized(self) {
        self = [super init];
        if (self) {
            _processing = NO;
            _deviceOrientation = UIDeviceOrientationPortrait;
            _interfaceOrientation = UIInterfaceOrientationPortrait;
            _operationQueue = [NSOperationQueue new];
            _motionManager = [[CMMotionManager alloc] init];
            _motionManager.accelerometerUpdateInterval = 0.1;
            [self start];
        }
        return self;
    }
}

- (void)terminate
{
    sharedManager = nil;
}

- (void)start
{
    [self.motionManager startAccelerometerUpdatesToQueue:self.operationQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        if (self.isProcessing) {
            return;
        }
        
        UIDeviceOrientation newDeviceOrientation;
        UIInterfaceOrientation newInterfaceOrientation;
        CMAcceleration acceleration = accelerometerData.acceleration;
        
        float xx = -acceleration.x;
        float yy = acceleration.y;
        float z = acceleration.z;
        float angle = atan2(yy, xx);
        float absoluteZ = (float)fabs(acceleration.z);
        
        if(absoluteZ > 0.8f)
        {
            if ( z > 0.0f ) {
                newDeviceOrientation = UIDeviceOrientationFaceDown;
            } else {
                newDeviceOrientation = UIDeviceOrientationFaceUp;
            }
        }
        else if(angle >= -2.25 && angle <= -0.75) //(angle >= -2.0 && angle <= -1.0) // (angle >= -2.25 && angle <= -0.75)
        {
            newInterfaceOrientation = UIInterfaceOrientationPortrait;
            newDeviceOrientation = UIDeviceOrientationPortrait;
        }
        else if(angle >= -0.5 && angle <= 0.5) // (angle >= -0.75 && angle <= 0.75)
        {
            newInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            newDeviceOrientation = UIDeviceOrientationLandscapeLeft;
        }
        else if(angle >= 1.0 && angle <= 2.0) // (angle >= 0.75 && angle <= 2.25)
        {
            newInterfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
            newDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        }
        else if(angle <= -2.5 || angle >= 2.5) // (angle <= -2.25 || angle >= 2.25)
        {
            newInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
            newDeviceOrientation = UIDeviceOrientationLandscapeRight;
        } else {
            
        }
        
        BOOL deviceOrientationChanged = NO;
        BOOL interfaceOrientationChanged = NO;
        
        if ( newDeviceOrientation != self.deviceOrientation ) {
            deviceOrientationChanged = YES;
            _deviceOrientation = newDeviceOrientation;
        }
        
        if ( newInterfaceOrientation != self.interfaceOrientation ) {
            interfaceOrientationChanged = YES;
            _interfaceOrientation = newInterfaceOrientation;
        }
        
        /*
        if ( deviceOrientationChanged ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationChangedNotification
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, kMotionOrientationKey, nil]];

        }
        if ( interfaceOrientationChanged ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationInterfaceOrientationChangedNotification
                                                                object:nil 
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, kMotionOrientationKey, nil]];
        }
         */
        
    }];
}
#pragma mark - util

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
    AVCaptureConnection *videoConnection = nil;
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [port.mediaType isEqual:mediaType] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    return videoConnection;
}


#pragma mark - control method

- (void)captureImageWithCompletionHandler:(void (^)(UIImage *image, NSDictionary *metaData, NSError *error))handler;
{
    if (self.isProcessing) {
        return;
    }
    
    self.processing = YES;
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            
            // TODO ERROR
            
            return;
        }
        else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
            
            // TODO ERROR
            
            return;
        }
    }
    
    AVCaptureConnection *captureConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:self.stillImageOut.connections];
    
    if ( [captureConnection isVideoOrientationSupported] ) {
        switch (self.deviceOrientation) {
            case UIDeviceOrientationPortraitUpsideDown:
                [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                [captureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                break;
                
            case UIDeviceOrientationLandscapeRight:
                [captureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
                
            default:
                [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
        }
    }
    
    if (captureConnection) {
        captureConnection.videoScaleAndCropFactor = 1;
        
        [self.stillImageOut captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer != NULL) {
                NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:data];
                
                CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
                NSDictionary *meta = [[NSDictionary alloc] initWithDictionary:(__bridge NSDictionary *)(metadata)];
                CFRelease(metadata);
                
                handler(image, meta, error);
            }
            self.processing = NO;
        }];
    }
}

#pragma mark - Focus & Exposure

- (void)optimizeAtPoint:(CGPoint)point
{
    [self focusAtPoint:point];
    [self exposureAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = self.deviceInput.device;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
    }
}

- (void)exposureAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = self.deviceInput.device;
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [device unlockForConfiguration];
        }
    }
}

- (void)dealloc
{
    [self.motionManager stopAccelerometerUpdates];
    self.operationQueue = nil;
    self.motionManager = nil;
}


@end
