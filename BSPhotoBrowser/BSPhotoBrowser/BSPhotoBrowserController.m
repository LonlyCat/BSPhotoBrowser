//
//  BSPhotoBrowserController.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoBrowserController.h"

@interface BSPhotoBrowserController ()

/**
 所有相册
 */
@property (nonatomic, strong) NSArray *albums;

/**
 相册中的所有图片
 */
@property (nonatomic, strong) NSArray *albumPhotos;

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@end

@implementation BSPhotoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
