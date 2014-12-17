//
// PNAdRequestTests.m
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

@interface PNAdRequestTests : XCTestCase

@property (nonatomic, strong) PNAdRequestCompletionBlock  block;

@end

@implementation PNAdRequestTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInstanceCreation
{
    PNAdRequest *nativeNotNil = [PNAdRequest request:PNAdRequest_Native
                                      withParameters:[PNAdRequestParameters requestParameters]
                                       andCompletion:nil];
    
    XCTAssertNotNil(nativeNotNil, @"Expected Native request to be allocated");

    PNAdRequest *nativeNil = [PNAdRequest request:PNAdRequest_Native
                                   withParameters:nil
                                    andCompletion:nil];
    
    XCTAssertNil(nativeNil, @"Expected Native nil request");

    PNAdRequest *imageNotNil = [PNAdRequest request:PNAdRequest_Image
                                     withParameters:[PNAdRequestParameters requestParameters]
                                      andCompletion:nil];
    
    XCTAssertNotNil(imageNotNil, @"Expected request to be allocated");

    PNAdRequest *imageNil = [PNAdRequest request:PNAdRequest_Image
                                  withParameters:nil
                                   andCompletion:nil];
    
    XCTAssertNil(imageNil, @"Expected nil request");
}

@end
