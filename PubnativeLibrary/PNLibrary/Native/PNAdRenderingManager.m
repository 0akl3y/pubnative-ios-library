//
// PNAdRenderingManager.m
//
// Created by Csongor Nagy on 20/06/14.
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

#import "PNAdRenderingManager.h"

@implementation PNAdRenderingManager

static PNAdRenderingManager *sharedManager = nil;

#pragma mark - Class Lifecycle

+ (PNAdRenderingManager*)sharedInstance
{
    static PNAdRenderingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PNAdRenderingManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}



#pragma mark - Instance Methods

- (void)renderAd:(PNAdModel*)ad withAssets:(PNAdLayout*)layout
{
    if (ad)
    {
        if (layout.titleLabel)
        {
            [layout.titleLabel performSelector:@selector(setText:) withObject:ad.title];
        }
        if (layout.descriptionField)
        {
            [layout.descriptionField performSelector:@selector(setText:) withObject:ad.Description];
        }
        
        dispatch_queue_t iconDownloadQueue = dispatch_queue_create("iconLoader", NULL);
        dispatch_async(iconDownloadQueue, ^{
            NSData *iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ad.icon_url]];
            dispatch_async(dispatch_get_main_queue(), ^ {
                UIImage *iconImage = [UIImage imageWithData:iconData];
                layout.iconImage.image = iconImage;
            });
        });
        
        dispatch_queue_t bannerDownloadQueue = dispatch_queue_create("bannerLoader", NULL);
        dispatch_async(bannerDownloadQueue, ^{
            NSData *bannerData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ad.banner_url]];
            dispatch_async(dispatch_get_main_queue(), ^ {
                UIImage *bannerImage = [UIImage imageWithData:bannerData];
                layout.bannerImage.image = bannerImage;
            });
        });
        
        if (layout.clickButton)
        {
            [layout.clickButton setTitle:ad.cta_text forState:UIControlStateNormal];
        }
        if (layout.nameField)
        {
            [layout.nameField performSelector:@selector(setText:) withObject:ad.app_details.name];
        }
        if (layout.reviewField)
        {
            [layout.reviewField performSelector:@selector(setText:) withObject:ad.app_details.review];
        }
        if (layout.publisherLabel)
        {
            [layout.publisherLabel performSelector:@selector(setText:) withObject:ad.app_details.publisher];
        }
        if (layout.developerLabel)
        {
            [layout.developerLabel performSelector:@selector(setText:) withObject:ad.app_details.developer];
        }
        if (layout.versionLabel)
        {
            [layout.versionLabel performSelector:@selector(setText:) withObject:ad.app_details.version];
        }
        if (layout.sizeLabel)
        {
            [layout.sizeLabel performSelector:@selector(setText:) withObject:ad.app_details.size];
        }
        if (layout.categoryLabel && !layout.subCategoryLabel)
        {
            [layout.categoryLabel performSelector:@selector(setText:)
                                       withObject:[NSString stringWithFormat:@"%@", ad.app_details.category]];
        }
        else if (layout.categoryLabel && layout.subCategoryLabel)
        {
            [layout.categoryLabel performSelector:@selector(setText:) withObject:ad.app_details.category];
            [layout.subCategoryLabel performSelector:@selector(setText:) withObject:ad.app_details.sub_category];
        }
    }
}

@end
