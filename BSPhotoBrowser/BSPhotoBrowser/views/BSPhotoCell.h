//
//  BSPhotoCell.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/5/2.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSPhotoModel;

@protocol BSPhotoCellDelegate <NSObject>

- (void)selectButtonDidClicked:(UICollectionViewCell *)cell;

@end

@interface BSPhotoCell : UICollectionViewCell

@property (nonatomic, assign) BOOL hasSelected;
@property (nonatomic, weak) id<BSPhotoCellDelegate> delegate;

- (void)configWithModel:(BSPhotoModel *)model;

@end
