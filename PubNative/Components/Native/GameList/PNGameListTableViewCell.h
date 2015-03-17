//
//  PNGameListTableViewCell.h
//  PubNativeDemo
//
//  Created by David Martin on 16/03/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNNativeAdModel.h"

@protocol PNGameListTableViewCellDelegate <NSObject>

- (void)pnGameListCellSelected;

@end

@interface PNGameListTableViewCell : UITableViewCell

@property (nonatomic, weak) NSObject<PNGameListTableViewCellDelegate> *delegate;

- (void)setModel:(PNNativeAdModel*)model;
- (void)setDark:(BOOL)set;

- (void)willDisplay;
- (void)didDisplay;


@end
