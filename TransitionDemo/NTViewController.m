//
//  NTViewController.m
//  TransitionDemo
//
//  Created by Nicholas Tau on 6/24/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTViewController.h"
#import "NTCollectionViewCell.h"
#import "NTCollectionCaptureCell.h"
#import "NTImagePickerViewController.h"
#import "NTCaptureLayer.h"
#import "NTCaptureAnimationView.h"

@import AssetsLibrary;
@interface NTViewController ()
@property (nonatomic,strong) ALAssetsLibrary * library;
@property (nonatomic,strong) NSMutableArray * assets;

@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,weak) NTCaptureLayer * captureLayer;
@end

@implementation NTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UICollectionViewFlowLayout * flowLayout =
    [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView * collectionView =
    [[UICollectionView alloc] initWithFrame:CGRectMake(0, 300, 320, 100)
                       collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceHorizontal = YES;
    collectionView.directionalLockEnabled = YES;
    collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:collectionView];

    self.collectionView = collectionView;
    [collectionView registerClass:[NTCollectionCaptureCell class]
       forCellWithReuseIdentifier:@"cell0"];
    [collectionView registerClass:[NTCollectionViewCell class]
       forCellWithReuseIdentifier:@"cell1"];
    
    self.assets = [NSMutableArray array];
    self.library =
    [[ALAssetsLibrary alloc] init];
    [self reloadCollectionViewWithCompleteBlock:nil];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Take"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(takePicture)];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        self.captureLayer.contents = nil;
        [self.captureLayer removeFromSuperlayer];
    }
}

-(void)takePicture
{
    __weak __typeof(&*self)weakSelf = self;
    animationDestination destination;
    destination.height = 100.0;
    destination.topLeft = CGPointMake(60, 300);
    [self.captureLayer takePictureAndPlayAnimationWithDestination:destination
                                                    finishHandler:^(NSError *error) {
        if (!error) {
            [weakSelf.assets insertObject:[ALAsset new]
                                  atIndex:0];
            [weakSelf.collectionView performBatchUpdates:^{
                [weakSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]];
            }
                                              completion:^(BOOL finished) {
                                                  [self.assets removeAllObjects];
                                                  [self reloadCollectionViewWithCompleteBlock:^{
                                                      NTCollectionCaptureCell * captureCell
                                                      =(NTCollectionCaptureCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                                                      [captureCell resumeRecord];
                                                  }];
                                              }];
        }
    }];
}

typedef void(^completeBlock)();
-(void)reloadCollectionViewWithCompleteBlock:(completeBlock)completeblock
{
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                           usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                               if(index!=NSIntegerMax){
                                                                   [self.assets addObject:result];
                                                               }else{
                                                                   [self.collectionView reloadData];
                                                                   if (completeblock) {
                                                                       completeblock();
                                                                   }
                                                               }
                                                           }];
                                }
                              failureBlock:nil];

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row) {
        return CGSizeMake(320*collectionView.frame.size.height/568, collectionView.frame.size.height);
    }
    ALAsset * asset = self.assets[indexPath.row-1];
    ALAssetRepresentation * representation =  [asset defaultRepresentation];
    CGSize originalSize = representation.dimensions;
    if (!representation) {//first asset
        originalSize = CGSizeMake(320, 427);//320*4/3-->4:3
    }
    CGFloat height = collectionView.frame.size.height;
    CGFloat width = originalSize.width*height/originalSize.height;
    width = width<=320?width:320;
    return CGSizeMake(width, height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.row&&
        !self.captureLayer) {
        NTCollectionCaptureCell * cell =
        (NTCollectionCaptureCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [cell pauseRecord];
        
        NTCaptureLayer * captureLayer =
        [NTCaptureLayer layer];
        captureLayer.frame =
//        CGRectMake(originalPoint.x, originalPoint.y, cell.frame.size.width, cell.frame.size.height);
        CGRectMake(0, 44+20, 320, 427);//320*4/3-->4:3
        [self.view.layer addSublayer:captureLayer];
        captureLayer.animationDelegate = self;
        [captureLayer start];
        
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setDuration:0.3];
        [animation setFromValue:@0.0];
        [animation setToValue:@1.0];
        [captureLayer addAnimation:animation forKey:@"alpha_animation"];
        
        self.captureLayer = captureLayer;
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = nil;
    if (indexPath.row) {
        NTCollectionViewCell * viewCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"cell1"
                                                  forIndexPath:indexPath];
        viewCell.asset = self.assets[indexPath.row-1];
        cell = viewCell;
    }else{
        NTCollectionCaptureCell * captureCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"cell0"
                                                  forIndexPath:indexPath];
        cell = captureCell;
    }
    [cell layoutSubviews];
    return cell;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return (UIInterfaceOrientation)UIInterfaceOrientationMaskAll;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count+1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
