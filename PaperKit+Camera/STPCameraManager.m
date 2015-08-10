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
@property (nonatomic) NSOperationQueue* operationQueue;

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
            _isTraking = NO;
            _deviceOrientation = UIDeviceOrientationPortrait;
            _interfaceOrientation = UIInterfaceOrientationPortrait;
            _operationQueue = [NSOperationQueue new];
            [self start]; // FIXME
        }
        return self;
    }
}

- (void)start
{
    [self startMotionManager];
    [self startLocationManager];
}

- (void)terminate
{
    sharedManager = nil;
}

- (CMMotionManager *)motionManager
{
    if (_motionManager) {
        return _motionManager;
    }
    
    _motionManager = [CMMotionManager new];
    _motionManager.accelerometerUpdateInterval = 0.1;
    return _motionManager;
}

- (CLLocationManager *)locationManager
{
    if (_locationManager) {
        return _locationManager;
    }
    _isTraking = NO;
    _locationManager = [CLLocationManager new];
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.delegate = self;
    return _locationManager;
}


#pragma mark - Location manager

- (void)startLocationManager
{
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(nonnull CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    if (!self.isTraking) {
        _isTraking = YES;
        if ([self.delegate respondsToSelector:@selector(cameraManager:readyForLocationManager:)]) {
            [self.delegate cameraManager:self readyForLocationManager:self.locationManager];
        }
    }
}

#pragma mark - Motion manager

- (void)startMotionManager
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
                NSMutableDictionary *meta = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)(metadata)];
                //NSMutableDictionary *exif = meta[(NSString *)kCGImagePropertyExifDictionary];
                CFRelease(metadata);
                
                if (self.isTraking && self.locationManager) {
                    meta[(NSString *)kCGImagePropertyGPSDictionary] = [self GPSDictionaryForLocation:self.locationManager.location];
                }
                
                handler(image, meta, error);
            }
            self.processing = NO;
        }];
    }
}

- (NSDictionary *)GPSDictionaryForLocation:(CLLocation *)location
{
    NSMutableDictionary *gps = [NSMutableDictionary new];
    
    // 日付
    gps[(NSString *)kCGImagePropertyGPSDateStamp] = [[self GPSDateFormatter] stringFromDate:location.timestamp];
    // タイムスタンプ
    gps[(NSString *)kCGImagePropertyGPSTimeStamp] = [[self GPSTimeFormatter] stringFromDate:location.timestamp];
    

    // 緯度
    CGFloat latitude = location.coordinate.latitude;
    NSString *gpsLatitudeRef;
    if (latitude < 0) {
        latitude = -latitude;
        gpsLatitudeRef = @"S";
    } else {
        gpsLatitudeRef = @"N";
    }
    gps[(NSString *)kCGImagePropertyGPSLatitudeRef] = gpsLatitudeRef;
    gps[(NSString *)kCGImagePropertyGPSLatitude] = @(latitude);
    
    // 経度
    CGFloat longitude = location.coordinate.longitude;
    NSString *gpsLongitudeRef;
    if (longitude < 0) {
        longitude = -longitude;
        gpsLongitudeRef = @"W";
    } else {
        gpsLongitudeRef = @"E";
    }
    gps[(NSString *)kCGImagePropertyGPSLongitudeRef] = gpsLongitudeRef;
    gps[(NSString *)kCGImagePropertyGPSLongitude] = @(longitude);
    
    // 標高
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        NSString *gpsAltitudeRef;
        if (altitude < 0) {
            altitude = -altitude;
            gpsAltitudeRef = @"1";
        } else {
            gpsAltitudeRef = @"0";
        }
        gps[(NSString *)kCGImagePropertyGPSAltitudeRef] = gpsAltitudeRef;
        gps[(NSString *)kCGImagePropertyGPSAltitude] = @(altitude);
    }
    
    return gps;
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

- (CGPoint)convertToPointOfInterestFrom:(CGRect)frame coordinates:(CGPoint)viewCoordinates layer:(AVCaptureVideoPreviewLayer *)layer
{
    CGPoint pointOfInterest = (CGPoint){ 0.5f, 0.5f };
    CGSize frameSize = frame.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = layer;
    
    if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] )
        pointOfInterest = (CGPoint){ viewCoordinates.y / frameSize.height, 1.0f - (viewCoordinates.x / frameSize.width) };
    else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in self.deviceInput.ports) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = 0.5f;
                CGFloat yc = 0.5f;
                
                if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.0f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.0f - (point.x / x2);
                        }
                    }
                } else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.0f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.0f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = (CGPoint){ xc, yc };
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    __block AVCaptureDevice *deviceBlock = nil;
    
    [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] enumerateObjectsUsingBlock:^( AVCaptureDevice *device, NSUInteger idx, BOOL *stop ) {
        if ( [device position] == position ) {
            deviceBlock = device;
            *stop = YES;
        }
    }];
    
    return deviceBlock;
}

- (AVCaptureDevice *)frontCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


- (void)dealloc
{
    [self.motionManager stopAccelerometerUpdates];
    self.operationQueue = nil;
    self.motionManager = nil;
}

#pragma mark - DateFormat

- (NSDateFormatter *)exifDateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy:MM:dd HH:mm:ss";
    }
    
    return dateFormatter;
}

- (NSDateFormatter *)GPSDateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy:MM:dd";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    
    return dateFormatter;
}

- (NSDateFormatter *)GPSTimeFormatter
{
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss.SSSSSS";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    
    return dateFormatter;
}

- (NSDateFormatter *)fileNameDateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    }
    
    return dateFormatter;
}


@end
