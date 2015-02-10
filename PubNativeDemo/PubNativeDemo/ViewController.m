//
// ViewController.m
//
// Created by Csongor Nagy on 11/11/14.
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

#import "ViewController.h"
#import "Pubnative.h"
#import "FeedViewController.h"
#import "SettingsViewController.h"
#import "AdViewController.h"
#import "EFApiModel.h"

NSString * const kPubnativeTestAppToken = @"e1a8e9fcf8aaeff31d1ddaee1f60810957f4c297859216dea9fa283043f8680f";

@interface ViewController ()<PubnativeAdDelegate, SettingsViewControllerDelegate>

@property (weak, nonatomic)     IBOutlet    UIActivityIndicatorView *adLoadingIndicator;
@property (strong, nonatomic)   IBOutlet    UIScrollView            *optionsScrollView;
@property (strong, nonatomic)               PNAdRequestParameters   *parameters;
@property (assign, nonatomic)               Pubnative_AdType        currentType;

@property (strong, nonatomic) EFApiModel                        *eventModel;

@property (nonatomic, strong) UIViewController  *currentAdVC;

- (IBAction)settingsPressed:(id)sender;

@end

@implementation ViewController

#pragma mark NSObject

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.optionsScrollView.contentSize = CGSizeMake(300, 344);
    
    self.parameters = [PNAdRequestParameters requestParameters];
    [self.parameters fillWithDefaults];
    self.parameters.app_token = kPubnativeTestAppToken;
    
    __weak typeof(self) weakSelf = self;
    self.eventModel = [[EFApiModel alloc] initWithURL:[NSURL URLWithString:@"http://api.eventful.com/json/events/search"]
                                               method:@"GET"
                                               params:@{@"app_key"     : @"pd5PdshD44wckpD7",
                                                        @"location"    : @"Berlin",
                                                        @"date"        : @"Today",
                                                        @"categories"  : @"music",
                                                        @"image_sizes" : @"block100,large",
                                                        @"page_size"   : @"100"}
                                              headers:nil
                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                              timeout:30
                                   andCompletionBlock:^(NSError *error) {
                                        __strong typeof(self) strongSelf = weakSelf;
                                        [strongSelf processEventsWithError:error];
                                   }];
}

- (void)processEventsWithError:(NSError*)error
{
    NSLog(@"%@", [error localizedDescription]);
    NSLog(@"%@", self.eventModel.events);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.currentAdVC.view removeFromSuperview];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Action Methods

- (IBAction)settingsPressed:(id)sender
{
    SettingsViewController *settings = [[SettingsViewController alloc] initWitParams:self.parameters
                                                                         andDelegate:self];
    [self presentViewController:settings animated:YES completion:nil];
}

- (IBAction)bannerTouchUpInside:(id)sender
{
    [self startLoading];
    self.currentType = Pubnative_AdType_Banner;
    
    [Pubnative requestAdType:Pubnative_AdType_Banner
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)interstitialTouchUpInside:(id)sender
{
    [self startLoading];
    self.currentType = Pubnative_AdType_Interstitial;
    
    [Pubnative requestAdType:Pubnative_AdType_Interstitial
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)iconTouchUpInside:(id)sender
{
    [self startLoading];
    self.currentType = Pubnative_AdType_Icon;
    
    [Pubnative requestAdType:Pubnative_AdType_Icon
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)videoTouchUpInside:(id)sender
{
    [self startLoading];
    self.currentType = Pubnative_AdType_VideoBanner;
    
    [Pubnative requestAdType:Pubnative_AdType_VideoBanner
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)videoFeedTouchUpInside:(id)sender
{
    [self startLoading];
    self.currentType = -1;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *feedVC = [storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    [self presentViewController:feedVC animated:YES completion:^{
        [self stopLoading];
        [feedVC loadAdWithParameters:self.parameters
                         requestType:PNAdRequest_Native_Video
                         andFeedType:PNFeed_Native_Video];
    }];
}

- (IBAction)adFeedTouchUpInside:(id)sender
{
    [self startLoading];
    self.currentType = -1;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *feedVC = [storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    [self presentViewController:feedVC animated:YES completion:^{
        [self stopLoading];
        [feedVC loadAdWithParameters:self.parameters
                         requestType:PNAdRequest_Native
                         andFeedType:PNFeed_Native_Ad];
    }];
}

- (IBAction)scrollFeedTouchUpInside:(id)sender
{
    [self startLoading];
    self.currentType = -1;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *feedVC = [storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    [self presentViewController:feedVC animated:YES completion:^{
        [self stopLoading];
        [feedVC loadAdWithParameters:self.parameters
                         requestType:PNAdRequest_Native
                         andFeedType:PNFeed_Native_Scroller];
    }];
}

- (void)startLoading
{
    [self.adLoadingIndicator startAnimating];
}

- (void)stopLoading
{
    [self.adLoadingIndicator stopAnimating];
}

#pragma mark - PubnativeAdDelegate Methods

- (void)pnAdDidLoad:(UIViewController *)adVC
{
    [self stopLoading];
    switch (self.currentType)
    {
        case Pubnative_AdType_Interstitial:
        {
            [self presentViewController:adVC animated:YES completion:nil];
        }
        break;
        
        case Pubnative_AdType_Banner:
        case Pubnative_AdType_Icon:
        case Pubnative_AdType_VideoBanner:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AdViewController *adContainerVC = [storyboard instantiateViewControllerWithIdentifier:@"AdViewController"];
            [self presentViewController:adContainerVC
                               animated:YES
                             completion:^{
                                 [adContainerVC presentAdWithViewController:adVC type:self.currentType];
                             }];
        }
        break;
            
        default:
        break;
    }
}

- (void)pnAdDidClose
{
}

- (void)pnAdDidFail:(NSError *)error
{
    [self stopLoading];
    
    NSLog(@"Error loading ad - %@", [error description]);
}

#pragma mark - SettingsViewControllerDelegate Methods

- (void)willCloseWithParams:(PNAdRequestParameters*)parameters
{
    self.parameters = parameters;
}

@end
