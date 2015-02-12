//
// FeedViewController.m
//
// Created by David Martin on 08/01/15.
// Copyright (c) 2015 PubNative. All rights reserved.
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

#import "FeedViewController.h"
#import "PNTableViewManager.h"
#import "PNIconTableViewCell.h"

NSString * const videoCellID    = @"videoCellID";
NSString * const bannerCellID   = @"bannerCellID";
NSString * const carouselCellID = @"carouselCellID";
NSString * const textCellID     = @"textCellID";
NSString * const iconCellID     = @"iconCellID";

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView      *tableView;
@property (strong, nonatomic) PNNativeAdModel           *model;
@property (strong, nonatomic) NSMutableArray            *ads;
@property (strong, nonatomic) PNAdRequest               *request;
@property (assign, nonatomic) PNFeedType                type;
@property (weak, nonatomic) IBOutlet UINavigationItem   *navItem;
@property (strong, nonatomic) EFApiModel                *eventModel;

@end

@implementation FeedViewController

#pragma mark NSObject

- (void)dealloc
{
    self.model = nil;
    self.eventModel = nil;
}

#pragma UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [PNTableViewManager controlTable:self.tableView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [PNTableViewManager controlTable:nil];
}

#pragma mark FeedViewController

- (void)loadAdWithParameters:(PNAdRequestParameters*)parameters
                 requestType:(PNAdRequestType)reuqestType
                 andFeedType:(PNFeedType)feedType
{
    self.type = feedType;
    
    if (self.type == PNFeed_Native_Banner)
    {
        parameters.ad_count = @10;
        self.navItem.title = @"Banner";
    }
    else if (self.type == PNFeed_Native_Video)
    {
        parameters.ad_count = @1;
        self.navItem.title = @"Video";
    }
    else if (self.type == PNFeed_Native_Carousel)
    {
        parameters.ad_count = @3;
        self.navItem.title = @"Carousel";
    }
    else if (self.type == PNFeed_Native_Icon)
    {
        parameters.ad_count = @5;
        parameters.icon_size = @"400x400";
        self.navItem.title = @"Icon";
    }
    
    __weak typeof(self) weakSelf = self;
    self.request = [PNAdRequest request:reuqestType
                         withParameters:parameters
                          andCompletion:^(NSArray *ads, NSError *error)
    {
        if(error)
        {
            NSLog(@"Pubnative - Request error: %@", error);
        }
        else
        {
            NSLog(@"Pubnative - Request end");
            weakSelf.ads = [[NSMutableArray alloc] initWithArray:ads];
            weakSelf.model = [ads firstObject];
            [self.tableView reloadData];
        }
    }];
    [self.request startRequest];
}

- (void)loadAdWithParameters:(PNAdRequestParameters*)parameters
                 requestType:(PNAdRequestType)reuqestType
                    feedData:(EFApiModel*)data
                 andFeedType:(PNFeedType)feedType
{
    self.eventModel = data;
    [self loadAdWithParameters:parameters requestType:reuqestType andFeedType:feedType];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isAdCell:(NSIndexPath*)indexPath
{
    BOOL result = NO;
    if(indexPath.row % 10 == 5)
    {
        result = YES;
    }
    return result;
}

#pragma mark - DELEGATES -

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSInteger result = 4;
    if(self.model && self.eventModel)
    {
        result = [self.eventModel.events.event count];
    }
    else if (self.model)
    {
        result = 100;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *result = nil;
    if (self.model &&
        [self isAdCell:indexPath])
    {
        if (self.type == PNFeed_Native_Video)
        {
            PNVideoTableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellID];
            if (!videoCell)
            {
                videoCell = [[PNVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellID];
            }
            videoCell.model = (PNNativeVideoAdModel*)self.model;
            result = videoCell;
        }
        else if (self.type == PNFeed_Native_Banner)
        {
            result = [tableView dequeueReusableCellWithIdentifier:bannerCellID];
            if(!result)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PNBannerTableViewCell" owner:self options:nil];
                result = [topLevelObjects objectAtIndex:0];
            }

            if ((indexPath.row-5)/10 < self.ads.count)
            {
                PNNativeAdModel *model = [self.ads objectAtIndex:(indexPath.row-5)/10];
                [(PNBannerTableViewCell*)result setModel:model];
            }
            else
            {
                PNNativeAdModel *model = [self.ads objectAtIndex:(indexPath.row-5)/10-self.ads.count];
                [(PNBannerTableViewCell*)result setModel:model];
            }
        }
        else if (self.type == PNFeed_Native_Carousel)
        {
            result = [tableView dequeueReusableCellWithIdentifier:carouselCellID];
            if (!result)
            {
                result = [[PNCarouselTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellID];
            }
            [(PNCarouselTableViewCell*)result setCollectionData:self.ads];
        }
        else if (self.type == PNFeed_Native_Icon)
        {
            PNIconTableViewCell *iconCell = [tableView dequeueReusableCellWithIdentifier:iconCellID];
            if (!iconCell)
            {
                iconCell = [[PNIconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iconCellID];
            }
            
            PNNativeAdModel *model = [self.ads objectAtIndex:((indexPath.row-5)/10)%[self.ads count]];
            iconCell.model = model;
            result = iconCell;
        }
    }
    else
    {
        result = [tableView dequeueReusableCellWithIdentifier:textCellID];
        if(!result)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:self options:nil];
            result = [topLevelObjects objectAtIndex:0];
        }
        
        if(self.model && self.eventModel)
        {
            EFEventModel *e = [self.eventModel.events.event objectAtIndex:indexPath.row];
            [(EventTableViewCell*)result setModel:e];
        }
    }
    return result;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = 150;
    if(self.model &&
       [self isAdCell:indexPath])
    {
        if (self.type == PNFeed_Native_Video)
        {
            result = 150;
        }
        else if (self.type == PNFeed_Native_Banner)
        {
            result = 60;
        }
        else if (self.type == PNFeed_Native_Carousel)
        {
            CGSize scrollerItemSize = [PNCarouselTableViewCell itemSize];
            return scrollerItemSize.height;
        }
    }
    return result;
}

@end
