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

#import "PNImpressionManager.h"
#import "PNAdModel.h"

@interface PNImpressionManagerTests : XCTestCase

@property (nonatomic, strong) PNAdModel     *model;

@end

@implementation PNImpressionManagerTests

- (void)setUp {
    [super setUp];
    
    self.model = [[PNAdModel alloc] init];
    
    [[[PNImpressionManager sharedInstance] confirmedAds] removeAllObjects];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInstance {
    XCTAssertNotNil([PNImpressionManager sharedInstance], @"Expected the PNImpressionManager to be allocated");
}

- (void)testConfirmWithNoBeacon {
    [[PNImpressionManager sharedInstance] confirmWithAd:self.model
                                     andCompletionBlock:^(id result, NSError *error) {
                                         XCTAssertNil(result);
    }];
}

- (void)testConfirmedAdsSave
{
    [[[PNImpressionManager sharedInstance] confirmedAds] addObject:@"FancyUrl"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[PNImpressionManager sharedInstance] confirmedAds] forKey:@"confirmedAds"];
    [defaults synchronize];
    
    XCTAssertEqualObjects([[PNImpressionManager sharedInstance] confirmedAds],
                          [defaults objectForKey:@"confirmedAds"],
                          @"Expected the two arrays to be the same");
}

- (void)testConfirmedAdsRead
{
    [[[PNImpressionManager sharedInstance] confirmedAds] addObject:@"FancyUrl"];
    
    XCTAssertEqualObjects([[[PNImpressionManager sharedInstance] confirmedAds] lastObject],
                          @"FancyUrl",
                          @"Expected the two strings to be the same");
}

@end
