//
//  ChatViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SuperViewController.h"

@interface ChatViewController : SuperViewController
@property (strong, nonatomic) PFUser *toUser;
@property (strong, nonatomic) PFObject *room;
@end
