//
//  STPCameraCollectionViewController.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/18.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPCameraCollectionViewController.h"

@interface STPCameraImageCell : PKCollectionViewCell

@property (nonatomic) UIImage *image;

@end


@implementation STPCameraImageCell

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundView = imageView;
    }
}
@end


@interface STPCameraCollectionViewController ()

@end

@implementation STPCameraCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[STPCameraImageCell class] forCellWithReuseIdentifier:@"STPCameraImageCell"];
}

- (void)addImage:(UIImage *)image
{
    NSMutableArray *images = [NSMutableArray arrayWithArray:self.images];
    [images addObject:image];
    self.images = images;
    [self.collectionView reloadData]; // TODO
}

#pragma mark  - collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STPCameraImageCell *cell = (STPCameraImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STPCameraImageCell" forIndexPath:indexPath];
    [cell setImage:[self.images objectAtIndex:indexPath.item]];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
