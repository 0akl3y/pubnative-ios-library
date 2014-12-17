//
//  Pubnative.m
//
//  Created by David Martin on 12/12/14.
//  Copyright (c) 2014 PubNative
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "Pubnative.h"
#import "PNAdRequest.h"

@interface Pubnative ()

@property (nonatomic, strong) PNAdRequest *currentRequest;

+ (instancetype)sharedInstance;

@end

@implementation Pubnative

#pragma mark - NSObject

- (void)dealloc
{
    self.currentRequest = nil;
}

#pragma mark - Pubnative

#pragma mark public

+ (void)requestAdType:(Pubnative_AdType)type
         withAppToken:(NSString *)appToken
          andDelegate:(NSObject<PubnativeAdDelegate>*)delegate
{
    PNAdRequestType requestType = PNAdRequest_Native;
    
    PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
    parameters.app_token = appToken;
    switch (type)
    {
        case Pubnative_AdType_VideoBanner:
        {
            requestType = PNAdRequest_Native_Video;
            parameters.banner_size = @"1200x627";
        }
        break;
        case Pubnative_AdType_Banner:
        {
            parameters.icon_size = @"50x50";
        }
        break;
        case Pubnative_AdType_Interstitial:
        {
        }
        break;
        case Pubnative_AdType_Icon:
        {
            parameters.icon_size = @"400x400";
        }
        break;
    }
    
    __block Pubnative_AdType adType = type;
    __weak NSObject<PubnativeAdDelegate> *weakDelegate = delegate;
    [Pubnative sharedInstance].currentRequest = [PNAdRequest request:requestType
                                                      withParameters:parameters
                                                       andCompletion:^(NSArray *ads, NSError *error)
    {
        if(error)
        {
            if(weakDelegate && [weakDelegate respondsToSelector:@selector(pnAdDidFail:)])
            {
                [weakDelegate pnAdDidFail:error];
            }
        }
        else
        {
            PNNativeAdModel *adModel = [ads firstObject];
            UIViewController *adVC = [Pubnative createType:adType withAd:adModel];
            if(weakDelegate && [weakDelegate respondsToSelector:@selector(pnAdDidLoad:)])
            {
                [weakDelegate pnAdDidLoad:adVC];
            }
        }
    }];
    
    [[Pubnative sharedInstance].currentRequest startRequest];
}

#pragma mark private

+ (instancetype)sharedInstance
{
    static Pubnative *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Pubnative alloc] init];
    });
    return _sharedInstance;
}

+ (UIViewController*)createType:(Pubnative_AdType)type withAd:(PNNativeAdModel*)ad
{
    UIViewController *result = nil;
    switch (type)
    {
        case Pubnative_AdType_Banner:       result = [Pubnative createAdTypeBannerWithAd:ad];       break;
        case Pubnative_AdType_VideoBanner:  result = [Pubnative createAdTypeVideoBannerWithAd:ad];  break;
        case Pubnative_AdType_Interstitial: result = [Pubnative createAdTypeInterstitialWithAd:ad]; break;
        case Pubnative_AdType_Icon:         result = [Pubnative createAdTypeIconWithAd:ad];         break;
    }
    return result;
}

+ (UIViewController*)createAdTypeBannerWithAd:(PNNativeAdModel*)ad
{
    PNBannerViewController *result = [[PNBannerViewController alloc] initWithNibName:NSStringFromClass([PNBannerViewController class])
                                                                              bundle:nil
                                                                               model:ad];
    return result;
}

+ (UIViewController*)createAdTypeVideoBannerWithAd:(PNNativeAdModel*)ad
{
    PNVideoBannerViewController *result = [[PNVideoBannerViewController alloc] initWithNibName:NSStringFromClass([PNVideoBannerViewController class])
                                                                                        bundle:nil
                                                                                         model:ad];
    return result;
}

+ (UIViewController*)createAdTypeInterstitialWithAd:(PNNativeAdModel*)ad
{
    PNInterstitialAdViewController *result = [[PNInterstitialAdViewController alloc] initWithNibName:NSStringFromClass([PNInterstitialAdViewController class])
                                                                                              bundle:nil
                                                                                               model:ad];
    return result;
}

+ (UIViewController*)createAdTypeIconWithAd:(PNNativeAdModel*)ad
{
    PNIconViewController *result = [[PNIconViewController alloc] initWithNibName:NSStringFromClass([PNIconViewController class])
                                                                          bundle:nil
                                                                           model:ad];
    return result;
}

@end
