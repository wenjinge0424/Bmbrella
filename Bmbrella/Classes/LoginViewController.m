//
//  LoginViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "LoginViewController.h"
#import "ResetPasswordViewController.h"
#import "SignUpOptionViewController.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import "RootViewController.h"

@interface LoginViewController ()
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    
    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnSignUp;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setCornerView:btnLogin];
    [Util setCornerView:btnSignUp];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configLanguage];

    if ([Util getLoginUserName].length > 0 && [Util getLoginUserPassword].length > 0){
        txtEmail.text = [Util getLoginUserName];
        txtPassword.text = [Util getLoginUserPassword];
        NSString *email = txtEmail.text;
        if ([email containsString:@"+"] && [email containsString:@"bmbrella.com"]){
            email = [email substringToIndex:[email length]-13];
            txtEmail.text = email;
        }
        [self onLogin:nil];
    }
}

- (void) configLanguage {
    [btnLogin setTitle:LOCALIZATION(@"let_go") forState:UIControlStateNormal];
    [btnSignUp setTitle:LOCALIZATION(@"sign_up") forState:UIControlStateNormal];
    
//    txtEmail.placeholder = LOCALIZATION(@"enter_email");
    txtPassword.placeholder = LOCALIZATION(@"enter_password");
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    txtEmail.text = @"";
    txtPassword.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    
    if (![self isValid]){
        return;
    }
    
    if ([txtEmail.text isEmail]){
        [self loginWithEmail];
    } else if ([txtEmail.text isPhone]){
        [self loginWithPhone];
    } else{
        [self loginWithName];
    }
}
- (void) loginWithName {
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query setLimit:1000];
    [query whereKey:PARSE_USER_FULL_NAME equalTo:txtEmail.text];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:txtPassword.text block:^(PFUser *user, NSError *error) {
                [SVProgressHUD dismiss];
                if (user) {
                    BOOL isBanned = [user[PARSE_USER_IS_BANNED] boolValue];
                    if (isBanned){
                        [Util showAlertTitle:self title:@"Error" message:@"Banned User"];
                        return;
                    }
                    [Util setLoginUserName:user.email password:txtPassword.text];
                    [self gotoMainScreen];
                } else {
                    NSString *errorString = LOCALIZATION(@"incorrect_password");
                    [Util showAlertTitle:self title:LOCALIZATION(@"login_failed") message:errorString finish:^{
                        [txtPassword becomeFirstResponder];
                    }];
                }
            }];
        }else{
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            
            NSString *msg = LOCALIZATION(@"msg_not_registerd_email");
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:LOCALIZATION(@"not_now") actionBlock:^(void) {
            }];
            [alert addButton:LOCALIZATION(@"sign_up") actionBlock:^(void) {
                [self onSignup:nil];
            }];
            [alert showError:LOCALIZATION(@"sign_up") subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
    
}
- (void) loginWithEmail {
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:txtEmail.text.lowercaseString];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:txtPassword.text block:^(PFUser *user, NSError *error) {
                [SVProgressHUD dismiss];
                if (user) {
                    BOOL isBanned = [user[PARSE_USER_IS_BANNED] boolValue];
                    if (isBanned){
                        [Util showAlertTitle:self title:@"Error" message:@"Banned User"];
                        return;
                    }
                    [Util setLoginUserName:user.email password:txtPassword.text];
                    [self gotoMainScreen];
                } else {
                    NSString *errorString = LOCALIZATION(@"incorrect_password");
                    [Util showAlertTitle:self title:LOCALIZATION(@"login_failed") message:errorString finish:^{
                        [txtPassword becomeFirstResponder];
                    }];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            
            NSString *msg = LOCALIZATION(@"msg_not_registerd_email");
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:LOCALIZATION(@"not_now") actionBlock:^(void) {
            }];
            [alert addButton:LOCALIZATION(@"sign_up") actionBlock:^(void) {
                [self onSignup:nil];
            }];
            [alert showError:LOCALIZATION(@"sign_up") subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
}

- (void) loginWithPhone {
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_PHONE_NUMBER equalTo:txtEmail.text.lowercaseString];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:txtPassword.text block:^(PFUser *user, NSError *error) {
                [SVProgressHUD dismiss];
                if (user) {
                    BOOL isBanned = [user[PARSE_USER_IS_BANNED] boolValue];
                    if (isBanned){
                        [Util showAlertTitle:self title:@"Error" message:@"Banned User"];
                        return;
                    }
                    [Util setLoginUserName:user.email password:txtPassword.text];
                    [self gotoMainScreen];
                } else {
                    NSString *errorString = LOCALIZATION(@"incorrect_password");
                    [Util showAlertTitle:self title:LOCALIZATION(@"login_failed") message:errorString finish:^{
                        [txtPassword becomeFirstResponder];
                    }];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            
            NSString *msg = LOCALIZATION(@"msg_not_registered_user");
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:LOCALIZATION(@"not_now") actionBlock:^(void) {
            }];
            [alert addButton:LOCALIZATION(@"sign_up") actionBlock:^(void) {
                [self onSignup:nil];
            }];
            [alert showError:LOCALIZATION(@"sign_up") subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
}

- (void) gotoMainScreen {
    PFUser *me = [PFUser currentUser];
    if (!me[PARSE_USER_TYPE]){
        [self showErrorMsg:LOCALIZATION(@"invalid_user")];
        return;
    }
    int type = [me[PARSE_USER_TYPE] intValue];
    if (type == USER_TYPE_ADMIN){
        HomeViewController *vc = (HomeViewController *)[Util getUIViewControllerFromStoryBoard:@"HomeViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == USER_TYPE_CUSTOMER) {
        RootViewController *vc = (RootViewController *)[Util getUIViewControllerFromStoryBoard:@"RootViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == USER_TYPE_BUSINESS){
        RootViewController *vc = (RootViewController *)[Util getUIViewControllerFromStoryBoard:@"RootViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    txtEmail.text = @"";
    txtPassword.text = @"";
}

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    
    NSString *password = txtPassword.text;
    if (email.length == 0){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_email") finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
//    if (![email isEmail] && ![email isPhone]){
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_email") finish:^(void){
//            [txtEmail becomeFirstResponder];
//        }];
//        return NO;
//    }
    
    if ([email containsString:@".."]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_email") finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    
    if (password.length == 0){
        [self showErrorMsg:LOCALIZATION(@"no_password")];
        return NO;
    }
    
    return YES;
}

- (IBAction)onResetPwd:(id)sender {
    ResetPasswordViewController *vc = (ResetPasswordViewController *)[Util getUIViewControllerFromStoryBoard:@"ResetPasswordViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSignup:(id)sender {
    SignUpOptionViewController *vc = (SignUpOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOptionViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
