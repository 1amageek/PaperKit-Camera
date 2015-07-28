//
//  STPCameraViewController.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPCameraViewController.h"
#import "STPAssetViewController.h"

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

@interface STPCameraViewController () <STPCameraViewDelegate>
@property (nonatomic) UIView *preview;
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
            [STPCameraManager sharedManager].deviceInput = cameraInput;
            [STPCameraManager sharedManager].stillImageOut = stillImageOut;
            CALayer *previewLayer = self.view.layer;
            previewLayer.masksToBounds = YES;
            [previewLayer insertSublayer:captureVideoPreviewLayer atIndex:0];

        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.minimumZoomScale = 0.2;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[STPCameraCell class] forCellWithReuseIdentifier:@"STPCameraCell"];
    [self.collectionView registerClass:[_STPCameraBackgroundCell class] forCellWithReuseIdentifier:@"_STPCameraBackgroundCell"];
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
    return [[STPAssetViewController alloc] initWithImage:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera view delegate

- (void)cameraViewStartRecording
{
    [[STPCameraManager sharedManager] captureImageWithCompletionHandler:^(UIImage *image, NSDictionary *metaData, NSError *error) {
        
        if (error) {
            return ;
        }
        
        if (image) {
            [self addImage:image];
        }
    }];
}

- (void)cameraView:(STPCameraView *)cameraView optimizeAtPoint:(CGPoint)point
{
    [[STPCameraManager sharedManager] optimizeAtPoint:point];
}

- (void)dealloc
{
    [[STPCameraManager sharedManager] terminate];
}


@end
