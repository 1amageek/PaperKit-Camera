//
//  STPAssetViewController.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/26.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKContentViewController.h"

@interface STPAssetViewController : PKContentViewController

@property (nonatomic) UIImage *image;

- (nullable instancetype)initWithImage:(nonnull UIImage *)image;

@end
