//
//  NTCaptureLayer.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/25/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTCaptureLayer.h"
#import "NSDetectOrientationManager.h"
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                                                     UIImage * image = [UIImage imageWithData:imageData scale:0];
                                                     ALAssetsLibrary * library = [ALAssetsLibrary new];
                                                     [library writeImageToSavedPhotosAlbum:image.CGImage
                                                                               orientation:[self assetOrientation]
                                                                           completionBlock:^(NSURL *assetURL, NSError *error) {
                                                                                captureblock(image,error);
                                                                               weakSelf.pictureTaking = NO;
                                                                           }];
                                                 }else{
                                                   weakSelf.pictureTaking = NO;
                                                 }
                                             }];
}

-(ALAssetOrientation)assetOrientation
{
    UIDeviceOrientation currentOrientation = [NSDetectOrientationManager sharedInstance].currentOrientation;
    ALAssetOrientation assetOrientation = ALAssetOrientationUp;
    switch (currentOrientation){
        case UIDeviceOrientationPortrait:
            return ALAssetOrientationRight;
        case UIDeviceOrientationPortraitUpsideDown:
            return ALAssetOrientationLeft;
        case UIDeviceOrientationLandscapeLeft:
            return ALAssetOrientationUp;
        case UIDeviceOrientationLandscapeRight:
            return ALAssetOrientationDown;
            break   ;
        default:
            return ALAssetOrientationRight;
            break;
    }
    return assetOrientation;
}

@end
