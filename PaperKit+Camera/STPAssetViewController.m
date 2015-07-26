//
//  STPAssetViewController.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/26.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPAssetViewController.h"

@interface STPAssetViewController ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation STPAssetViewController

- (nullable instancetype)initWithImage:(nonnull UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews
{
    self.imageView.frame = self.view.bounds;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    [self.imageView setNeedsDisplay];
}

- (UIImageView *)imageView
{
    if (_imageView) {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    return _imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
