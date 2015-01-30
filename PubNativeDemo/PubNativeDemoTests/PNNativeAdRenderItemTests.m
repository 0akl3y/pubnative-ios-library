//
// PNAdRenderingManagerTests.m
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

#import "PNAdRequest.h"
#import "PNNativeAdModel.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"

FOUNDATION_IMPORT NSString * const kPubnativeTestAppToken;

CGFloat const kPNNativeAdRenderItemTestsDefaultTimeout = 30.0f;

@interface PNNativeAdRenderItemTests : XCTestCase

@property (strong, nonatomic) XCTestExpectation *iconExpectation;
@property (strong, nonatomic) XCTestExpectation *bannerExpectation;

@property (strong, nonatomic) PNAdRequest           *request;
@property (strong, nonatomic) PNNativeAdRenderItem  *renderItem;

@property (strong, nonatomic) UILabel       *title;
@property (strong, nonatomic) UITextView    *descriptionField;
@property (strong, nonatomic) UIImageView   *icon;
@property (strong, nonatomic) UIImageView   *banner;
@property (strong, nonatomic) UILabel       *cta_text;

@end

@implementation PNNativeAdRenderItemTests

- (void)setUp
{
    [super setUp];
    
    PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
    
    self.title = [[UILabel alloc] init];
    self.descriptionField = [[UITextView alloc] init];
    self.icon = [[UIImageView alloc] init];
    self.banner = [[UIImageView alloc] init];
    self.cta_text = [[UILabel alloc] init];
    
    renderItem.title = self.title;
    renderItem.descriptionField = self.descriptionField;
    renderItem.icon = self.icon;
    renderItem.banner = self.banner;
    renderItem.cta_text = self.cta_text;
    
    self.renderItem = renderItem;
}

- (void)tearDown
{
    self.iconExpectation = nil;
    self.bannerExpectation = nil;
    
    self.request = nil;
    self.renderItem = nil;
    
    self.title = nil;
    self.descriptionField = nil;
    self.icon = nil;
    self.banner = nil;
    self.cta_text = nil;
    
    [super tearDown];
}

- (void)testRender
{
    self.iconExpectation = [self expectationWithDescription:@"iconExpectation"];
    self.bannerExpectation = [self expectationWithDescription:@"iconExpectation"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadNotification:)
                                                 name:kPNAdRenderingManagerIconNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadNotification:)
                                                 name:kPNAdRenderingManagerBannerNotification
                                               object:nil];
    
    PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
    parameters.app_token = kPubnativeTestAppToken;
    
    self.request = [PNAdRequest request:PNAdRequest_Native
                         withParameters:parameters
                          andCompletion:^(NSArray *ads, NSError *error) {
               
                              XCTAssert(ads && [ads count] > 0, "Expected some ads in the request");
                              XCTAssert(!error, @"Errors not expected in the request");
                              
                              PNNativeAdModel *nativeAdModel = [ads firstObject];
                              
                              [PNAdRenderingManager renderNativeAdItem:self.renderItem withAd:nativeAdModel];
                              XCTAssertEqualObjects(nativeAdModel.title, self.renderItem.title.text, @"Expected the two strings to be the same");
                              XCTAssertEqualObjects(nativeAdModel.Description, self.renderItem.descriptionField.text, @"Expected the two strings to be the same");
                              XCTAssertEqualObjects(nativeAdModel.cta_text, self.renderItem.cta_text.text, @"Expected the two strings to be the same");
                          }];
    [self.request startRequest];
    [self waitForExpectationsWithTimeout:kPNNativeAdRenderItemTestsDefaultTimeout handler:nil];
}

- (void)downloadNotification:(NSNotification*)notification
{
    if([kPNAdRenderingManagerIconNotification isEqualToString:notification.name])
    {
        XCTAssertNotNil(self.renderItem.icon.image, @"Expected some image setted up");
        [self.iconExpectation fulfill];
    }
    else if([kPNAdRenderingManagerBannerNotification isEqualToString:notification.name])
    {
        XCTAssertNotNil(self.renderItem.banner.image, @"Expected some image setted up");
        [self.bannerExpectation fulfill];
    }
}

@end
