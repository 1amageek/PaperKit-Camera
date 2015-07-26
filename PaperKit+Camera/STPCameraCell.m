//
//  STPCameraCell.m
//  PaperKit+Camera
//
//  Created by Norikazu on 2015/07/26.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "STPCameraCell.h"

@implementation STPCameraCell

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cameraView];
    }
    return self;
}

- (UIView *)cameraView
{
    if (_cameraView) {
        return _cameraView;
    }
    _cameraView = [[STPCameraView alloc] initWithFrame:self.bounds];
    return _cameraView;
}

@end
