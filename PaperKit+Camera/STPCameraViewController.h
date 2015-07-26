//
//  STPCameraViewController.h
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/17.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//


@import UIKit;
@import AVFoundation;

#import <PaperKit/PaperKit.h>

#import "STPCameraView.h"
#import "STPCameraCell.h"
#import "STPCameraManager.h"


@interface STPCameraViewController : PKViewController

@property (nonatomic) NSArray *images;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end
