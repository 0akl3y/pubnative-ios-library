//
//  WKPNNativeAdModel.m
//
//  Created by David Martin on 23/03/2015
//  Copyright (c) 2015 PubNative
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

#import "WKPNNativeAdModel.h"

@implementation WKPNNativeAdModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        self.click_url = dictionary[@"click_url"];
        NSData *iconData = dictionary[@"icon"];
        if(iconData &&
           [NSNull null] != ((NSNull*)iconData))
        {
            self.icon = [UIImage imageWithData:iconData];
        }
        NSData *bannerData = dictionary[@"banner"];
        if(bannerData &&
           [NSNull null] != ((NSNull*)bannerData))
        {
            self.banner = [UIImage imageWithData:bannerData];
        }
        self.title = dictionary[@"title"];
        self.cta_text = dictionary[@"cta_text"];
        self.Description = dictionary[@"description"];
        self.impression_url = dictionary[@"impression_url"];
    }
    return self;
}

- (void)dealloc
{
    self.click_url = nil;
    self.icon = nil;
    self.banner = nil;
    self.title = nil;
    self.cta_text = nil;
    self.Description = nil;
    self.impression_url = nil;
}

@end
