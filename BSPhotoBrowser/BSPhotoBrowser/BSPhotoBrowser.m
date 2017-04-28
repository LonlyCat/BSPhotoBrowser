//
//  BSPhotoBrowser.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoBrowser.h"
#import "BSPhotoBrowserController.h"

@interface BSPhotoBrowser ()

@property (nonatomic, weak) UINavigationController   *nav;
@property (nonatomic, weak) BSPhotoBrowserController *browserVC;

@property (nonatomic, weak) UIViewController<BSPhotoBrowserDelegate> *delegate;

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

- (void)showBrowerWithDelegate:(UIViewController<BSPhotoBrowserDelegate> *)delegate
{
    _delegate = delegate;
    
    BSPhotoBrowserController *browserVC = [[BSPhotoBrowserController alloc] init];
    browserVC.maxImageCount = _maxImageCount;
    browserVC.selectPhotos = _selectPhotos;
    _browserVC = browserVC;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browserVC];
    nav.navigationBar.translucent = NO;
    _nav = nav;
    
    [_delegate presentViewController:nav animated:YES completion:^{
        
    }];
}

@end
