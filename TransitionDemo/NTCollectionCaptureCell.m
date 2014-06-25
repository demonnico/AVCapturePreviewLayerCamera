//
//  NTCollectionCaptureCell.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/24/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTCollectionCaptureCell.h"
#import "CLLAccelerometerOrientation.h"
#import "NTCaptureLayer.h"
@import AssetsLibrary;
@import AVFoundation;

@interface NTCollectionCaptureCell()
@property (nonatomic,strong) NTCaptureLayer  * previewLayer;
@property (nonatomic,strong) UITabBar * tabBar;
@property (nonatomic,assign) UIDeviceOrientation deviceOrientation;
@end

@implementation NTCollectionCaptureCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.previewLayer = [NTCaptureLayer layer];
        [self.contentView.layer addSublayer:self.previewLayer];
        [self.previewLayer start];
        
        self.tabBar = [UITabBar new];
        [self.contentView addSubview:self.tabBar];
        self.tabBar.barStyle = UIBarStyleBlack;
    }
    return self;
}

-(void)pauseRecord
{
    [self.previewLayer pause];
}
-(void)resumeRecord
{
    [self.previewLayer start];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.previewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.tabBar.frame = self.previewLayer.frame;
}

@end

