//
//  BSPAlbumListCell.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/5/2.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPAlbumListCell.h"
#import "BSPhotoModel.h"
#import "BSPTool.h"

@interface BSPAlbumListCell ()

@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UILabel *titlaLable;
@property (nonatomic, strong) BSPAlbumModel *albumModel;

@end

@implementation BSPAlbumListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 6, 50, 50)];
    _photoView.layer.masksToBounds = YES;
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_photoView];
    
    _titlaLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 6, 200, 50)];
    _titlaLable.textColor = [UIColor blackColor];
    _titlaLable.textAlignment = NSTextAlignmentLeft;
    [_titlaLable setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:18]];
    [self.contentView addSubview:_titlaLable];
}

- (void)configWithModel:(BSPAlbumModel *)model
{
    if (model == _albumModel)
    {
        return;
    }
    _albumModel = model;
    // 设置标题
    NSString *text = [NSString stringWithFormat:@"%@ %@", model.name, @(model.count)];
    
    NSMutableAttributedString *aText = [[NSMutableAttributedString alloc] initWithString:text];
    [aText setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12]}
                   range:NSRangeFromString(text)];
    [aText setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:18]}
                   range:[text rangeOfString:model.name]];
    
    _titlaLable.attributedText = aText;
    
    // 设置封面
    __weak typeof(self) weakSelf = self;
    [[BSPTool shareInstance] getAssetsFromFetchResult:model.result
                                           completion:^(NSArray<BSPhotoModel *> *models)
     {
         BSPhotoModel *pModel = [models firstObject];
         
         [pModel getThumbImageWithSize:CGSizeZero completed:^(UIImage *image)
         {
             weakSelf.photoView.image = image;
         }];
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected)
    {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
