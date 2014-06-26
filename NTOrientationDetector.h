//
//  NSDetectOrientationManager.h
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/26/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kAccelerometerOrientationDidChangeNotification;
@interface NTOrientationDetector : NSObject

@property (nonatomic,readonly,assign) UIDeviceOrientation currentOrientation;
+(instancetype)sharedInstance;
-(void)startDetect;
-(void)stopDetect;
@end
