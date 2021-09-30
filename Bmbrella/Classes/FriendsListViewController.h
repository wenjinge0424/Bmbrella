//
//  FriendsListViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SuperViewController.h"

@interface FriendsListViewController : SuperViewController
@property (strong, nonatomic) PFUser *user;
@property (nonatomic) BOOL isFollowing;
@end
