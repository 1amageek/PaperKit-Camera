//
//  ViewController.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "ViewController.h"
#import "ContentViewController.h"
#import "STPCameraViewController.h"

@interface ViewController ()

@property (nonatomic) NSArray *backgroundData;
@property (nonatomic) NSArray *foregroundData;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _transitioning = NO;
    _backgroundData = @[@"0",@"1",@"2"];
    _foregroundData = @[@"0",@"1",@"2",@"3",@"4",@"5"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)backgroundCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _backgroundData.count;
}

- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section onCategory:(NSInteger)category
{
    return _foregroundData.count;
}

- (UICollectionViewCell *)backgroundCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    CGFloat color = floorf(indexPath.item)/[self backgroundCollectionView:collectionView numberOfItemsInSection:indexPath.section];
    
    CGFloat saturation = floorf([[UIApplication sharedApplication].windows indexOfObject:(UIWindow *)self.view.superview])/[UIApplication sharedApplication].windows.count;
    cell.backgroundColor = [UIColor colorWithHue:color saturation:saturation brightness:1 alpha:1];
    return cell;
}

- (PKContentViewController *)foregroundCollectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:(NSIndexPath *)indexPath onCategory:(NSUInteger)category
{
    //NSLog(@"indexPaht %@ cateogry %lu",indexPath, (unsigned long)category);
    return [ContentViewController new];
}

- (void)pullDownToActionWithProgress:(CGFloat)progress
{
    if (1 < progress) {
        if (!self.isTransitioning) {
            self.transitioning = YES;
            STPCameraViewController *cameraViewController = [STPCameraViewController new];
            [[PKWindowManager sharedManager] showWindowWithRootViewController:cameraViewController];
        }
    }
    if (progress == 0) {
        self.transitioning = NO;
    }
}

@end
