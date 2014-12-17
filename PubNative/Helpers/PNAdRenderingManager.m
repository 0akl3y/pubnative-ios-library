//
//  PNAdRenderingManager.m
//
//  Created by Csongor Nagy on 04/06/14.
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

#import "PNAdRenderingManager.h"

@interface PNAdRenderingManager ()

@end

@implementation PNAdRenderingManager

#pragma mark PNAdRenderingManager

+ (void)renderNativeAdItem:(PNNativeAdRenderItem*)renderItem withAd:(PNNativeAdModel*)ad
{
    if (ad)
    {
        if (renderItem.title)
        {
            renderItem.title.text = ad.title;
        }
        if (renderItem.descriptionField)
        {
            renderItem.descriptionField.text = ad.Description;
        }
        
        if (renderItem.icon)
        {
            dispatch_queue_t iconDownloadQueue = dispatch_queue_create("iconLoader", NULL);
            dispatch_async(iconDownloadQueue, ^{
                NSData *iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ad.icon_url]];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    UIImage *iconImage = [UIImage imageWithData:iconData];
                    renderItem.icon.image = iconImage;
                });
            });
        }

        if(renderItem.banner)
        {
            dispatch_queue_t bannerDownloadQueue = dispatch_queue_create("bannerLoader", NULL);
            dispatch_async(bannerDownloadQueue, ^{
                NSData *bannerData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ad.banner_url]];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    UIImage *bannerImage = [UIImage imageWithData:bannerData];
                    renderItem.banner.image = bannerImage;
                });
            });
        }
        
        if(renderItem.portrait_banner)
        {
            dispatch_queue_t portraitBannerDownloadQueue = dispatch_queue_create("portraitBannerLoader", NULL);
            dispatch_async(portraitBannerDownloadQueue, ^{
                NSData *portraitBannerData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ad.portrait_banner_url]];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    UIImage *postraitBannerImage = [UIImage imageWithData:portraitBannerData];
                    renderItem.portrait_banner.image = postraitBannerImage;
                });
            });
        }
        
        if (renderItem.cta_text)
        {
            renderItem.cta_text.text = ad.cta_text;
        }
        
        if(ad.app_details && [NSNull null] != (NSNull*)ad.app_details)
        {
            if (renderItem.app_name)
            {
                renderItem.app_name.text = ad.app_details.name;
            }
            if (renderItem.app_review)
            {
                renderItem.app_review.text = ad.app_details.review;
            }
            if (renderItem.app_publisher)
            {
                renderItem.app_publisher.text = ad.app_details.publisher;
            }
            if (renderItem.app_developer)
            {
                renderItem.app_developer.text = ad.app_details.developer;
            }
            if (renderItem.app_version)
            {
                renderItem.app_version.text = ad.app_details.version;                
            }
            if (renderItem.app_size)
            {
                renderItem.app_size.text = ad.app_details.size;
            }
            if (renderItem.app_category)
            {
                renderItem.app_category.text = ad.app_details.category;
            }
            if (renderItem.app_sub_category)
            {
                renderItem.app_sub_category.text = ad.app_details.sub_category;
            }
        }
    }
}

@end
