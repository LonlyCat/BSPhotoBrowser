//
//  ViewController.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "ViewController.h"
#import "BSPhotoBrowser.h"

@interface ViewController () <BSPhotoBrowserDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[BSPhotoBrowser shareInstance] showBrowerWithMediaType:BSAssetMediaTypeAll
                                                   delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BSPhotoBrowserDelegate
- (void)browserDidSelectedImages:(NSArray<UIImage *> *)images
{
    NSLog(@"image: %@", images);
}

- (void)browserDidSelectedVideo:(NSURL *)videoUrl
{
    
}

- (void)browserCancleSelected
{
    
}

@end
