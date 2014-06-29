//
//  NTCaptureLayer.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/25/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTCaptureLayer.h"
#import "NTOrientationDetector.h"
#import <ImageIO/ImageIO.h>
@import AssetsLibrary;

@interface NTCaptureLayer()
@property (nonatomic,assign) BOOL pictureTaking;
@end

@implementation NTCaptureLayer
{
    BOOL isUsingFrontFacingCamera;
}
- (void)dealloc
{
    NSLog(@"capture dealloc");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        AVCaptureDevice       *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError * error = nil;
        [inputDevice lockForConfiguration:&error];
        inputDevice.flashMode = AVCaptureFlashModeAuto;
        inputDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
        
        AVCaptureStillImageOutput *captureOutput = [[AVCaptureStillImageOutput alloc] init];
        
        AVCaptureSession * captureSession = [AVCaptureSession new];
        captureSession.sessionPreset =  AVCaptureSessionPresetPhoto;
        [captureSession addInput:captureInput];
        [captureSession addOutput:captureOutput];
        
        [self setSession:captureSession];
         self.fillMode  = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

-(void)switchCamera
{
    AVCaptureDevicePosition desiredPosition;
    if (isUsingFrontFacingCamera) {
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [[self session] beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in [[self session] inputs]) {
                [[self session] removeInput:oldInput];
            }
            [[self session] addInput:input];
            [[self session] commitConfiguration];
            isUsingFrontFacingCamera=!isUsingFrontFacingCamera;
            break;
        }
    }
}

-(void)start
{
    [[self session] startRunning];
}
-(void)pause
{
    [[self session] stopRunning];
}

-(void)takePictureWithHandler:(captureBlock)captureblock
{
    if (self.pictureTaking) {
        return;
    }
    self.pictureTaking = YES;
    AVCaptureStillImageOutput * imageOutput = [self session].outputs[0];
    AVCaptureConnection * connection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
    __weak __typeof(&*self)weakSelf = self;
    [imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                 if (!error) {
                                                     NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                     //if you wanna know something in default metadata, uncomment these lines.
//                                                     NSDictionary * dic =
//                                                     (__bridge NSDictionary*)CMCopyDictionaryOfAttachments(NULL, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
//                                                     NSLog(@"default metadata:%@",dic);
                                                     ALAssetsLibrary * library = [ALAssetsLibrary new];
                                                     [library writeImageDataToSavedPhotosAlbum:imageData
                                                                                      metadata:[self metaData]
                                                                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                                                                   weakSelf.pictureTaking = YES;
                                                                                   captureblock(error);
                                                                               }];
                                                 }else{
                                                   weakSelf.pictureTaking = NO;
                                                 }
                                             }];
}

-(void)takePictureAndPlayAnimationWithDestination:(animationDestination)destination
                                    finishHandler:(captureBlock)captureblock
{
    __weak __typeof(&*self)weakSelf = self;
    [self takePictureWithHandler:^(NSError *error) {
        [weakSelf pause];
        [weakSelf playAnimationWithDestination:destination];
        captureblock(error);
    }];
}

-(NSDictionary*)metaData
{
    UIDeviceOrientation  deviceOrientation =
    [NTOrientationDetector sharedInstance].currentOrientation;
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (deviceOrientation){
        case UIDeviceOrientationPortrait:
            orientation = UIImageOrientationRight;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation =  UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation =  UIImageOrientationDown;
            break  ;
        default:
            orientation = UIImageOrientationRight;
            break;
    }
    NSInteger metaOrientation = [self metaOrientation:orientation];
    NSDictionary * metaData = [NSDictionary dictionaryWithObject:@(metaOrientation)
                                                          forKey:(NSString*)kCGImagePropertyOrientation];
    return metaData;
}

-(NSInteger)metaOrientation:(UIImageOrientation)orientation
{
    int metaOrientation = 1;
    switch (orientation) {
        case UIImageOrientationUp:
            metaOrientation = 1;
            break;
            
        case UIImageOrientationDown:
            metaOrientation = 3;
            break;
            
        case UIImageOrientationLeft:
            metaOrientation = 8;
            break;
            
        case UIImageOrientationRight:
            metaOrientation = 6;
            break;
            
        case UIImageOrientationUpMirrored:
            metaOrientation = 2;
            break;
            
        case UIImageOrientationDownMirrored:
            metaOrientation = 4;
            break;
            
        case UIImageOrientationLeftMirrored:
            metaOrientation = 5;
            break;
            
        case UIImageOrientationRightMirrored:
            metaOrientation = 7;
            break;
    }
    return metaOrientation;
}

-(void)playAnimationWithDestination:(animationDestination)destination
{
    CGFloat fromWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    CGFloat fromHeight = self.frame.size.height/self.frame.size.width*fromWidth;
    
    CGFloat toHeight = destination.height;
    CGFloat toWidth  = toHeight*fromWidth/fromHeight;
    CGFloat radius = 0;
    CGFloat toScale  =  toHeight/fromHeight;
    CGPoint leftUpperPoint = destination.topLeft;
    
    UIDeviceOrientation orientation = [NTOrientationDetector sharedInstance].currentOrientation;
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
    
    CGFloat animationDuration = 0.5;
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
    [translateAnimation setFromValue:[NSValue valueWithCGPoint:self.position]];
    [translateAnimation setToValue:[NSValue valueWithCGPoint:toPoint]];
    
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:@[scaleAnimation,translateAnimation,rotateAnimation]];
    [animationGroup setDuration:animationDuration];
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self.animationDelegate;
    
    [self addAnimation:animationGroup forKey:@"holyAnimation"];
}

@end
