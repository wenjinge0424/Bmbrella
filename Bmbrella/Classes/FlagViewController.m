//
//  FlagViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 11/19/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "FlagViewController.h"

@interface FlagViewController ()
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIButton *btnReport;
    IBOutlet UIPlaceHolderTextView *txtDescription;
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation FlagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.object[PARSE_REPORT_TYPE] integerValue] == REPORT_TYPE_POST){
        lblTitle.text = LOCALIZATION(@"report_post");
    } else {
        lblTitle.text = LOCALIZATION(@"report_user");
    }
    txtDescription.placeholder = LOCALIZATION(@"no_reason");
    [Util setCornerView:txtDescription];
    [Util setCornerView:btnReport];
    [Util setBorderView:txtDescription color:[UIColor blackColor] width:1.0];
    
    PFUser *me = [PFUser currentUser];
    if (me){
        int userType = [me[PARSE_USER_TYPE] intValue];
        if (userType == USER_TYPE_CUSTOMER){
            [imgBackground setImage:[UIImage imageNamed:@"bg_main"]];
        } else if (userType == USER_TYPE_BUSINESS){
//            [imgBackground setImage:[UIImage imageNamed:@"bg_main_blue"]];
        }
    } else {
//        [imgBackground setImage:[UIImage imageNamed:@"bg_main_blue"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onReport:(id)sender {
    if (![self isValid]){
        return;
    }
    self.object[PARSE_REPORT_DESCRIPTION] = txtDescription.text;
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            [Util showAlertTitle:self title:lblTitle.text message:LOCALIZATION(@"success") finish:^(void){
                [self onback:nil];
            }];
        }
    }];
}

- (BOOL) isValid {
    txtDescription.text = [Util trim:txtDescription.text];
    NSString *text = txtDescription.text;
    if (text.length == 0){
        [self showErrorMsg:LOCALIZATION(@"no_reason")];
        return NO;
    }
    if (text.length < 10){
        [self showErrorMsg:LOCALIZATION(@"short_reason")];
        return NO;
    }
    if (text.length > 500){
        [self showErrorMsg:LOCALIZATION(@"long_reason")];
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
