// CLLAccelerometerOrientation.m
//
// Copyright (c) 2012 Shigeyuki Takeuchi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CLLAccelerometerOrientation.h"

@implementation CLLAccelerometerOrientation {
    CMMotionManager *manager;
    UIDeviceOrientation past_orientation;
}

NSString * const CLLAccelerometerOrientationDidChangeNotification = @"AccelerometerOrientationDidChangeNotification";

struct CLLAccelerationMatrix {
    UIDeviceOrientation type;
    CMAcceleration acceration;
};

#define MATRIX_SIZE 6

static const struct CLLAccelerationMatrix orientation_matrix[MATRIX_SIZE] = {
//    { UIDeviceOrientationUnknown, {  0.0f,  0.0f,  0.0f } },
    { UIDeviceOrientationPortrait, {  0.0f, -1.0f,  0.0f } },
    { UIDeviceOrientationPortraitUpsideDown, {  0.0f,  1.0f,  0.0f } },
    { UIDeviceOrientationLandscapeLeft, { -1.0f,  0.0f,  0.0f } },
    { UIDeviceOrientationLandscapeRight, {  1.0f,  0.0f,  0.0f } },
    { UIDeviceOrientationFaceUp, {  0.0f,  0.0f, -1.0f } },
    { UIDeviceOrientationFaceDown, {  0.0f,  0.0f,  1.0f } },
};

#pragma mark - Lifecycle

-(id)init
{
    self = [super init];
    if (self) {
        manager = [[CMMotionManager alloc] init];
        past_orientation = UIDeviceOrientationUnknown;
    }
    
    return self;
}

-(void)dealloc
{
    [self stop];
}

#pragma mark -

-(void)start
{
    past_orientation = UIDeviceOrientationUnknown;
    
    if (!manager.accelerometerAvailable) {
        return;
    }
    
    manager.accelerometerUpdateInterval = 1; // 1Hz
   
    __weak __typeof(&*self)weakSelf = self;
    [manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                  withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [weakSelf accelerometerUpdateCallback:accelerometerData withError:error];
    }];
}

-(void)stop
{
    if (manager && manager.accelerometerActive) {
        [manager stopAccelerometerUpdates];
    }
}

-(UIDeviceOrientation)orientation
{
    return past_orientation;
}

-(void)accelerometerUpdateCallback:(CMAccelerometerData*)accelerometerData withError:(NSError*)error
{    
    CMAcceleration acceleration = accelerometerData.acceleration;

    UIDeviceOrientation current_orientation = [self convertAccelerationToOrientation:acceleration];
    if (past_orientation != current_orientation) {
        past_orientation  = current_orientation;
        NSNotification *notification = [NSNotification notificationWithName:CLLAccelerometerOrientationDidChangeNotification
                                                                     object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

-(UIDeviceOrientation)convertAccelerationToOrientation:(CMAcceleration)acceleration
{
    UIDeviceOrientation ret = UIDeviceOrientationUnknown;
    double diff = 100;
    
    for (int i = 0; i <= MATRIX_SIZE; i++) {
        double tmp = sqrt(
                          pow((orientation_matrix[i].acceration.x - acceleration.x), 2)
                          + pow((orientation_matrix[i].acceration.y - acceleration.y), 2)
                          + pow((orientation_matrix[i].acceration.z - acceleration.z), 2)
                          );

        if (diff > tmp) {
            diff = tmp;
            ret = orientation_matrix[i].type;
        }
    }
    
    return ret;
}

@end