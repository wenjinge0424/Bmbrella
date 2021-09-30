//
//  AdminSettingsViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "AdminSettingsViewController.h"
#import "EditAdminViewController.h"
#import "LoginViewController.h"

@interface AdminSettingsViewController ()

@end

@implementation AdminSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onEditProfile:(id)sender {
    EditAdminViewController *vc = (EditAdminViewController *)[Util getUIViewControllerFromStoryBoard:@"EditAdminViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onLogout:(id)sender {
    [SVProgressHUD showWithStatus:LOCALIZATION(@"loggin_out") maskType:SVProgressHUDMaskTypeGradient];
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:LOCALIZATION(@"log_out") message:[error localizedDescription]];
        } else {
            [Util setLoginUserName:@"" password:@""];
            for (UIViewController *vc in [Util appDelegate].rootNavigationViewController.viewControllers){
                if ([vc isKindOfClass:[LoginViewController class]]){
                    [[Util appDelegate].rootNavigationViewController popToViewController:vc animated:YES];
                    break;
                }
            }
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
