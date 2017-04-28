//
//  BSAlbumModel.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSAlbumModel.h"
#import <Photos/Photos.h>

@implementation BSAlbumModel

+ (instancetype)modelWithFetchResult:(PHFetchResult *)result
                                name:(NSString *)name
{
    BSAlbumModel *model = [[BSAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    return model;
}

#pragma mark - setter
- (void)setResult:(PHFetchResult *)result
{
    _result = result;
    
    _count = _result.count;
}

@end
