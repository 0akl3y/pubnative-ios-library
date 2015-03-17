//
//  PNGameListTableViewCell.m
//  PubNativeDemo
//
//  Created by David Martin on 16/03/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "PNGameListTableViewCell.h"
#import "PNAdRenderingManager.h"
#import "AMRatingControl.h"
#import "PNAdConstants.h"
#import "PNTrackingManager.h"

@interface PNGameListTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView    *icon;
@property (weak, nonatomic) IBOutlet UILabel        *title;
@property (weak, nonatomic) IBOutlet UILabel        *cta_text;
@property (weak, nonatomic) IBOutlet UIView         *ratingContainer;
@property (weak, nonatomic) IBOutlet UILabel        *totalRatings;
@property (weak, nonatomic) IBOutlet UIView         *darkBG;

@property (weak, nonatomic)     PNNativeAdModel     *model;
@property (strong, nonatomic)   AMRatingControl     *ratingControl;
@property (strong, nonatomic)   NSTimer             *impressionTimer;

@end

@implementation PNGameListTableViewCell

#pragma mark NSObject

- (void)dealloc
{
    [self.ratingControl removeFromSuperview];
    self.ratingControl = nil;
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    self.model = nil;
    self.delegate = nil;
}

#pragma mark UITableViewCell

- (void)awakeFromNib
{
    self.cta_text.layer.cornerRadius = 5;
    
    // Rating stars
    self.ratingControl = [[AMRatingControl alloc] initWithLocation:CGPointZero
                                                        emptyColor:[UIColor lightGrayColor]
                                                        solidColor:[PNAdConstants pubnativeColor]
                                                      andMaxRating:(NSInteger)5];
    self.ratingControl.rating = 0;
    [self.ratingControl setUserInteractionEnabled:NO];
    [self.ratingContainer addSubview:self.ratingControl];
}

#pragma mark PNGameListTableViewCell

- (void)didDisplay
{
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

- (void)willDisplay
{
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    self.impressionTimer = [NSTimer scheduledTimerWithTimeInterval:kPNAdConstantShowTimeForImpression
                                                            target:self
                                                          selector:@selector(impressionTimerTick:)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)impressionTimerTick:(NSTimer *)timer
{
    if(self.model)
    {
        [PNTrackingManager trackImpressionWithAd:self.model completion:nil];
    }
}

- (void)setModel:(PNNativeAdModel*)model
{
    _model = model;
    
    if(self.model)
    {
        NSInteger rating = 0;
        if([NSNull null] != ((NSNull*)self.model.app_details) &&
           self.model.app_details.store_rating &&
           [NSNull null] != ((NSNull*)self.model.app_details.store_rating))
        {
            rating =  (int) [self.model.app_details.store_rating doubleValue];
        }
        
        NSString *totalRatings = @"";
        if ((NSNull*)self.model.app_details.total_ratings != [NSNull null])
        {
            totalRatings = [NSString stringWithFormat:@"(%@)", self.model.app_details.total_ratings];
        }
        self.totalRatings.text = totalRatings;
        self.ratingControl.rating = rating;
        
        PNNativeAdRenderItem *item = [PNNativeAdRenderItem renderItem];
        item.title = self.title;
        item.icon = self.icon;
        item.cta_text = self.cta_text;
        
        [PNAdRenderingManager renderNativeAdItem:item withAd:self.model];
    }
}

- (void)setDark:(BOOL)set
{
    self.darkBG.hidden = !set;
}

- (IBAction)touchUpInside:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnGameListCellSelected)])
    {
        [self.delegate pnGameListCellSelected];
    }
    
    if (self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

@end
