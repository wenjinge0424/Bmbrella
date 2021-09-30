//
//  SignUpTwoViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SignUpTwoViewController.h"
#import "SignupThreeViewController.h"

@interface SignUpTwoViewController ()
{
    IBOutlet UITextField *txtPassword;
    IBOutlet UIButton *btnNext;
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnLength;
    IBOutlet UIButton *btnUpper;
    IBOutlet UIButton *btnLower;
    IBOutlet UIButton *btnNumber;
    IBOutlet UILabel *lblLength;
    IBOutlet UILabel *lblUpper;
    IBOutlet UILabel *lblLower;
    IBOutlet UILabel *lblNumber;
}
@end

@implementation SignUpTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblTitle.text = LOCALIZATION(@"sign_up");
    txtPassword.placeholder = LOCALIZATION(@"enter_password");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    lblLength.text = LOCALIZATION(@"pwd_one");
    lblUpper.text = LOCALIZATION(@"pwd_two");
    lblLower.text = LOCALIZATION(@"pwd_three");
    lblNumber.text = LOCALIZATION(@"pwd_four");
    txtPassword.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    self.user[PARSE_USER_PASSWORD] = txtPassword.text;
    self.user[PARSE_USER_PRE_PASSWORD] = txtPassword.text;
    SignupThreeViewController *vc = (SignupThreeViewController *)[Util getUIViewControllerFromStoryBoard:@"SignupThreeViewController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL) isValid {
    BOOL result = btnLength.selected /*&& btnLower.selected && btnUpper.selected && btnNumber.selected */;
    return result;
}

-(void)textFieldDidChange :(UITextField *) textField{
    NSString *password = txtPassword.text;
    btnLength.selected = (password.length >= 6);
    btnUpper.selected = [Util isContainsUpperCase:password];
    btnLower.selected = [Util isContainsLowerCase:password];
    btnNumber.selected = [Util isContainsNumber:password];
    btnNext.enabled = [self isValid];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 20;
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
