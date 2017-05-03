//
//  BSPhotoBrowserController.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSPhotoModel.h"
#import "BSPConst.h"

@protocol BSPhotoBrowserDelegate <NSObject>

- (void)browserDidSelectedImages:(NSArray<UIImage *> *)images;
- (void)browserDidSelectedVideo:(NSURL *)videoUrl;
- (void)browserCancleSelected;

@end
@interface BSPhotoBrowserController : UIViewController

/** 最大照片选择数 default: 6 */
@property (nonatomic, assign) NSInteger maxImageCount;
/** 最大视频时长 default: 0 没有限制 */
@property (nonatomic, assign) NSInteger maxVideoSec;
/** 最大视频字节数 default: 0 没有限制 */
@property (nonatomic, assign) NSInteger maxVideoByte;
/** 相簿显示内容 */
@property (nonatomic, assign) BSAssetMediaType mediaType;
/** 代理对象 */
@property (nonatomic, weak) UIViewController<BSPhotoBrowserDelegate> *delegate;

@end
