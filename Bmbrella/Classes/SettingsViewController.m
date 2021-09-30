//
//  SettingsViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditPersonalViewController.h"
#import "EditBusinessViewController.h"
#import "LoginViewController.h"
#import "InformViewController.h"
#import "RequestsViewController.h"
#import "AllNotifyViewController.h"

@interface SettingsViewController ()
{
    PFUser *me;
    IBOutlet UILabel *lblEditProfile;
    IBOutlet UILabel *lblLanguage;
    IBOutlet UILabel *lblRateApp;
    IBOutlet UILabel *lblSendFeedback;
    IBOutlet UILabel *lblAboutApp;
    IBOutlet UILabel *lblPrivacy;
    IBOutlet UILabel *lblTerms;
    IBOutlet UILabel *lblLogout;
    IBOutlet UIImageView *imgBackground;
    IBOutlet UIImageView *ic_dot;
    __weak IBOutlet UILabel *lblNotifications;
    __weak IBOutlet UILabel *lbl_following;
    __weak IBOutlet UIImageView *ic_wholeDot;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
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
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query whereKey:PARSE_FOLLOW_TO equalTo:me];
    [query whereKey:PARSE_FOLLOW_ACTIVE equalTo:@NO];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (array.count > 0){
            ic_dot.hidden = NO;
        } else {
            ic_dot.hidden = YES;
        }
        
        PFQuery * notificationQuery = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
        [notificationQuery whereKey:PARSE_NOTIFICATION_TO equalTo:me];
        [notificationQuery whereKey:PARSE_NOTIFICATION_ISREAD equalTo:@NO];
        [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            [SVProgressHUD dismiss];
            if (array.count > 0){
                ic_wholeDot.hidden = NO;
            } else {
                ic_wholeDot.hidden = YES;
            }
        }];
        
    }];
    
    [self configLanguage];
}

- (void) configLanguage {
    lblNotifications.text = LOCALIZATION(@"notification");
    lbl_following.text = LOCALIZATION(@"following_noitification");
    lblTitle.text = LOCALIZATION(@"settings");
    lblEditProfile.text = LOCALIZATION(@"edit_profile");
    lblLanguage.text = LOCALIZATION(@"lng");
    lblRateApp.text = LOCALIZATION(@"rate_app");
    lblSendFeedback.text = LOCALIZATION(@"send_feedback");
    lblAboutApp.text = LOCALIZATION(@"about_app");
    lblPrivacy.text = LOCALIZATION(@"privacy");
    lblTerms.text = LOCALIZATION(@"terms_condition");
    lblLogout.text = LOCALIZATION(@"log_out");
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNotifications:(id)sender {
    RequestsViewController *vc = (RequestsViewController *)[Util getUIViewControllerFromStoryBoard:@"RequestsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onWholeNotifications:(id)sender {
    AllNotifyViewController *vc = (AllNotifyViewController *)[Util getUIViewControllerFromStoryBoard:@"AllNotifyViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onEditProfile:(id)sender {
    UIViewController *vc;
    if ([me[PARSE_USER_TYPE] intValue] == USER_TYPE_CUSTOMER){
        vc = (EditPersonalViewController *)[Util getUIViewControllerFromStoryBoard:@"EditPersonalViewController"];
    } else if ([me[PARSE_USER_TYPE] intValue] == USER_TYPE_BUSINESS){
        vc = (EditBusinessViewController *)[Util getUIViewControllerFromStoryBoard:@"EditBusinessViewController"];
    }
    if (vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)onLanguage:(id)sender {
    NSString *msg = LOCALIZATION(@"choose_lng");
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    [alert addButton:@"English" actionBlock:^(void) {
        [Util setLanguage:KEY_LANGUAGE_EN];
        [self setLanguage];
    }];
    [alert addButton:@"العربية" actionBlock:^(void) {
        [Util setLanguage:KEY_LANGUAGE_AR];
        [self setLanguage];
    }];
    [alert addButton:@"Français" actionBlock:^(void) {
        [Util setLanguage:KEY_LANGUAGE_FR];
        [self setLanguage];
    }];
    [alert addButton:@"Español" actionBlock:^(void) {
        [Util setLanguage:KEY_LANGUAGE_ES];
        [self setLanguage];
    }];
    [alert showQuestion:LOCALIZATION(@"lng") subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (void) setLanguage {
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.color = [UIColor whiteColor];
    hud.labelText = LOCALIZATION(@"set_language");
    hud.labelColor = [UIColor redColor];
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
        [self configLanguage];
    });
}

- (IBAction)onRateApp:(id)sender {
    NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
    str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
    str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
    
    // Here is the app id from itunesconnect
    str = [NSString stringWithFormat:@"%@%@", str, APP_ID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (IBAction)onSendFeedback:(id)sender {
    [self sendMail:[NSArray arrayWithObject:@"admin@bmbrella.com"] subject:nil message:nil];
}

- (IBAction)onAbout:(id)sender {
    [self openInformation:FLAG_ABOUT_THE_APP];
}

- (IBAction)onPrivacy:(id)sender {
    [self openInformation:FLAG_PRIVACY_POLICY];
}

- (IBAction)onTerms:(id)sender {
    [self openInformation:FLAG_TERMS_OF_SERVERICE];
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
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    break;
                }
            }
        }
    }];
}

- (void) openInformation:(int) type {
    InformViewController *vc = (InformViewController *)[Util getUIViewControllerFromStoryBoard:@"InformViewController"];
    vc.type = type;
    [self.navigationController pushViewController:vc animated:YES];
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
