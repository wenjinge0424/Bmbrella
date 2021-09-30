//
//  MediaViewController.h
//  Bmbrella
//
//  Created by gao on 4/24/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "SuperViewController.h"

@interface MediaViewController : SuperViewController

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) PFFile *video;
@property (nonatomic) CMTime currentTime;
@property (nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *txtDescriptionString;

@end
