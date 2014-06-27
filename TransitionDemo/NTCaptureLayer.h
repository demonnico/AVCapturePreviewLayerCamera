//
//  NTCaptureLayer.h
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/25/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@import AVFoundation;
@class NTCaptureLayer;
@class AVCaptureVideoPreviewLayer;

struct animationDestination {
    CGPoint topLeft;
    CGFloat height;
};
typedef struct animationDestination animationDestination;

typedef void(^captureBlock)(NSError *error);
@interface NTCaptureLayer : AVCaptureVideoPreviewLayer
/**
 *  please implement -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag method,
 *  and remove previewLayer in that place.
 */
@property (nonatomic,weak) id animationDelegate;

-(void)start;
-(void)pause;
-(void)switchCamera;
-(void)takePictureAndPlayAnimationWithDestination:(animationDestination)destination
                                    finishHandler:(captureBlock)captureblock;
@end
