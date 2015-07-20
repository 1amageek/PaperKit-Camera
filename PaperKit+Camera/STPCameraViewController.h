//
//  STPCameraViewController.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//


@import UIKit;
@import AVFoundation;

#import "STPCameraView.h"
#import "STPCameraManager.h"
#import "STPCameraCollectionViewController.h"

@interface STPCameraViewController : UIViewController

@property (nonatomic) STPCameraView *cameraView;
@property (nonatomic) NSArray *images;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end
