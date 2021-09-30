//
//  MainViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//
#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"

#import "SuperViewController.h"

@interface MainViewController : SuperViewController

+ (MainViewController *) getInstance;
- (void) onSearch;

- (void) setContentOffset:(CGPoint)point;

@end
