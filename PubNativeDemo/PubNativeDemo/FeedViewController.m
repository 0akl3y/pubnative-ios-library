//
//  FeedViewController.m
//  PubNativeDemo
//
//  Created by David Martin on 08/01/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "FeedViewController.h"
#import "PNAdRequest.h"
#import "PNTableViewManager.h"

NSString * const videoCellID    = @"videoCellID";
NSString * const textCellID     = @"textCellID";

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView  *tableView;
@property (strong, nonatomic) PNNativeAdModel       *model;
@property (strong, nonatomic) PNAdRequest           *request;

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

- (void)loadAdWithAppToken:(NSString *)appToken
{
    PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
    parameters.app_token = appToken;
    
    __weak typeof(self) weakSelf = self;
    self.request = [PNAdRequest request:PNAdRequest_Native_Video
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
    if(indexPath.row % 15 == 5)
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
        PNVideoTableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellID];
        if (!videoCell)
        {
            videoCell = [[PNVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellID];
        }
        videoCell.model = (PNNativeVideoAdModel*)self.model;
        result = videoCell;
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
        result = 150;
    }
    return result;
}

@end
