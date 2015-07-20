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
        }
        return self;
    }
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

- (void)startRecordingWithCompletionHandler:(void (^)(UIImage *, NSDictionary *, NSError *))handler
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
    
    AVCaptureConnection *connection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:self.stillImageOut.connections];
    
    [self.stillImageOut captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
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

@end
