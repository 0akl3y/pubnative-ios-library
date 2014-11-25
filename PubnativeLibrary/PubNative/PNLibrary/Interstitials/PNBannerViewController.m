//
// PNBannerViewController.m
//
// Created by Csongor Nagy on 12/11/14.
// Copyright (c) 2014 PubNative
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

#import "PNBannerViewController.h"

@interface PNBannerViewController ()

@property (nonatomic,strong) PNAdRequest    *request;
@property (nonatomic,strong) NSMutableArray *ads;
@property (nonatomic, strong) PNAdModel     *model;

@end

@implementation PNBannerViewController

#pragma mark - View Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                          frame:(CGRect)frame
                       delegate:(NSObject<PNLibraryDelegate>*)delegate
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self)
    {
        self.delegate = delegate;
        self.view.frame = frame;
        self.iconView.layer.cornerRadius = 5.0f;
        [self.iconView setClipsToBounds:YES];
        self.dataContainer.layer.borderColor = [UIColor orangeColor].CGColor;
        self.dataContainer.layer.borderWidth = 1.0f;
        self.dataContainer.layer.cornerRadius = 5.0f;
        self.installButton.layer.cornerRadius = 5.0f;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ratingControl = [[AMRatingControl alloc]
                          initWithLocation:CGPointZero
                          emptyColor:[UIColor lightGrayColor]
                          solidColor:[UIColor orangeColor]
                          andMaxRating:(NSInteger)5];
    [self.ratingControl setUserInteractionEnabled:NO];
    [self.ratingContainer addSubview:self.ratingControl];
    
    [self loadAd];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidShow)])
    {
        [self.delegate performSelector:@selector(pnAdDidShow)];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidClose)])
    {
        [self.delegate performSelector:@selector(pnAdDidClose)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark - Action Methods

- (IBAction)installButtonPressed:(id)sender
{
    if (self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}



#pragma mark - Private Methods

- (void)loadAd
{
    __weak typeof(self) weakSelf = self;
    
    [[PNAdRequestTargeting sharedInstance] setAd_count:@1];
    self.request = [[PNAdRequest alloc] initWithTargeting:[PNAdRequestTargeting sharedInstance]
                                          completionBlock:^(NSMutableArray *ads, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              strongSelf.ads = ads;
                                              
                                              
                                              if (!error)
                                              {
                                                  [strongSelf renderAd];
                                                  if ([self.delegate respondsToSelector:@selector(pnAdReady:)])
                                                  {
                                                      [self.delegate performSelector:@selector(pnAdReady:) withObject:self];
                                                  }
                                              }
                                              else
                                              {
                                                  if ([strongSelf.delegate respondsToSelector:@selector(pnAdDidFailWithError:)])
                                                  {
                                                      [strongSelf.delegate pnAdDidFailWithError:error];
                                                  }
                                              }
                                          }];
}

- (void)renderAd
{
    self.model = [self.ads firstObject];
    
    if (self.model)
    {
        [[PNImpressionManager sharedInstance] confirmWithAd:self.model];
        
        PNAdLayout *layout = [[PNAdLayout alloc] init];
        layout.titleLabel = self.titleLabel;
        layout.iconImage = self.iconView;
        layout.clickButton = self.installButton;
        
        [[PNAdRenderingManager sharedInstance] renderAd:self.model withAssets:layout];
        
        if ((NSNull*)self.model.app_details.store_rating != [NSNull null])
        {
            [self.ratingControl setRating:[self.model.app_details.store_rating intValue]];
        }
        
        self.dataContainer.hidden = NO;
    }
}

@end
