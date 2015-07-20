//
//  STPCameraCollectionViewController.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/18.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewController.h"

@interface STPCameraCollectionViewController : PKCollectionViewController

@property (nonatomic) NSArray *images;

- (void)addImage:(UIImage *)image;

@end
