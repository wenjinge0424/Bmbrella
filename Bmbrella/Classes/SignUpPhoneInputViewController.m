//
//  SignUpPhoneInputViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 3/26/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "SignUpPhoneInputViewController.h"
#import "SignUpTwoViewController.h"
#import "SignupPhoneVerifyViewController.h"
#import "CountryListViewController.h"

@interface SignUpPhoneInputViewController ()<CountryListViewDelegate>
{
    IBOutlet UITextField *txtPhone;
    IBOutlet UIButton *btnValid;
    IBOutlet UIButton *btnNoUse;
    
    IBOutlet UILabel *lblValid;
    IBOutlet UILabel *lblUse;
    IBOutlet UIButton *btnNext;
    
    NSMutableArray *dataArray;
    IBOutlet UIButton *btnCode;
    NSString *phone_code;
}
@end

@implementation SignUpPhoneInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dataArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query includeKey:PARSE_USER_PHONE_NUMBER];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                NSString *phoneNumber = owner[PARSE_USER_PHONE_NUMBER];
                if (phoneNumber != nil && phoneNumber.length > 0)
                    [dataArray addObject:owner[PARSE_USER_PHONE_NUMBER]];
            }
        }
    }];
    
    [txtPhone addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    phone_code = @"+1";
}

- (IBAction)onPhoneCode:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:nil];
}

- (void) didSelectCountry:(NSDictionary *)country{
    [btnCode setTitle:[NSString stringWithFormat:@"%@", country[@"dial_code"]] forState:UIControlStateNormal];
    phone_code = [Util clearString:country[@"dial_code"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    
//    //*****///
//    NSString *code = [NSString stringWithFormat:@"2222"];
//    SignupPhoneVerifyViewController *vc = (SignupPhoneVerifyViewController *)[Util getUIViewControllerFromStoryBoard:@"SignupPhoneVerifyViewController"];
//    vc.user = self.user;
//    vc.phoneCode = code;
//    [self.navigationController pushViewController:vc animated:YES];
//    return;
//    ///****////
    
    NSString *phoneNum = [NSString stringWithFormat:@"%@%@", phone_code, txtPhone.text];
    self.user[PARSE_USER_PHONE_NUMBER] = [NSString stringWithFormat:@"%@%@", phone_code, txtPhone.text];
    self.user.username = [NSString stringWithFormat:@"%@%@", phoneNum, @"@bmbrella.com"];
    self.user[PARSE_USER_EMAIL] = self.user.username;
    self.user[PARSE_USER_PHONE_CODE] = phone_code;
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    NSDictionary *data = @{
                           @"number" : [NSString stringWithFormat:@"%@%@", phone_code, txtPhone.text],
                           };
    [PFCloud callFunctionInBackground:@"phoneVerify" withParameters:data block:^(id object, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            NSDictionary *dic = (NSDictionary *)[err localizedDescription];
            [self showErrorMsg:dic[@"message"]];
        } else {
            NSString *code = [NSString stringWithFormat:@"%@", (NSString *)object];
            SignupPhoneVerifyViewController *vc = (SignupPhoneVerifyViewController *)[Util getUIViewControllerFromStoryBoard:@"SignupPhoneVerifyViewController"];
            vc.user = self.user;
            vc.phoneCode = code;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
   
}

-(void)textFieldDidChange :(UITextField *) textField{
    txtPhone.text = [Util trim:txtPhone.text];
    NSString *phone = [NSString stringWithFormat:@"%@%@", phone_code, txtPhone.text];
    btnValid.selected = [phone isPhone];
    if (![phone isPhone]){
        btnNoUse.selected = NO;
        btnNext.enabled = NO;
        return;
    }
    if ([dataArray containsObject:phone]){
        btnNoUse.selected = NO;
        btnNext.enabled = NO;
    } else if ([phone isPhone]){
        btnNoUse.selected = YES;
        btnNext.enabled = YES;
    }
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
