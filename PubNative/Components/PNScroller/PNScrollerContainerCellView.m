//
// PNScrollerContainerCellView.m
//
// Created by David Martin on 24/10/14.
// Copyright (c) 2014 PubNative.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "PNScrollerContainerCellView.h"
#import <QuartzCore/QuartzCore.h>
#import "PNScrollerViewCell.h"
#import "PNNativeAdModel.h"
#import "PNAdConstants.h"

@interface PNScrollerContainerCellView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic)     IBOutlet    UICollectionView        *collectionView;
@property (strong, nonatomic)               NSArray                 *collectionData;
@property (assign, nonatomic)               CGSize                  cellSize;
@property (assign, nonatomic)               NSInteger               currentIndex;

@end

@implementation PNScrollerContainerCellView

#pragma NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma UIView

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotateNotification:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self updateCollectionViewLayout];
    
    NSString *classname = NSStringFromClass([PNScrollerViewCell class]);
    
    // Register Portrait cells (ID=PNSCrollerViewCell)
    NSString *portraitCellName = classname;
    UINib *portraitCellNib = [UINib nibWithNibName:portraitCellName bundle:nil];
    [self.collectionView registerNib:portraitCellNib forCellWithReuseIdentifier:portraitCellName];
    
    // Register Landscape cells (ID=PNSCrollerViewCell-landscape)
    NSString *landscapeCellName = [NSString stringWithFormat:@"%@-landscape", classname];
    UINib *landscapeCellNib = [UINib nibWithNibName:landscapeCellName bundle:nil];
    [self.collectionView registerNib:landscapeCellNib forCellWithReuseIdentifier:landscapeCellName];
    
    self.currentIndex = 0;
    
    [self addSponsorLabel];
}

#pragma PNScrollerContainerCellView

- (void)didRotateNotification:(NSNotification*)notification
{
    [self updateCollectionViewLayout];
    [self.collectionView reloadData];
}

- (void)updateCollectionViewLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = [PNScrollerContainerCellView itemSize];
    
    CGFloat margin = (([UIScreen mainScreen].bounds.size.width/2) - (flowLayout.itemSize.width/2));

    flowLayout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin);
    flowLayout.minimumLineSpacing = 5;
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)addSponsorLabel
{
    UILabel *sponsorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 15)];
    sponsorLabel.font = [UIFont systemFontOfSize:9.0f];
    sponsorLabel.text = kPNAdConstantSponsoredContentString;
    sponsorLabel.textAlignment = NSTextAlignmentCenter;
    sponsorLabel.backgroundColor = [UIColor purpleColor];
    sponsorLabel.textColor = [UIColor whiteColor];
    sponsorLabel.alpha = 0.75f;
    [self addSubview:sponsorLabel];
}

- (void)setCollectionData:(NSArray *)collectionData
{
    _collectionData = collectionData;
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    self.currentIndex = 0;
    [self.collectionView reloadData];
}

- (CGFloat)offsetXForIndex:(NSInteger)index;
{
    CGFloat result = self.collectionView.contentOffset.x;
    if(index >= 0 && index < [self.collectionData count])
    {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
        CGSize itemSize = layout.itemSize;
        result = (index * itemSize.width) + (index * layout.minimumLineSpacing) - layout.sectionInset.left + layout.sectionInset.right;
    }
    return result;
}

+ (CGSize)itemSize
{
    CGSize result = CGSizeZero;
    
    NSString *cellNibName = NSStringFromClass([PNScrollerViewCell class]);
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        cellNibName = [NSString stringWithFormat:@"%@-landscape", cellNibName];
    }
    UINib *cellNib      = [UINib nibWithNibName:cellNibName bundle:nil];
    UIView *cellView    = [[cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    result = cellView.frame.size;
    
    return result;
}

#pragma mark - DELEGATE -

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.collectionData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = NSStringFromClass([PNScrollerViewCell class]);
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        cellID = [NSString stringWithFormat:@"%@-landscape", cellID];
    }
    PNScrollerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    PNNativeAdModel *cellData = [self.collectionData objectAtIndex:[indexPath row]];
    [cell setData:cellData];
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((PNScrollerViewCell*)cell) didEndDisplayingCell];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if([indexPath row] != self.currentIndex)
    {
        CGFloat newOffsetX = [self offsetXForIndex:[indexPath row]];
        [self.collectionView setContentOffset:CGPointMake(newOffsetX, 0) animated:YES];
        self.currentIndex = [indexPath row];
    }
    else
    {
        if([indexPath row] >= 0 && [indexPath row] < [self.collectionData count])
        {
            PNNativeAdModel *cellModel = [self.collectionData objectAtIndex:[indexPath row]];
            if (cellModel && cellModel.click_url)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellModel.click_url]];
            }
        }
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGSize scrollerItemSize = [PNScrollerContainerCellView itemSize];
    
    // Get target index following scroller
    NSInteger targetIndex = lroundf(targetContentOffset->x / scrollerItemSize.width);
    
    // Get target movement calculated (normalizing)
    NSInteger targetMovement = targetIndex - self.currentIndex;
    if(targetMovement != 0)
    {
        targetMovement = (targetMovement / targetMovement) * ((targetMovement < 0) ? -1 : +1);
    }
    
    // Get final target index in array limits (0 - index - data.count)
    targetIndex = self.currentIndex + targetMovement;
    targetIndex = MIN(MAX(targetIndex, 0), [self.collectionData count]);
    
    CGFloat newOffsetX = [self offsetXForIndex:targetIndex];
    targetContentOffset->x = newOffsetX;
    
    self.currentIndex = targetIndex;
}

@end
