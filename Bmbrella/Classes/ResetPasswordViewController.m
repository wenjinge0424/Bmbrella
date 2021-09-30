//
//  ResetPasswordViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "SignUpOptionViewController.h"

@interface ResetPasswordViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnDone;
    IBOutlet UITextField *txtEmail;
    IBOutlet UILabel *lbldesc;
    
    NSMutableArray *dataArray;
}
@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setCornerView:btnDone];
    dataArray = [[NSMutableArray alloc] init];
    
    dataArray = [[NSMutableArray alloc] init];
    if (![Util isConnectableInternet]){
        [self showErrorMsg:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                [dataArray addObject:user.username];
            }
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configLanguage];
}

- (void) configLanguage {
    lblTitle.text = LOCALIZATION(@"reset_pwd");
    lbldesc.text = LOCALIZATION(@"reset_desc");
    [btnDone setTitle:LOCALIZATION(@"done") forState:UIControlStateNormal];
    txtEmail.placeholder = LOCALIZATION(@"enter_email");
}
- (BOOL) stringArrayContains:(NSString*)str inArray:(NSMutableArray*)array
{
    for(NSString * subStr in array){
        if([subStr isEqualToString:str])
            return YES;
    }
    return NO;
}
- (IBAction)onSubmit:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    txtEmail.text = [Util trim:txtEmail.text.lowercaseString];
    NSString *email = txtEmail.text;
    if (email.length == 0){
        [self showErrorMsg:LOCALIZATION(@"no_email")];
        return;
    }
    if (![email isEmail]){
        [self showErrorMsg:LOCALIZATION(@"invalid_email")];
        return;
    }
    if (![self stringArrayContains:email inArray:dataArray]){
        NSString *msg = LOCALIZATION(@"msg_not_registerd_email");
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:LOCALIZATION(@"not_now") actionBlock:^(void) {
        }];
        [alert addButton:LOCALIZATION(@"sign_up") actionBlock:^(void) {
            SignUpOptionViewController *vc = (SignUpOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOptionViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }];
        [alert showError:LOCALIZATION(@"sign_up") subTitle:msg closeButtonTitle:nil duration:0.0f];
        return;
    }
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util showAlertTitle:self
                           title:LOCALIZATION(@"success")
                         message: LOCALIZATION(@"sent_reset_link")
                          finish:^(void) {
                              [self onback:nil];
                          }];
        } else {
            NSString *errorString = [error localizedDescription];
            [Util showAlertTitle:self
                           title:LOCALIZATION(@"error") message:errorString
                          finish:^(void) {
                          }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
