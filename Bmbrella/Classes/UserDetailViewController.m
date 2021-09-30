//
//  UserDetailViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "UserDetailViewController.h"
#import "CircleImageView.h"

@interface UserDetailViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblEmail;
    IBOutlet UILabel *lblPassword;
    IBOutlet CircleImageView *imgAvatar;
    
    IBOutlet UIButton *btnAction;
    BOOL isBanned;
}
@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:btnAction];
    [Util setBorderView:imgAvatar color:[UIColor whiteColor] width:1.0];
    
    [self showData];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initData {
    if (![Util isConnectableInternet]){
        return;
    }
    
    if (![SVProgressHUD isVisible])
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [self.user fetchInBackgroundWithBlock:^(PFObject *data, NSError *error){
        [SVProgressHUD dismiss];
        if (!error){
            self.user = (PFUser *)data;
        }
        [self showData];
    }];
}

- (void) showData {
    [Util setImage:imgAvatar imgFile:(PFFile *)self.user[PARSE_USER_AVATAR]];
    lblEmail.text = self.user.username;
    NSInteger type = [self.user[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        lblTitle.text = self.user[PARSE_USER_FULL_NAME];
    } else {
        lblTitle.text = self.user[PARSE_USER_COMPANY_NAME];
    }
    lblPassword.text = @"******";
    isBanned = [self.user[PARSE_USER_IS_BANNED] boolValue];
    if (isBanned){
        [btnAction setTitle:@"Unban this User" forState:UIControlStateNormal];
    } else {
        [btnAction setTitle:@"Ban this User" forState:UIControlStateNormal];
    }
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doActionUser:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.user.username, @"email",
                          isBanned?@NO:@YES, @"isBanned",
                          nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [PFCloud callFunctionInBackground:@"resetBanned" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[err localizedDescription] finish:nil];
        } else {
            [self sendPush];
            [Util showAlertTitle:self title:@"" message:@"Success"];
            [self initData];
        }
    }];
}

- (void) sendPush {
    NSString *pushMsg = @"You are banned by admin.";
    NSDictionary *data = @{
                           @"alert" : pushMsg,
                           @"badge" : @"Increment",
                           @"sound" : @"cheering.caf",
                           @"email" : self.user.username,
                           @"type"  : [NSNumber numberWithInt:PUSH_TYPE_BAN],
                           };
    
    [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            NSLog(@"Fail APNS: %@", @"send ban push");
        } else {
            NSLog(@"Success APNS: %@", @"send ban push");
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
