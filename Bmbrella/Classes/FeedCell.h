//
//  FeedCell.h
//  OMG
//
//  Created by Vitaly's Team on 7/22/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Config.h"
#import "Util.h"

@class FeedCell;

@protocol FeedCellDelegate <NSObject>
@required
- (void)onTapImageOne:(FeedCell *)cell;
- (void)onTapImageTwo:(FeedCell *)cell;
- (void)onTapImageThree:(FeedCell *)cell;
- (void)onTapImageFour:(FeedCell *)cell;
- (void)onTapImageFive:(FeedCell *)cell;
- (void)onTapImageSix:(FeedCell *)cell;
- (void)onTapImageSeven:(FeedCell *)cell;
- (void)onTapImageEight:(FeedCell *)cell;

- (void)onShareImageOne:(FeedCell *)cell;
- (void)onShareImageTwo:(FeedCell *)cell;
- (void)onShareImageThree:(FeedCell *)cell;
- (void)onShareImageFour:(FeedCell *)cell;
- (void)onShareImageFive:(FeedCell *)cell;
- (void)onShareImageSix:(FeedCell *)cell;
- (void)onShareImageSeven:(FeedCell *)cell;

@end


@interface FeedCell : UITableViewCell

@property (strong, nonatomic) id<FeedCellDelegate> delegate;

@end

