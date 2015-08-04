//
//  STPPreviewViewController.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/08/04.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPPreviewViewController.h"

@interface STPPreviewViewController ()

@property (nonatomic) PKPreviewView *imageView;

@end

@implementation STPPreviewViewController

- (nullable instancetype)initWithImage:(nonnull UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
        _imageView = [[PKPreviewView alloc] initWithImage:image];
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

- (PKPreviewView *)imageView
{
    if (_imageView) {
        return _imageView;
    }
    
    _imageView = [[PKPreviewView alloc] initWithFrame:self.view.bounds];
    _imageView.clipsToBounds = YES;
    return _imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
