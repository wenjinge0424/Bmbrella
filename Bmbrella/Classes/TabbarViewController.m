//
//  TabbarViewController.m
//  OMG
//
//  Created by Vitaly's Team on 7/18/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "TabbarViewController.h"
#import "MainViewController.h"

@interface TabbarViewController ()<UITabBarControllerDelegate>

@end

@implementation TabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBar setHidden:YES];
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    if(selectedIndex == 0){
        UINavigationController * nav0 = [self.viewControllers firstObject];
        UIViewController * mainViewCtr = [[nav0 viewControllers] firstObject];
        if([mainViewCtr isKindOfClass:[MainViewController class]]){
            [((MainViewController*) mainViewCtr) setContentOffset:CGPointZero];
        }
    }
}
@end
