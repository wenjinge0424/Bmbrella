//
//  PostViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SuperViewController.h"
#import "AddTextViewController.h"

@interface PostViewController : SuperViewController
@property (strong, nonatomic) NSString *title;
@property (nonatomic) NSInteger colorIndex;
@property (strong, nonatomic) AVPlayer *avplayer;
@end
