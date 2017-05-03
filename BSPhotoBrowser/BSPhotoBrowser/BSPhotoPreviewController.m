//
//  BSPhotoPreviewController.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoPreviewController.h"
#import "BSPPreviewCell.h"
#import "BSPPlayerView.h"
#import "BSPTool.h"
#import <Photos/Photos.h>

@interface BSPhotoPreviewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

/** 确定按钮 */
@property (nonatomic, strong) UIButton *doneButton;
/** 选择按钮 */
@property (nonatomic, strong) UIButton *selectButton;
/** 视频播放 */
@property (nonatomic, strong) BSPPlayerView *playerView;
/** 照片展示 */
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BSPhotoPreviewController

static NSString *const identifier = @"previewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self filterPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_previewCompleted)
    {
        _previewCompleted(self.selectPhotos);
    }
    
    [_playerView pause];
    [_playerView removeFromSuperview];
    _playerView = nil;
    
    [super viewWillDisappear:animated];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    // 确定按钮
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(0, 0, 70, 30);
    _doneButton.backgroundColor = [UIColor blackColor];
    _doneButton.layer.cornerRadius = 3;
    [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(rightBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_doneButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (_mediaType == BSAssetMediaTypeImage)
    {
        // collection view
        CGFloat itemMargin = 10;
        CGFloat itemWidth = kScreenWidth;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(itemWidth, KScreenHeight);
        layout.minimumLineSpacing = itemMargin;
        layout.minimumInteritemSpacing = itemMargin;
        layout.sectionInset = UIEdgeInsetsMake(0, itemMargin, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-itemMargin,
                                                                             0,
                                                                             kScreenWidth + itemMargin,
                                                                             KScreenHeight)
                                             collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[BSPPreviewCell class] forCellWithReuseIdentifier:identifier];
        [self.view addSubview:_collectionView];
        
        // 选择按钮
        UIImage *nImage = [UIImage imageNamed:@"browser_choose_normal"];
        UIImage *sImage = [UIImage imageNamed:@"browser_choose_pressed"];
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(kScreenWidth - nImage.size.width - 10,
                                         10,
                                         nImage.size.width,
                                         nImage.size.height);
        [_selectButton setImage:nImage forState:UIControlStateNormal];
        [_selectButton setImage:sImage forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectButton];
        
        [self refreshButtonStatus];
    }
    else
    {
        BSPhotoModel *model = [_photos firstObject];
        
        __weak typeof(self) weakSelf = self;
        [[BSPTool shareInstance] getVideoWithAsset:model.asset
                                         limitByte:0
                                        completion:^(NSURL *fileUrl, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 weakSelf.playerView = [[BSPPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, KScreenHeight)
                                                                  videoPath:fileUrl
                                                               previewImage:model.originImage];
                 [weakSelf.view addSubview:weakSelf.playerView];
             });
        }];
    }
}

- (void)refreshTitle
{
    _currentIndex = _collectionView.contentOffset.x / (kScreenWidth + 10);
    NSString *title = [NSString stringWithFormat:@"%@ / %@", @(_currentIndex + 1), @(_photos.count)];
    
    self.title = title;
}
#pragma mark - 
- (void)filterPhotos
{
    if (_mediaType != BSAssetMediaTypeVideo)
    {
        NSMutableArray *array = [NSMutableArray array];
        [_photos enumerateObjectsUsingBlock:^(BSPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.asset.mediaType == PHAssetMediaTypeImage)
            {
                [array addObject:obj];
            }
            else
            {
                if (idx < _currentIndex)
                {
                    _currentIndex --;
                }
            }
        }];
        _photos = array;
        [_collectionView reloadData];
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:NO];
        [self refreshTitle];
    }
}

#pragma mark - button action
- (void)rightBarButtonAction:(id)sender
{
    if (self.selectPhotos.count < 1)
    {
        [self.selectPhotos addObject:_photos[_currentIndex]];
    }
    
    if (_doneButtonHandle)
    {
        _doneButtonHandle(_selectPhotos);
    }
}

- (void)selectButtonAction:(id)sender
{
    BSPhotoModel *model = _photos[_currentIndex];
    
    if ([self.selectPhotos containsObject:model])
    {
        [self.selectPhotos removeObject:model];
    }
    else
    {
        if (_selectPhotos.count >= _maxImageCount)
        {
            NSLog(@"照片上限");
#warning 提示超出最大选择数
            return;
        }
        
        [self.selectPhotos addObject:model];
    }
    [self refreshButtonStatus];
}

- (void)refreshButtonStatus
{
    if (self.selectPhotos.count > 0)
    {
        NSString *title = [NSString stringWithFormat:@"确定(%@)", @(self.selectPhotos.count)];
        [_doneButton setTitle:title forState:UIControlStateNormal];
    }
    else
    {
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    
    BSPhotoModel *model = _photos[_currentIndex];
    if ([_selectPhotos containsObject:model])
    {
        _selectButton.selected = YES;
    }
    else
    {
        _selectButton.selected = NO;
    }
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSPPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                     forIndexPath:indexPath];
    
    BSPhotoModel *model = _photos[indexPath.item];
    [cell configWithModel:model];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self refreshTitle];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / kScreenWidth;
    if (scrollView.contentOffset.x - index * kScreenWidth > kScreenWidth / 2)
    {
        index += 1;
    }
    
    BSPhotoModel *model = _photos[index];
    if ([self.selectPhotos containsObject:model])
    {
        _selectButton.selected = YES;
    }
    else
    {
        _selectButton.selected = NO;
    }
}

#pragma mark - get
- (NSMutableArray<BSPhotoModel *> *)selectPhotos
{
    if (!_selectPhotos)
    {
        _selectPhotos = [NSMutableArray array];
    }
    return _selectPhotos;
}

@end
