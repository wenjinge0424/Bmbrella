//
//  SignupPhoneVerifyViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 3/14/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "SuperViewController.h"

@interface SignupPhoneVerifyViewController : SuperViewController
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSString *phoneCode;
@end
