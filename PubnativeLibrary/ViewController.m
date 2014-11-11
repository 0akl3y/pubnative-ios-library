//
// ViewController.m
//
// Created by Csongor Nagy on 11/11/14.
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

#import "ViewController.h"

#import "PNAdRequest.h"

@interface ViewController ()

@property (strong, nonatomic) PNAdRequest   *request;
@property (strong, nonatomic) PNAPIModel    *result;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    [[PNAdRequestTargeting sharedInstance] setApp_token:@"1dbe82c9cf40d82aeea6368a878c756cccf0ac10f4db75672e12a4c6c0a6c0e2"];
    
    self.request = [[PNAdRequest alloc] initWithTargeting:[PNAdRequestTargeting sharedInstance]
                                          completionBlock:^(PNAPIModel *result, NSError *error) {
                                              __strong typeof(self) strongSelf = weakSelf;
                                              
                                              strongSelf.result = result;
                                              
                                              if ([strongSelf.result.status isEqualToString:@"error"])
                                              {
                                                  NSLog(@"Error: %@", strongSelf.result.error_message);
                                              }
                                              else
                                              {
                                                  NSLog(@"Loaded %lu offers", (unsigned long)[strongSelf.result.ads count]);
                                                  
                                                  for (PNAdModel *ad in strongSelf.result.ads) {
                                                      NSLog(@" - %@", ad.title);
                                                  }
                                              }
                                          }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
