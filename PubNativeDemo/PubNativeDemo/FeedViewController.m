//
//  FeedViewController.m
//  PubNativeDemo
//
//  Created by David Martin on 08/01/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "FeedViewController.h"
#import "PNTableViewManager.h"

NSString * const videoCellID    = @"videoCellID";
NSString * const wallCellID     = @"wallCellID";
NSString * const textCellID     = @"textCellID";

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView      *tableView;
@property (strong, nonatomic) PNNativeAdModel           *model;
@property (strong, nonatomic) NSMutableArray            *ads;
@property (strong, nonatomic) PNAdRequest               *request;
@property (assign, nonatomic) PNFeedType                type;
@property (weak, nonatomic) IBOutlet UINavigationItem   *navItem;

@end

@implementation FeedViewController

#pragma mark NSObject

- (void)dealloc
{
    self.model = nil;
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
    
    if (self.type == PNFeed_Native_Ad)
    {
        parameters.ad_count = @10;
        self.navItem.title = @"AdFeed";
    }
    else if (self.type == PNFeed_Native_Video)
    {
        parameters.ad_count = @1;
        self.navItem.title = @"VideoFeed";
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
    if(self.model)
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
        else if (self.type == PNFeed_Native_Ad)
        {
            result = [tableView dequeueReusableCellWithIdentifier:wallCellID];
            if(!result)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PNAdWallCell" owner:self options:nil];
                result = [topLevelObjects objectAtIndex:0];
            }

            if ((indexPath.row-5)/10 < self.ads.count)
            {
                PNNativeAdModel *model = [self.ads objectAtIndex:(indexPath.row-5)/10];
                [(PNAdWallCell*)result setModel:model];
            }
            else
            {
                PNNativeAdModel *model = [self.ads objectAtIndex:(indexPath.row-5)/10-self.ads.count];
                [(PNAdWallCell*)result setModel:model];
            }
        }
    }
    else
    {
        result = [tableView dequeueReusableCellWithIdentifier:textCellID];
        if(!result)
        {
            result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellID];
        }
        result.textLabel.text = [NSString stringWithFormat:@"Item %ld", (long)indexPath.row];
    }
    return result;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = tableView.rowHeight;
    if(self.model &&
       [self isAdCell:indexPath])
    {
        if (self.type == PNFeed_Native_Video)
        {
            result = 150;
        }
        else if (self.type == PNFeed_Native_Ad)
        {
            result = 60;
        }
    }
    return result;
}

@end
