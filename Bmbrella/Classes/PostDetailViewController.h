//
//  PostDetailViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SuperViewController.h"
#import "GUIPlayerView.h"

@protocol PostDetailViewControllerDelegate
- (void)PostDetailViewControllerDelegate_complete;
@end

@interface PostDetailViewController : SuperViewController
@property (nonatomic, retain) id<PostDetailViewControllerDelegate>delegate;
@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) AVPlayer *avplayer;
@property (nonatomic) CMTime currentTime;
@property (nonatomic) NSString *filePath;

@end
