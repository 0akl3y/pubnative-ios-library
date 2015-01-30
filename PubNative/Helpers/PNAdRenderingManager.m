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

NSString *kPNAdRenderingManagerIconNotification = @"kPNAdRenderingManagerIconNotification";
NSString *kPNAdRenderingManagerBannerNotification = @"kPNAdRenderingManagerBannerNotification";
NSString *kPNAdRenderingManagerPortraitBannerNotification = @"kPNAdRenderingManagerPortraitBannerNotification";

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
            renderItem.icon.alpha = 0;
            [PNCacheManager dataWithURLString:ad.icon_url
                                andCompletion:^(NSData *data) {
                                    
                                    UIImage *iconImage = [UIImage imageWithData:data];
                                    
                                    dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        [renderItem.icon setImage:iconImage];
                                        [UIView animateWithDuration:0.3f
                                                         animations:^{
                                                             renderItem.icon.alpha = 1;
                                                         }];
                                    
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kPNAdRenderingManagerIconNotification object:renderItem.icon];
                                    });
                                }];
        }

        if(renderItem.banner)
        {
            renderItem.banner.alpha = 0;
            [PNCacheManager dataWithURLString:ad.banner_url
                                andCompletion:^(NSData *data) {
                                    UIImage *portraitBannerImage = [UIImage imageWithData:data];
                                    
                                    dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        [renderItem.banner setImage:portraitBannerImage];
                                    
                                        [UIView animateWithDuration:0.3f
                                                         animations:^{
                                                             renderItem.banner.alpha = 1;
                                                         }];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kPNAdRenderingManagerBannerNotification object:renderItem.banner];
                                    });
                                }];
        }
        
        if(renderItem.portrait_banner)
        {
            renderItem.portrait_banner.alpha = 0;
            [PNCacheManager dataWithURLString:ad.portrait_banner_url
                                andCompletion:^(NSData *data) {
                                    UIImage *portraitBannerImage = [UIImage imageWithData:data];
                                    
                                    dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        [renderItem.portrait_banner setImage:portraitBannerImage];
                                    
                                        [UIView animateWithDuration:0.3f
                                                         animations:^{
                                                             renderItem.portrait_banner.alpha = 1;
                                                         }];
                                    
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kPNAdRenderingManagerPortraitBannerNotification object:renderItem.portrait_banner];
                                    });
                                }];
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
