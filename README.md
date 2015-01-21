![PNLogo](PNLogo.png)

[![Build Status](https://travis-ci.org/pubnative/pubnative-ios-library.svg?branch=master)](https://travis-ci.org/pubnative/pubnative-ios-library)[![Coverage Status](https://coveralls.io/repos/pubnative/pubnative-ios-library/badge.svg?branch=master)](https://coveralls.io/r/pubnative/pubnative-ios-library?branch=master)

PubNative is an API-based publisher platform dedicated to native advertising which does not require the integration of an SDK. Through PubNative, publishers can request over 20 parameters to enrich their ads and thereby create any number of combinations for unique and truly native ad units.

# pubnative-ios-library

pubnative-ios-library is a collection of Open Source tools to implement API based native ads in iOS.

## Requirements

* ARC only; iOS 6.1+
* An App Token provided in pubnative dashboard

## Dependencies

* This library is using the [YADMLib](https://github.com/cnagy/YADMLib) for networking and JSON to data model mapping.


## Install

1. Download this repository
2. Copy the PubNative folder into your Xcode project

## Simple usage

1. Implement `PubnativeAdDelegate`.
2. Request an ad using `Pubnative` class
3. Wait for the callback with `PubnativeAdDelegate`. 

There are 3 types of predefined ads, please see the demo to have more info on how to operate with each. 

Here there is a sample for each one.

### 1) Interstitial

```objective-c
#import "Pubnative.h"
//==================================================================

@interface MyClass : UIViewController<PubnativeAdDelegate>

@property (nonatomic, strong)PNInterstitialViewController *interstitialVC;

#pragma mark Pubnative

- (void)showInterstitial
{
    [Pubnative requestAdType:Pubnative_AdType_Interstitial
                withAppToken:@"YOUR_APP_TOKEN_HERE"
                 andDelegate:self];
}

- (void)pnAdDidLoad:(UIViewController*)ad
{
    // Hold an instance of the VC so it doesn't get released
    self.interstitialVC = ad;
    
    // Present the interstitial or add it as a subview
    [self.view addSubView:self.interstitialVC.view];
}

- (void)pnAdDidFail:(NSError*)error {}
- (void)pnAdWillShow{}
- (void)pnAdDidShow{}
- (void)pnAdWillClose{}
- (void)pnAdDidClose
{
    // Release it when it closes or whenever you want
    self.interstitialVC = nil;
}

@end

//==================================================================
```

### 2) Banner

```objective-c
#import "Pubnative.h"
//==================================================================

@interface MyClass : UIViewController<PubnativeAdDelegate>

@property (nonatomic, strong)PNBannerViewController *bannerVC;

#pragma mark Pubnative

- (void)showBanner
{
    [Pubnative requestAdType:Pubnative_AdType_Banner
                withAppToken:@"YOUR_APP_TOKEN_HERE"
                 andDelegate:self];
}

- (void)pnAdDidLoad:(UIViewController*)ad
{
    // Hold an instance of the VC so it doesn't get released
    self.bannerVC = ad;
    
    // Put the banner whenever you want assiging a frame
    self.bannerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    
    // Add the banner
    [self.view addSubview:self.bannerVC.view];
}

- (void)pnAdDidFail:(NSError*)error {}
- (void)pnAdWillShow{}
- (void)pnAdDidShow{}
- (void)pnAdWillClose{}
- (void)pnAdDidClose{}

@end

//==================================================================
```

### 3)Video banner

```objective-c
#import "Pubnative.h"
//==================================================================

@interface MyClass : UIViewController<PubnativeAdDelegate>

@property (nonatomic, strong)PNVideoBannerViewController *videoBannerVC;

#pragma mark Pubnative

- (void)showBanner
{
    [Pubnative requestAdType:Pubnative_AdType_VideoBanner
                withAppToken:@"YOUR_APP_TOKEN_HERE"
                 andDelegate:self];
}

- (void)pnAdDidLoad:(UIViewController*)ad
{
    // Hold an instance of the VC so it doesn't get released
    self.videoBannerVC = ad;
    
    // Put the banner whenever you want assiging a frame
    self.videoBannerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    
    // Add the banner
    [self.view addSubview:self.videoBannerVC.view];
}

- (void)pnAdDidFail:(NSError*)error {}
- (void)pnAdWillShow{}
- (void)pnAdDidShow{}
- (void)pnAdWillClose{}
- (void)pnAdDidClose{}

@end

//==================================================================
```

## Advanced usage

1. **Request**: Using `PNAdRequest` and `PNAdRequestParameters`
2. **Show**: Manually, or using `PNAdRenderingManager` and `PNNativeAdRenderItem`
3. **Confirm impression**: By using `PNTrackingManager`

### 1) Request 

To start getting native ads from our API, you should import `PNAdRequest.h`.

You will need to create a PNAdRequestParameters for configuration and (like setting up your App token) and request the type of ad you need.

You just need to control that the returned type in the array of ads is different depending on the request type:

* `PNAdRequest_Native`: returns `PNNativeAdModel`
* `PNAdRequest_Native_Video`: returns `PNNativeVideoAdModel`
* `PNAdRequest_Image`: returns `PNImageAdModel`

```objective-c
#import "PNAdRequest.h"
//==================================================================
// Create a new request parameters and set it up configuring at least your app token
PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
parameters.app_token = @"YOUR_APP_TOKEN_HERE";
parameters.icon_size = @"400x400"; 

// Create the request and start it
__weak typeof(self) weakSelf = self;
self.request = [PNAdRequest request:PNAdRequest_Native
                    withParameters:parameters
                     andCompletion:^(NSArray *ads, NSError *error)
{
   if(error)
   {
       NSLog(@"Pubnative - error requesting ads: %@", [error description]);
   }
   else
   {
       NSLog(@"Pubnative - loaded PNNativeAdModel ads: %d", [ads count]);
   }
}];
[self.request startRequest];
//==================================================================
```

### 2) Show

Once the ads are downloaded, you can use them manually by accessing properties inside the model. We developed a tool that will work for most cases `PNAdRenderingManager` and `PNNativeAdRenderItem`.

Simply create and stick a `PNNativeAdRenderItem` to your custom view and make the `PNAdRenderingManager` fill it with the ad (saving you time for image download, field availability check, etc).

The following example shows you how to fill icon, title and cta_text:

```objective-c
#import "PNAdRenderingManager.h"
//==================================================================
PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
renderItem.icon = self.iconView;
renderItem.title = self.titleLabel;
renderItem.cta_text = self.ctaLaxbel;

[PNAdRenderingManager renderNativeAdItem:renderItem withAd:self.ad];
//==================================================================
```

### 3) Confirm impressions

We developed an utility to make you confirm impressions easier and safer, just send the ad you want to confirm to `PNTrackingManager` and it will confirmed.

Common standard is to call this only when your ad remains at least half of the view that holds your ad remains 1 second in the screen.

```objective-c
#import "PNTrackingManager.h"
//==================================================================
[PNTrackingManager trackImpressionWithAd:self.ad
                              completion:^(id result, NSError *error)
{
    // Do whatever you want once the ad is confirmed
}];
//==================================================================
```

## Misc

### License

This code is distributed under the terms and conditions of the MIT license.

### Contribution guidelines

**NB!** If you fix a bug you discovered or have development ideas, feel free to make a pull request.

