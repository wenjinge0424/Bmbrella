//
//  HomeViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "HomeViewController.h"
#import "UsersViewController.h"
#import "AdminSettingsViewController.h"
#import "ReportedPostsViewController.h"
#import "ReportedUsersViewController.h"

@interface HomeViewController ()
{
    IBOutlet UILabel *lblTitle;
    
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onUsers:(id)sender {
    [self gotoNextScreen:(UsersViewController *)[Util getUIViewControllerFromStoryBoard:@"UsersViewController"]];
}

- (IBAction)onSettings:(id)sender {
    [self gotoNextScreen:(AdminSettingsViewController *)[Util getUIViewControllerFromStoryBoard:@"AdminSettingsViewController"]];

}

- (IBAction)onPosts:(id)sender {
    [self gotoNextScreen:(ReportedPostsViewController *)[Util getUIViewControllerFromStoryBoard:@"ReportedPostsViewController"]];

}

- (IBAction)onReportedUsers:(id)sender
{
    [self gotoNextScreen:(ReportedUsersViewController *)[Util getUIViewControllerFromStoryBoard:@"ReportedUsersViewController"]];

}

- (void) gotoNextScreen:(UIViewController *)vc {
    if (vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
