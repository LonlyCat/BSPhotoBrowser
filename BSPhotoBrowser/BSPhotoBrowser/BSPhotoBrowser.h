//
//  BSPhotoBrowser.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BSPhotoModel;

@protocol BSPhotoBrowserDelegate <NSObject>

- (void)browserDidSelectedImages:(NSArray<BSPhotoModel *> *)images;
- (void)browserCancleSelected;

@end

@interface BSPhotoBrowser : NSObject

/**
 最大照片选择数 default: 6
 */
@property (nonatomic, assign) NSInteger maxImageCount;
//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray<BSPhotoModel *> *arraySelectPhotos;

@end
