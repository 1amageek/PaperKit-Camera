//
//  STPCameraViewController.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPCameraViewController.h"



@interface STPCameraViewController () <STPCameraViewDelegate>

@property (nonatomic) STPCameraCollectionViewController *viewController;

@end

@implementation STPCameraViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _images = @[];
    _viewController = [STPCameraCollectionViewController new];
    [self setupAVCapture];
}

- (void)setupAVCapture
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSError *error = nil;
        AVCaptureSession *session = [AVCaptureSession new];
        AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
        AVCaptureStillImageOutput *stillImageOut = [AVCaptureStillImageOutput new];
        
        if ([session canAddInput:cameraInput]) {
            [session addInput:cameraInput];
        }
        
        if ([session canAddOutput:stillImageOut]) {
            [session addOutput:stillImageOut];
        }
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        captureVideoPreviewLayer.frame = self.view.bounds;
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [session startRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [STPCameraManager sharedManager].session = session;
            [STPCameraManager sharedManager].stillImageOut = stillImageOut;
            CALayer *previewLayer = self.cameraView.layer;
            previewLayer.masksToBounds = YES;
            [previewLayer addSublayer:captureVideoPreviewLayer];
            [self.cameraView buildSubviews];
        });
    });
}

- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.cameraView];
}

- (UIView *)cameraView
{
    if (_cameraView) {
        return _cameraView;
    }
    _cameraView = [[STPCameraView alloc] initWithFrame:self.view.bounds];
    _cameraView.controller = self;
    return _cameraView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set gesture
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToOptimize:)];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToExpose:)];
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressToLockFocus:)];
    
    [self.cameraView addGestureRecognizer:_tapGestureRecognizer];
    [self.cameraView addGestureRecognizer:_panGestureRecognizer];
    [self.cameraView addGestureRecognizer:_longPressGestureRecognizer];
    
    [self addChildViewController:self.viewController];
    [self.view addSubview:self.viewController.view];
    [self.viewController didMoveToParentViewController:self];
    
    
}

#pragma mark - gesture

- (void)tapToOptimize:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.cameraView];
    [self.cameraView draw:self.cameraView.focusBox atPoint:point remove:YES];
}

- (void)panToExpose:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.cameraView];
    
}

- (void)pressToLockFocus:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.cameraView];
}

#pragma mark - Camera view delegate

- (void)cameraViewStartRecording
{
    [[STPCameraManager sharedManager] startRecordingWithCompletionHandler:^(UIImage *image, NSDictionary *metaData, NSError *error) {
        
        if (error) {
            return ;
        }
        
        if (image) {
            [self.viewController addImage:image];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
