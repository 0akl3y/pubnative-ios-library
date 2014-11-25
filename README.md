![ScreenShot](/PubnativeLibrary/Images.xcassets/PNLogo.png)

![](https://ship.io/jobs/8tguNiRCQXeL6_S8/build_status.png)

PubNative is an API-based publisher platform dedicated to native advertising which does not require the integration of an SDK. Through PubNative, publishers can request over 20 parameters to enrich their ads and thereby create any number of combinations for unique and truly native ad units.

# PNLibrary

PNLibrary is a collection of Open Source tools, to implement API based native ads in iOS.

## Requirements and dependencies

* ARC only; iOS 6.1+
* The PNLibrary is using the [YADMLib](https://github.com/cnagy/YADMLib) for networking and JSON to data model mapping.

## Install

### 1) Source files

Copy the PubnativeLibrary/PNLibrary sub-folder into your Xcode project

## Simple implementation

To get native ads from our API you should use the PNAdRequest.h in your controller:

```objective-c
#import "PNAdRequest.h"

@interface MyViewController()

@property (strong, nonatomic) PNAdRequest   *request;
@property (strong, nonatomic) PNAPIModel    *result;

@end

@implementation MyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;

    [[PNAdRequestTargeting sharedInstance] setApp_token:@"YourAppsToken"];

    self.request = [[PNAdRequest alloc] initWithTargeting:[PNAdRequestTargeting sharedInstance]
                                       andCompletionBlock:^(PNAPIModel *result, NSError *error) {
                                          __strong typeof(self) strongSelf = weakSelf;
                                          strongSelf.result = result;

                                          if ([strongSelf.result.status isEqualToString:@"error"])
                                          {
                                              NSLog(@"Error: %@", strongSelf.result.error_message);
                                          }
                                          else
                                          {
                                              NSLog(@"Loaded %lu offers", (unsigned long)[strongSelf.result.ads count]);

                                              for (PNAdModel *ad in strongSelf.result.ads) {
                                                  NSLog(@" - %@", ad.title);
                                              }
                                          }
                                       }];
}

@end
```


## Advanced implementation

### How to get ads with PNAdRequest and the PNAdRequestTargeting class

> **PNAdRequest** public methods:
> - (id)initWithTargeting:(PNAdRequestTargeting*)targeting andCompletionBlock:(PNRequestCompletionBlock)block;
>
> **PNAdRequestTargeting** public methods:
> - (id)initWithToken:(NSString*)token;
>

The `PNAdRequest` is managing the ad request and can get configured through the `PNAdRequestTargeting` class.

Let's start to populate the `PNAdRequestTargeting` singleton:

```objective-c
[[PNAdRequestTargeting sharedInstance] setApp_token:@"YourAppsToken"];
[[PNAdRequestTargeting sharedInstance] setAd_count:@5];
[[PNAdRequestTargeting sharedInstance] setLocale: @"en"];
```

In this case I'm asking for 5 offers localised to English.

Now pass my `PNAdRequestTargeting` singleton to the `PNAdRequest` class:

```objective-c
__weak typeof(self) weakSelf = self;
PNAdRequest *request = [[PNAdRequest alloc] initWithTargeting:[PNAdRequestTargeting sharedInstance]
                                       andCompletionBlock:^(PNAPIModel *result, NSError *error) {
                                           __strong typeof(self) strongSelf = weakSelf;
                                           strongSelf.result = result;
                                           [strongSelf processResult];
                                       }];
```

### Managing ad impressions with the PNImpressionManager

> **[PNImpressionManager sharedInstance]** public methods and properties:

> `- (void)confirmWithAd:(PNAdModel*)ad;`

> `- (void)confirmWithAd:(PNAdModel*)ad andCompletionBlock:(PNImpressionCompletionBlock)block;`

> `- @property (strong, nonatomic) NSMutableArray *confirmedAds;`
>

For a better targeting you should confirm the shown ad. The `PNAdModel` is containing an array of `PNBeaconModel`-s. 
The impression link is sent by the API in a `PNBeaconModel` object and it's type is `impression`.

The `PNImpressionManager` singleton is a helper for managing impressions. It can be triggered also with or without a completion block:

```objective-c
[[PNImpressionManager sharedInstance] confirmWithAd:ad];
```

or

```objective-c
[[PNImpressionManager sharedInstance] confirmWithAd:self.model
                                 andCompletionBlock:^(id result, NSError *error) {
    if (!error)
    {
        NSLog(@"Impression completed");
    }
}];
```

### The PNAdRenderingManager with the PNAdLayout

> **[PNAdRenderingManager sharedInstance]** public methods:

> `- (void)renderAd:(PNAdModel*)ad withAssets:(PNAdLayout*)layout;`
>
> **PNAdLayout** public properties:

> `- @property (strong, nonatomic) UILabel                       *titleLabel;`

> `- @property (strong, nonatomic) UITextView                    *descriptionField;`

> `- @property (strong, nonatomic) UIImageView                   *iconImage;`

> `- @property (strong, nonatomic) UIImageView                   *bannerImage;`

> `- @property (strong, nonatomic) UIButton                      *clickButton;`

> `- @property (strong, nonatomic) UILabel                       *nameField;`

> `- @property (strong, nonatomic) UITextView                    *reviewField;`

> `- @property (strong, nonatomic) UILabel                       *publisherLabel;`

> `- @property (strong, nonatomic) UILabel                       *developerLabel;`

> `- @property (strong, nonatomic) UILabel                       *versionLabel;`

> `- @property (strong, nonatomic) UILabel                       *sizeLabel;`

> `- @property (strong, nonatomic) UILabel                       *categoryLabel;`

> `- @property (strong, nonatomic) UILabel                       *subCategoryLabel;`
>

The `PNAdLayout` is linking the received ad data to your UIView's IBOutlets:

```objective-c
PNAdLayout *layout = [[PNAdLayout alloc] init];
layout.titleLabel = self.titleLabel;
layout.descriptionField = self.descriptionField;
layout.nameField = self.nameLabelField;
layout.reviewField = self.reviewField;
layout.clickButton = self.clickButton;
```

and the `PNAdRenderingManager` by using the populated `PNAdLayout *layout`, rendrers the data to the given fields:

```objective-c
[[PNAdRenderingManager sharedInstance] renderAd:ad
                                     withAssets:layout];
```

## Misc

### License

This code is distributed under the terms and conditions of the MIT license.

### Contribution guidelines

**NB!** If you fix a bug you discovered or have development ideas, feel free to make a pull request.

