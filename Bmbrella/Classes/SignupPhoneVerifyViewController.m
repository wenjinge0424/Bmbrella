//
//  SignupPhoneVerifyViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 3/14/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "SignupPhoneVerifyViewController.h"
#import "SignUpFiveViewController.h"
#import "MainViewController.h"
#import "RootViewController.h"
#import "SignUpTwoViewController.h"


@interface SignupPhoneVerifyViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextField *txtCode;
    
    IBOutlet UIButton *btnValid;
    IBOutlet UIButton *btnNext;
}
@end

@implementation SignupPhoneVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [txtCode addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidChange :(UITextField *) textField{
    btnValid.selected = [self.phoneCode isEqualToString:txtCode.text];
    btnNext.enabled = btnValid.selected;
}


- (IBAction)onNext:(id)sender {
//    int type = [self.user[PARSE_USER_TYPE] intValue];
//    if (type == USER_TYPE_CUSTOMER){
//        SignUpFiveViewController *vc = (SignUpFiveViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFiveViewController"];
//        vc.user = self.user;
//        [self.navigationController pushViewController:vc animated:YES];
//    } else if (type == USER_TYPE_BUSINESS){
//        [self signup];
//    }
    SignUpTwoViewController *vc = (SignUpTwoViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpTwoViewController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) signup {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util setLoginUserName:self.user[PARSE_USER_EMAIL] password:self.user[PARSE_USER_PASSWORD]];
            NSString *message = LOCALIZATION(@"success_sign_up");
            [Util showAlertTitle:self title:LOCALIZATION(@"success") message:message finish:^(void){
                RootViewController *vc = (RootViewController *)[Util getUIViewControllerFromStoryBoard:@"RootViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            NSString *errMsg = [error localizedDescription];
            if ([errMsg containsString:@"already exist"]){
                [self showErrorMsg:@"Account already exists for this email."];
            } else {
                [self showErrorMsg:errMsg];
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
