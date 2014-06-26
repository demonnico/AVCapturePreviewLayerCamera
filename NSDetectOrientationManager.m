//
//  NSDetectOrientationManager.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/26/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NSDetectOrientationManager.h"
@import CoreMotion;
@interface NSDetectOrientationManager()
@property (nonatomic,strong) CMMotionManager * motionManager;
@property (nonatomic,readwrite,assign) UIDeviceOrientation currentOrientation;
@end

@implementation NSDetectOrientationManager

struct CLLAccelerationMatrix {
    UIDeviceOrientation type;
    CMAcceleration acceration;
};

NSString * const kAccelerometerOrientationDidChangeNotification = @"kAccelerometerOrientationDidChangeNotification";

#define MATRIX_SIZE 7
static const struct CLLAccelerationMatrix orientation_matrix[MATRIX_SIZE] = {
    { UIDeviceOrientationUnknown, {  0.0f,  0.0f,  0.0f } },
    { UIDeviceOrientationPortrait, {  0.0f, -1.0f,  0.0f } },
    { UIDeviceOrientationPortraitUpsideDown, {  0.0f,  1.0f,  0.0f } },
    { UIDeviceOrientationLandscapeLeft, { -1.0f,  0.0f,  0.0f } },
    { UIDeviceOrientationLandscapeRight, {  1.0f,  0.0f,  0.0f } },
    { UIDeviceOrientationFaceUp, {  0.0f,  0.0f, -1.0f } },
    { UIDeviceOrientationFaceDown, {  0.0f,  0.0f,  1.0f } },
};

static NSDetectOrientationManager * _instance;
+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [NSDetectOrientationManager new];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [self removeObsever];
}

-(void)callbackWithAccelerometerData:(CMAccelerometerData*)accelerometerData andError:(NSError*)error
{
    
    UIDeviceOrientation orientation = [self deviceOrientationWithAcceleration:accelerometerData.acceleration];
    if (self.currentOrientation!=orientation) {
        self.currentOrientation = orientation;
        [[NSNotificationCenter defaultCenter] postNotificationName:kAccelerometerOrientationDidChangeNotification
                                                            object:self];
    }
}

-(UIDeviceOrientation)deviceOrientationWithAcceleration:(CMAcceleration)acceleration
{
    UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
    double diff = 100;
    
    for (int i = 0; i <= MATRIX_SIZE; i++) {
        double tmp = sqrt(
                          pow((orientation_matrix[i].acceration.x - acceleration.x), 2)
                          + pow((orientation_matrix[i].acceration.y - acceleration.y), 2)
                          + pow((orientation_matrix[i].acceration.z - acceleration.z), 2)
                          );//空间亮点距离公式
        
        if (diff > tmp) {//求出最短距离（最接近的值）
            diff = tmp;
            orientation = orientation_matrix[i].type;
        }
    }
    return orientation;
}

-(CMMotionManager*)motionManager
{
    if (!_motionManager) {
        _motionManager = [CMMotionManager new];
        _motionManager.accelerometerUpdateInterval = 1.0;
    }
    return _motionManager;
}

-(void)startObsever
{
    if(self.motionManager.isAccelerometerAvailable){
        __weak __typeof(&*self)weakSelf = self;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                     [weakSelf callbackWithAccelerometerData:accelerometerData
                                                                                    andError:error];
                                                 }];
    }
}

-(void)removeObsever
{
    if (self.motionManager&&self.motionManager.accelerometerActive) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

@end
