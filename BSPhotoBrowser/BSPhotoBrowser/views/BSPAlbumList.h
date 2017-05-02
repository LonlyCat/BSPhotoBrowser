//
//  BSPhotoAlbumList.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BSPAlbumListDelegate <NSObject>

- (void)selectAlbumAtIndex:(NSInteger)index;

@end

@interface BSPAlbumList : UIView

@property (nonatomic, weak) NSArray *albums;
@property (nonatomic, weak) id<BSPAlbumListDelegate> delegate;

- (void)show;
- (void)hidden;

@end
