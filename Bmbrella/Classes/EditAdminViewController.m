//
//  EditAdminViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "EditAdminViewController.h"

@interface EditAdminViewController ()
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtRepassword;
    
    IBOutlet UIButton *btnSave;
    PFUser *me;
}
@end

@implementation EditAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setCornerView:btnSave];
    me = [PFUser currentUser];
    txtEmail.text = me.username;
    txtPassword.text = [Util getLoginUserPassword];
    txtRepassword.text = [Util getLoginUserPassword];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender {
    if (![self isValid]){
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    me[PARSE_USER_EMAIL] = txtEmail.text;
    me.username = txtEmail.text;
    me[PARSE_USER_PASSWORD] = txtPassword.text;
    me[PARSE_USER_USERNAME] = txtEmail.text;
    me[PARSE_USER_PRE_PASSWORD] = txtPassword.text;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:txtEmail.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        } else if (object) {
            [SVProgressHUD dismiss];
            [self showErrorMsg:@"This email is already taken by other user."];
        } else {
            [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                [SVProgressHUD dismiss];
                if (error){
                    [self showErrorMsg:[error localizedDescription]];
                } else {
                    [Util showAlertTitle:self title:@"" message:@"Success"];
                    [Util setLoginUserName:txtEmail.text password:txtPassword.text];
                }
            }];
        }
    }];
}

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if (email.length == 0){
        [self showErrorMsg:@"Please enter your email address."];
        return NO;
    }
    NSString *password = txtPassword.text;
    if (password.length == 0){
        [self showErrorMsg:@"Please enter password."];
        return NO;
    }
    if (password.length < 6){
        [self showErrorMsg:@"Password is too short."];
        return NO;
    }
    NSString *rePwd = txtRepassword.text;
    if (![password isEqualToString:rePwd]){
        [self showErrorMsg:@"Passwords do not match."];
        return NO;
    }
    return YES;
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
