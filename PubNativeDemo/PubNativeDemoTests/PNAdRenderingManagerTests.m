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

#import "PNNativeAdModel.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"

@interface PNAdRenderingManagerTests : XCTestCase

@property (nonatomic, strong) PNNativeAdModel       *appModel;
@property (nonatomic, strong) PNNativeAdRenderItem  *renderItem;

@property (nonatomic, strong) UILabel       *titleLabel;

@end

@implementation PNAdRenderingManagerTests

- (void)setUp
{
    [super setUp];
    
    self.appModel = [[PNNativeAdModel alloc] init];
    self.appModel.title = @"Title";
    
    self.renderItem = [PNNativeAdRenderItem renderItem];
    self.titleLabel = [[UILabel alloc] init];
    
    self.renderItem.title = self.titleLabel;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testRender
{
    [PNAdRenderingManager renderNativeAdItem:self.renderItem withAd:self.appModel];
    XCTAssertEqualObjects(self.appModel.title, self.renderItem.title.text, @"Expected the two strings to be the same");
}

@end
