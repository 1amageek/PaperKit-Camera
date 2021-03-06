//
//  STPCameraViewController.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPCameraViewController.h"
#import "STPPreviewViewController.h"

@interface _STPCameraBackgroundCell : PKCollectionViewCell

@end


@implementation _STPCameraBackgroundCell

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    
    return self;
}
@end

@interface STPCameraViewController () <STPCameraViewDelegate, STPCameraManagerDelegate>
@property (nonatomic) UIView *preview;
@property (nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic) NSArray *backgroundData;
@property (nonatomic) NSArray *foregroundData;
@end

@implementation STPCameraViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    _images = @[];
    _backgroundData = @[@"撮影"];
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
        
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        _captureVideoPreviewLayer.frame = self.view.bounds;
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [session startRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [STPCameraManager sharedManager].session = session;
            [STPCameraManager sharedManager].deviceInput = cameraInput;
            [STPCameraManager sharedManager].stillImageOut = stillImageOut;
            [STPCameraManager sharedManager].delegate = self;
            CALayer *previewLayer = self.view.layer;
            previewLayer.masksToBounds = YES;
            [previewLayer insertSublayer:_captureVideoPreviewLayer atIndex:0];

        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.minimumZoomScale = 0.07;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[STPCameraCell class] forCellWithReuseIdentifier:@"STPCameraCell"];
    [self.collectionView registerClass:[_STPCameraBackgroundCell class] forCellWithReuseIdentifier:@"_STPCameraBackgroundCell"];
    [self setupAVCapture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    STPCameraCell *cell = (STPCameraCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if (cell) {
        [cell.cameraView draw:cell.cameraView.focusBox atPoint:self.view.center remove:YES];
    }
}

- (void)addImage:(UIImage *)image
{
    NSMutableArray *images = self.images.mutableCopy;
    [images insertObject:image atIndex:0];
    self.images = images;
    NSMutableArray *insertIndexPaths = @[].mutableCopy;
    [insertIndexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    [self foregroundCollectionViewOnCategory:self.selectedCategory performBatchUpdates:^(PKCollectionViewController *controller){
        [controller.collectionView insertItemsAtIndexPaths:insertIndexPaths];
    } completion:^(BOOL finished) {
        [self.view setNeedsLayout];
    }];
}

#pragma mark  - collection view delegate

- (NSInteger)backgroundCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _backgroundData.count;
}

- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section onCategory:(NSInteger)category
{
    return _images.count;
}

- (UICollectionViewCell *)backgroundCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"_STPCameraBackgroundCell" forIndexPath:indexPath];
    
    if (indexPath.item == 0) {
        STPCameraCell *cell = (STPCameraCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STPCameraCell" forIndexPath:indexPath];
        cell.cameraView.delegate = self;
        return cell;
    }
    
    return cell;
}

- (PKContentViewController *)foregroundCollectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:(NSIndexPath *)indexPath onCategory:(NSUInteger)category
{
    UIImage *image = [self.images objectAtIndex:indexPath.item];
    return [[STPPreviewViewController alloc] initWithImage:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera view delegate

- (void)cameraViewStartRecording
{
    
#if TARGET_IPHONE_SIMULATOR
    
    NSUInteger i = random() % 7 + 1;
    NSString *name = [NSString stringWithFormat:@"%lu", (unsigned long)i];
    UIImage *image = [UIImage imageNamed:name];
    
    [self addImage:image];
    
#else
    [[STPCameraManager sharedManager] captureImageWithCompletionHandler:^(UIImage *image, NSDictionary *metaData, NSError *error) {
        if (error) {
            return ;
        }
        
        if (image) {
            NSLog(@"meta %@", metaData);
            
            [self addImage:image];
        }
    }];
#endif
}

- (void)cameraView:(STPCameraView *)cameraView optimizeAtPoint:(CGPoint)point
{

    CGPoint convertPoint = [[STPCameraManager sharedManager] convertToPointOfInterestFrom:self.captureVideoPreviewLayer.frame coordinates:point layer:self.captureVideoPreviewLayer];
    [[STPCameraManager sharedManager] optimizeAtPoint:convertPoint];
}

#pragma mark - CameraManager

- (void)cameraManager:(STPCameraManager *)manager readyForLocationManager:(CLLocationManager *)locationManager
{
    NSLog(@"cameraManager");
}

- (void)dealloc
{
    [[STPCameraManager sharedManager] terminate];
}


@end
