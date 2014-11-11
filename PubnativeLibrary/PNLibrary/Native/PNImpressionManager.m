//
// PNImpressionManager.m
//
// Created by Csongor Nagy on 19/06/14.
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

#import "PNImpressionManager.h"

NSString * const kImpressionErrorFileOperationError     = @"ImpressionManagerError";
NSString * const kImpressionManagerNamespace            = @"com.pubnative.ImpressionManager";

@implementation PNImpressionManager

static PNImpressionManager *sharedManager = nil;

#pragma mark - Class Lifecycle

+ (PNImpressionManager*)sharedInstance
{
    static PNImpressionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PNImpressionManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.confirmedAds = [defaults objectForKey:@"confirmedAds"] ? [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"confirmedAds"]] : [[NSMutableArray alloc] init];
    }
    return self;
}



#pragma mark - Instance Methods

- (void)confirmWithAd:(PNAdModel*)ad
{
    [[PNImpressionManager sharedInstance] confirmWithAd:ad andCompletionBlock:nil];
}

- (void)confirmWithAd:(PNAdModel*)ad andCompletionBlock:(PNImpressionCompletionBlock)block
{
    __block PNBeaconModel *beacon;
    
    if (ad.beacons)
    {
        [ad.beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            beacon = obj;
            
            if ([beacon.type isEqualToString:@"impression"] && beacon.url)
            {
                *stop = YES;
                return;
            }
        }];
    }
    else
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:kImpressionErrorFileOperationError
                    forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:kImpressionManagerNamespace
                                             code:0
                                         userInfo:userInfo];
        
        if (block)
        {
            block(nil, error);
        }
        return;
    }
    
    if (![[[PNImpressionManager sharedInstance] confirmedAds] containsObject:beacon.url])
    {
        NSLog(@"Confirming impression for '%@'", ad.title);
        
        [[[PNImpressionManager sharedInstance] confirmedAds] addObject:beacon.url];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[[PNImpressionManager sharedInstance] confirmedAds] forKey:@"confirmedAds"];
        [defaults synchronize];
        
        
        if ((NSNull*)ad.app_details.url_scheme != [NSNull null] &&
            [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:ad.app_details.url_scheme]])
        {
            beacon.url = [beacon.url stringByAppendingString:@"&installed=1"];
        }
        
        NSURL *requestURL = [NSURL URLWithString:beacon.url];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:30];
        
        [request setHTTPMethod:kMethodGet];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           [NSURLConnection sendAsynchronousRequest:request
                                                              queue:[NSOperationQueue mainQueue]
                                                  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                            {
                                dispatch_async(dispatch_get_main_queue(),
                                               ^{
                                                   if (block)
                                                   {
                                                       block(response, error);
                                                   }
                                               });
                            }];
                       });
    }
}

@end
