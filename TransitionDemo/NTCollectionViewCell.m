//
//  NTCollectionViewCell.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/24/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTCollectionViewCell.h"
@import AVFoundation;
@import AssetsLibrary;

@interface NTCollectionViewCell()
@property (nonatomic,strong) UIImageView * imageView;
@end

@implementation NTCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [UIImageView new];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.image = nil;
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGImageRef imageRef = [self.asset aspectRatioThumbnail];
    self.imageView.image = [UIImage imageWithCGImage:imageRef];
}

@end
