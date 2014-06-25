//
//  NTImagePickerViewController.h
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/25/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^finishBlock)(UIImage * originalImage);
@interface NTImagePickerViewController : UIImagePickerController
@property (nonatomic,copy) finishBlock finishblock;
-(id)initCapture;
@end
