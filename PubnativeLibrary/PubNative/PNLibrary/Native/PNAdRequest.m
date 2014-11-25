//
// PNRequest.m
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

#import "PNAdRequest.h"

@interface PNAdRequest()

@property (nonatomic, strong) PNAdRequestTargeting          *targeting;
@property (nonatomic, strong) PNRequestCompletionBlock      requestBlock;

@end

@implementation PNAdRequest

#pragma mark - Class Lifecycle

- (id)initWithTargeting:(PNAdRequestTargeting*)targeting completionBlock:(PNRequestCompletionBlock)block
{
    return [self initWithTargeting:targeting completionBlock:block autostart:YES];
}

- (id)initWithTargeting:(PNAdRequestTargeting*)targeting completionBlock:(PNRequestCompletionBlock)block autostart:(BOOL)autostart
{
    self = [super init];
    
    if (self) {
        self.targeting      = targeting;
        self.requestBlock   = block;
        
        if (autostart)
        {
            [self getAds];
        }
    }
    
    return self;
}



#pragma mark - Private Methods

- (void)getAds
{
    __weak typeof(self) weakSelf = self;
    
    self.apiModel = [[PNAPIModel alloc] initWithURL:[NSURL URLWithString:kUrlString]
                                             method:kMethodGet
                                             params:[self.targeting getProperties]
                                            headers:nil
                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeout:30
                                 andCompletionBlock:^(NSError *error)
                     {
                         __strong typeof(self) strongSelf = weakSelf;
                         [strongSelf processAdsWithError:error];
                     }];
}

- (void)processAdsWithError:(NSError*)error
{
    if (!error && [self.apiModel.status isEqualToString:@"ok"])
    {
        self.requestBlock([self.apiModel.ads mutableCopy], nil);
    }
    else
    {
        self.requestBlock(nil, error);
    }
}

@end
