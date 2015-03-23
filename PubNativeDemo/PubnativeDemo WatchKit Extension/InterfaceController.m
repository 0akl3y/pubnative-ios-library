//
//  InterfaceController.m
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

#import "InterfaceController.h"
#import "WKPubnative.h"

NSString * const kWKPubnativeTestAppToken = @"e1a8e9fcf8aaeff31d1ddaee1f60810957f4c297859216dea9fa283043f8680f";

@interface InterfaceController()<WKPubnativeDelegate>

- (IBAction)requestTouch;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *iconImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (strong, nonatomic) WKPNNativeAdModel *model;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)requestTouch
{
    [WKPubnative setDelegate:self];
    [WKPubnative requestWithAppToken:kWKPubnativeTestAppToken];
}

#pragma mark WKPubnativeDelegate

- (void)wkPNRequestDidLoad:(WKPNNativeAdModel *)model
{
    self.model = model;
    
    [self.titleLabel setText:self.model.title];
    [self.iconImage setImage:self.model.icon];
    
    [WKPubnative trackImpressionWithModel:self.model];
}

- (void)wkPNRequestDidFail:(NSError *)error
{
    NSLog(@"WKPubnative - Error in request: %@", [error description]);
}

- (void)wkPNTrackDidEnd
{
    NSLog(@"WKPubnative - Impression tracked");
}

- (void)wkPNTrackDidFail:(NSError *)error
{
    NSLog(@"WKPubnative - Error tracking impression: %@", [error description]);
}

@end



