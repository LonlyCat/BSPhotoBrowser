//
//  BSPhotoBrowser.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoBrowser.h"

@interface BSPhotoBrowser ()

@property (nonatomic, weak) UINavigationController   *nav;
@property (nonatomic, weak) BSPhotoBrowserController *browserVC;

@property (nonatomic, weak) UIViewController<BSPhotoBrowserDelegate> *delegate;

@property (nonatomic, assign) BSAssetMediaType mediaType;

@end

@implementation BSPhotoBrowser

+ (instancetype)shareInstance
{
    static BSPhotoBrowser *browser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        browser = [[BSPhotoBrowser alloc] init];
    });
    return browser;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _maxImageCount = 6;
    }
    return self;
}

- (void)showBrowerWithMediaType:(BSAssetMediaType)type
                       delegate:(UIViewController<BSPhotoBrowserDelegate> *)delegate
{
    _mediaType = type;
    _delegate = delegate;
    
    BSPhotoBrowserController *browserVC = [[BSPhotoBrowserController alloc] init];
    browserVC.maxImageCount = _maxImageCount;
    browserVC.selectPhotos = _selectPhotos;
    browserVC.mediaType = _mediaType;
    browserVC.delegate = _delegate;
    _browserVC = browserVC;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browserVC];
    nav.navigationBar.translucent = NO;
    _nav = nav;
    
    [_delegate presentViewController:nav animated:YES completion:^{
        
    }];
}

@end
