//
//  BSPhotoPreviewController.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSPConst.h"

@class BSPhotoModel;
@interface BSPhotoPreviewController : UIViewController

/** 最大照片选择数 */
@property (nonatomic, assign) NSInteger maxImageCount;
/** 最大视频时长 */
@property (nonatomic, assign) NSInteger maxVideoSec;
/** 最大视频字节数 */
@property (nonatomic, assign) NSInteger maxVideoByte;
/** 媒体类型 */
@property (nonatomic, assign) BSAssetMediaType mediaType;
/** 展示文件下标 */
@property (nonatomic, assign) NSInteger currentIndex;
/** 展示的图片 */
@property (nonatomic, strong) NSArray<BSPhotoModel *> *photos;
/** 选中的图片 */
@property (nonatomic, strong) NSMutableArray<BSPhotoModel *> *selectPhotos;
/** 当控制器返回时调用 selectPhotos: 选中的照片 */
@property (nonatomic, copy) void(^previewCompleted)(NSMutableArray *selectPhotos);
/** 点击确定按钮时调用 selectPhotos: 选中的照片 */
@property (nonatomic, copy) void(^doneButtonHandle)(NSMutableArray *selectPhotos);

@end
