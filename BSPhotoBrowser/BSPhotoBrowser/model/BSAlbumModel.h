//
//  BSAlbumModel.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHFetchResult;
@interface BSAlbumModel : NSObject

/** 相簿名字 */
@property (nonatomic, strong) NSString      *name;
/** 相簿中照片数量 */
@property (nonatomic, assign) NSInteger     count;
/** PHAsset 的集合 */
@property (nonatomic, strong) PHFetchResult *result;

+ (instancetype)modelWithFetchResult:(PHFetchResult *)result
                                name:(NSString *)name;

@end
