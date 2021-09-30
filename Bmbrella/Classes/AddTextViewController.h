//
//  AddTextViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SuperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@class AddTextViewController;

@protocol SetDataDelegate <NSObject>
@required
- (void)setTitle:(NSString *) title;
- (void)setColor:(NSInteger) colorIndex;
- (void)setImage:(UIImage *) image;
- (void)setVideoUrl:(NSURL *) url;
@end


@interface AddTextViewController : SuperViewController
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *videoData;
@property (strong, nonatomic) NSURL *videoUrl;
@property(nonatomic, strong) AVAsset *videoAsset;
@property (strong, nonatomic) AVPlayer *avplayer;
@property (nullable, nonatomic, weak) id<SetDataDelegate> delegate;
@end
