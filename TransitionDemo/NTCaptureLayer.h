//
//  NTCaptureLayer.h
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/25/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@import AVFoundation;

@class AVCaptureVideoPreviewLayer;
typedef void(^captureBlock)(UIImage *image, NSError *error);
@interface NTCaptureLayer : AVCaptureVideoPreviewLayer
-(void)start;
-(void)pause;
-(void)switchCamera;
-(void)takePictureWithHandler:(captureBlock)captureblock;
@end
