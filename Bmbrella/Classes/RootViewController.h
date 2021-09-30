//
//  RootViewController.h
//  Bmbrella
//
//  Created by gao on 5/17/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "SuperViewController.h"
#import "TabbarViewController.h"
#import "MainViewController.h"

typedef enum {
    TAB_HOME = 1,
    TAB_CATEGORY,
    TAB_SEARCH,
    TAB_CHAT,
    TAB_SETTING
} TAB_INDEX;

@interface RootViewController : SuperViewController

@property(strong, nonatomic) TabbarViewController *tabbarController;

+ (RootViewController *) getInstance;
- (void) setCurrentTab:(NSInteger) tabIndex;
- (void) hideChatLabel;
- (void) setChatCount:(int)count;

@end
