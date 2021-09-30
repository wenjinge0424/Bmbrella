//
//  ReportedUserDetailViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "ReportedUserDetailViewController.h"

@interface ReportedUserDetailViewController ()
{
    IBOutlet UIButton *btnBan;
    IBOutlet UIButton *btnDelet;
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextView *txtDesc;
    IBOutlet UILabel *lblUser;
}
@end

@implementation ReportedUserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:btnBan];
    [Util setCornerView:btnDelet];
    
    PFUser *owner = self.object[PARSE_REPORT_OWNER];
    NSInteger type = [owner[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        lblTitle.text = owner[PARSE_USER_FULL_NAME];
    } else {
        lblTitle.text = owner[PARSE_USER_COMPANY_NAME];
    }
    txtDesc.text = self.object[PARSE_REPORT_DESCRIPTION];
    PFUser *reporter = self.object[PARSE_REPORT_REPORTER];
    type = [reporter[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        lblUser.text = [NSString stringWithFormat:@"Reported by: %@", reporter[PARSE_USER_FULL_NAME]];
    } else {
        lblUser.text = [NSString stringWithFormat:@"Reported by: %@", reporter[PARSE_USER_COMPANY_NAME]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDelReport:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [self showErrorMsg:[error localizedDescription]];
            } else {
                [Util showAlertTitle:self title:@"" message:@"Sucess" finish:^(void){
                    [self onback:nil];
                }];
            }
        }];
    }];
    [alert addButton:@"Cancel" actionBlock:^(void) {
        
    }];
    [alert showError:@"Delete Ad" subTitle:@"Are you sure want to delete this report?" closeButtonTitle:nil duration:0.0f];
}

- (IBAction)onBanuse:(id)sender { // ban user
    PFUser *owner = self.object[PARSE_REPORT_OWNER];
    BOOL isBanned = [owner[PARSE_USER_IS_BANNED] boolValue];
    if (isBanned){
        [self showErrorMsg:@"This user is already banned."];
        return;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              owner.username, @"email",
                              [NSNumber numberWithBool:YES], @"isBanned",
                              nil];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [PFCloud callFunctionInBackground:@"resetBanned" withParameters:data block:^(id object, NSError *err) {
            if (err) {
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[err localizedDescription] finish:nil];
            } else {
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self onback:nil];
                }];
            }
        }];
    }];
    [alert addButton:@"Cancel" actionBlock:^(void) {
        
    }];
    [alert showError:@"Ban User" subTitle:@"Are you sure want to ban this user?" closeButtonTitle:nil duration:0.0f];
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
