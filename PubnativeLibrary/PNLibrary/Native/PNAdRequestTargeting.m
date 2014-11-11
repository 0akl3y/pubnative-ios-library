//
// PNAdRequestTargeting.m
//
// Created by Csongor Nagy on 04/06/14.
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

#import <objc/runtime.h>
#import <AdSupport/ASIdentifierManager.h>

#import "NSString+PNMD5.h"
#import "NSString+PNSHA1.h"

#import "PNAdConstants.h"
#import "PNAdRequestTargeting.h"

@implementation PNAdRequestTargeting

+ (id)sharedInstance
{
    static PNAdRequestTargeting *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;

}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.ad_count = @3;
        
        self.os = [[UIDevice currentDevice] systemName];
        self.os_version = [[UIDevice currentDevice] systemVersion];
        self.device_model = [[UIDevice currentDevice] model];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.icon_size = kIpadIconSize;
            self.banner_size = kIpadBannerSize;
            self.device_type = kIpadDeviceName;
        }
        else
        {
            self.icon_size = kIphoneIconSize;
            self.banner_size = kIphoneBannerSize;
            self.device_type = kIphoneDeviceName;
        }
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
        self.device_resolution = [NSString stringWithFormat:@"%ix%i",
                                  [[NSNumber numberWithFloat:screenSize.width] intValue],
                                  [[NSNumber numberWithFloat:screenSize.height] intValue]];

        self.bundle_id = [[NSBundle mainBundle] bundleIdentifier];
        
        NSLocale *currentLocale = [NSLocale currentLocale];
        self.locale = [currentLocale objectForKey:NSLocaleLanguageCode];
        
        if(NSClassFromString(@"ASIdentifierManager")) {
            if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
                NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                if(idfa)
                {
                    self.apple_idfa = idfa;
                    self.apple_idfa_md5 = [idfa md5String];
                    self.apple_idfa_sha1 = [idfa sha1String];
                }
            }
        }
        
        if (!self.apple_idfa)
        {
            self.no_user_id = @"1";
        }
    }
    
    return self;
}

- (NSMutableDictionary*)getProperties
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for(NSInteger i = 0; i < propertyCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:propName
                                                    encoding:[NSString defaultCStringEncoding]];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [self performSelector:NSSelectorFromString(propertyName)];
#pragma clang diagnostic pop
        
        if (value && value != [NSNull null])
        {
            [dict setObject:value forKey:propertyName];
        }
    }
    
    return dict;
}

@end
