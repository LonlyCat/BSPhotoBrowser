//
//  BSPAlbumModel.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPAlbumModel.h"
#import <Photos/Photos.h>

@implementation BSPAlbumModel

+ (instancetype)modelWithFetchResult:(PHFetchResult *)result
                                name:(NSString *)name
{
    BSPAlbumModel *model = [[BSPAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    return model;
}

#pragma mark - override
- (void)setResult:(PHFetchResult *)result
{
    _result = result;
    
    _count = _result.count;
}

@end
