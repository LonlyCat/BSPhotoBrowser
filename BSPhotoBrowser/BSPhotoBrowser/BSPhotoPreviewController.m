//
//  BSPhotoPreviewController.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoPreviewController.h"
#import "BSPPreviewCell.h"
#import <Photos/Photos.h>

@interface BSPhotoPreviewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

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

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
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
}

- (void)refreshTitle
{
    _currentIndex = _collectionView.contentOffset.x / (kScreenWidth + 10) + 1;
    NSString *title = [NSString stringWithFormat:@"%@ / %@", @(_currentIndex), @(_photos.count)];
    
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

@end
