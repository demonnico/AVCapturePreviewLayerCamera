//
//  NTCaptureAnimationLayer.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/26/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTCaptureAnimationView.h"

@implementation NTCaptureAnimationView

-(void)playAnimationWithOrientation:(UIDeviceOrientation)orientation
{
    CGFloat fromWidth = 320;
    CGFloat fromHeight = self.frame.size.height/self.frame.size.width*fromWidth;
    
    CGFloat toHeight = 100.0;
    CGFloat toWidth  = toHeight*fromWidth/fromHeight;
    CGFloat radius = 0;
    CGFloat toScale  =  toHeight/fromHeight;
    CGPoint leftUpperPoint = CGPointMake(60, 300);
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            radius = M_PI;
            break;
        case UIDeviceOrientationLandscapeLeft:
            toScale  = toHeight/fromWidth;
            radius = -M_PI_2;
            toWidth  = toHeight*fromHeight/fromWidth;
            break;
        case UIDeviceOrientationLandscapeRight:
            toScale  = toHeight/fromWidth;
            radius = M_PI_2;
            toWidth  = toHeight*fromHeight/fromWidth;
            break;
        default:
            break;
    }
    CGPoint toPoint = CGPointMake(leftUpperPoint.x+toWidth/2, leftUpperPoint.y+toHeight/2);
    
    CGFloat animationDuration = 1.3;
    CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnimation setDuration:animationDuration];
    [scaleAnimation setFromValue:@1.0];
    [scaleAnimation setToValue:@(toScale)];
    
    CABasicAnimation * rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [rotateAnimation setDuration:animationDuration];
    [rotateAnimation setFromValue:@0];
    [rotateAnimation setToValue:@(radius)];
    
    CABasicAnimation * translateAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [translateAnimation setDuration:animationDuration];
    [translateAnimation setFromValue:[NSValue valueWithCGPoint:self.layer.position]];
    [translateAnimation setToValue:[NSValue valueWithCGPoint:toPoint]];
    
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:@[scaleAnimation,translateAnimation,rotateAnimation]];
    [animationGroup setDuration:animationDuration];
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self;

    [self.layer addAnimation:animationGroup forKey:@"holyAnimation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self removeFromSuperview];
    }
}

@end
