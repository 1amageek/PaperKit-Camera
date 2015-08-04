//
//  STPPreviewViewController.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/08/04.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <PaperKit/PaperKit.h>

@interface STPPreviewViewController : PKContentViewController

@property (nonatomic) UIImage *image;

- (nullable instancetype)initWithImage:(nonnull UIImage *)image;

@end
