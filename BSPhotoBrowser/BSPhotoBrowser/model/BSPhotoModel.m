//
//  BSPhotoModel.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoModel.h"

#import "BSPTool.h"
#import <Photos/Photos.h>

@interface BSPhotoModel ()

@property (nonatomic, assign) CGSize thumbSize;

@end

@implementation BSPhotoModel

- (void)getThumbImageWithSize:(CGSize)size
                    completed:(void (^)(UIImage *))completed
{
    if (CGSizeEqualToSize(CGSizeZero, size))
    {
        size = CGSizeMake(kScreenWidth, KScreenHeight);
    }
    
    if (_thumbImage
        && CGSizeEqualToSize(_thumbSize, size))
    {
        if (completed)
        {
            completed(_thumbImage);
        }
        return;
    }
    
    _thumbSize = size;
    [[BSPTool shareInstance] getPhotoWithAsset:_asset
                                              size:_thumbSize
                                     isSynchronous:NO
                                        completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded)
    {
        _thumbImage = photo;
        if (photo && completed)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completed(_thumbImage);
            });
        }
    }];
}

- (void)getOriginImageWithCompleted:(void (^)(UIImage *))completed
{
    if (_originImage && completed)
    {
        completed(_originImage);
        return;
    }
    
    [[BSPTool shareInstance] getOriginalPhotoWithAsset:_asset
                                                completion:^(UIImage *photo, NSDictionary *info)
     {
         _originImage = photo;
         if (photo && completed)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 completed(_originImage);
             });
         }
     }];
}

#pragma mark - override
- (void)setAsset:(PHAsset *)asset
{
    if (_asset != asset)
    {
        _asset = asset;
        
        _thumbImage = nil;
        _originImage = nil;
        
        _mediaType = (BSAssetMediaType)asset.mediaType;
        if (_mediaType == BSAssetMediaTypeVideo)
        {
            _duration = _asset.duration;
        }
        
        [self getOriginImageWithCompleted:nil];
        [self getThumbImageWithSize:CGSizeMake(kScreenWidth, KScreenHeight) completed:nil];
    }
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[BSPhotoModel class]])
    {
        BSPhotoModel *other = (BSPhotoModel *)object;
        
        return [_asset isEqual:other.asset];
    }
    return NO;
}

@end
