//
//  NTImagePickerViewController.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/25/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTImagePickerViewController.h"
@import AssetsLibrary;

@interface NTImagePickerViewController()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@end

@implementation NTImagePickerViewController
-(id)initCapture
{
    self = [super init];
    if(self){
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.showsCameraControls = YES;
        self.delegate = self;
    }
    return self;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * originalImage =  [info valueForKey:UIImagePickerControllerOriginalImage];
    ALAssetsLibrary * library = [ALAssetsLibrary new];
    [library writeImageToSavedPhotosAlbum:originalImage.CGImage
                                 metadata:nil
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              NSLog(@"assetURL:%@",assetURL);
                              NSLog(@"error:%@",error);
                              if (self.finishblock)
                                  self.finishblock(originalImage);
                              [self dismissViewControllerAnimated:YES
                                                       completion:nil];
                          }];
    
}

@end
