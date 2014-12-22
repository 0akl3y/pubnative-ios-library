//
// PNImpressionManagerTests.m
//
// Created by Csongor Nagy on 23/09/14.
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PNTrackingManager.h"
#import "PNNativeAdModel.h"
#import "PNAdConstants.h"

NSString * const kPNTrackingManagerTestMockURL    = @"FancyURL";
NSString * const kPNTrackingManagerTestGoogleURL  = @"http://www.google.com";

@interface PNTrackingManagerTests : XCTestCase

@property (nonatomic, strong) PNNativeAdModel     *model;

@end

@implementation PNTrackingManagerTests

- (void)setUp {
    [super setUp];

    NSArray *confirmedAds = [[NSArray alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:confirmedAds forKey:kPNAdConstantTrackingConfirmedAdsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.model = [[PNNativeAdModel alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testConfirmWithNoBeacon
{
    [PNTrackingManager trackImpressionWithAd:self.model
                            completion:^(id result, NSError *error)
    {
        XCTAssertNil(result);
    }];
}

- (void)testConfirmedAdsSave
{
    // This should NOT save the ad as we are using a fancyURL
    PNBeaconModel *impressionBeacon = [[PNBeaconModel alloc] init];
    impressionBeacon.type = kPNAdConstantTrackingBeaconImpressionTypeString;
    impressionBeacon.url = kPNTrackingManagerTestGoogleURL;
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:impressionBeacon];
    
    self.model.beacons = (NSArray<PNBeaconModel>*) array;
    
    __block NSArray *confirmedAds = [[NSUserDefaults standardUserDefaults] objectForKey:kPNAdConstantTrackingConfirmedAdsKey];
    [PNTrackingManager trackImpressionWithAd:self.model
                          completion:^(id result, NSError *error)
     {
         XCTAssertNotEqualObjects(confirmedAds,
                                  [[NSUserDefaults standardUserDefaults] objectForKey:kPNAdConstantTrackingConfirmedAdsKey],
                                  @"Expected ad to be saved with good URL");
     }];
}

- (void)testConfirmedAdsDontSave
{
    // This should NOT save the ad as we are using a fancyURL
    PNBeaconModel *impressionBeacon = [[PNBeaconModel alloc] init];
    impressionBeacon.type = kPNAdConstantTrackingBeaconImpressionTypeString;
    impressionBeacon.url = kPNTrackingManagerTestMockURL;
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:impressionBeacon];
    
    self.model.beacons = (NSArray<PNBeaconModel>*) array;
    
    __block NSArray *confirmedAds = [[NSUserDefaults standardUserDefaults] objectForKey:kPNAdConstantTrackingConfirmedAdsKey];
    
    [PNTrackingManager trackImpressionWithAd:self.model
                            completion:^(id result, NSError *error)
    {
        XCTAssertEqualObjects(confirmedAds,
                              [[NSUserDefaults standardUserDefaults] objectForKey:kPNAdConstantTrackingConfirmedAdsKey],
                              @"Expected ad not to be saved with mock URL");
    }];
}

@end
