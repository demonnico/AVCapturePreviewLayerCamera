//
//  NTCaptureAnimationLayer.h
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/26/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface NTCaptureAnimationView : UIImageView
/**
 *  play animation
 *  This UIImageView will be removed from superView after
 *  animation is finished.
 *  @param orientation current UIDeviceOrientation
 */
-(void)playAnimationWithOrientation:(UIDeviceOrientation)orientation;
@end
