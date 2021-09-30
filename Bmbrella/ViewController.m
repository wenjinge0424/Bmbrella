//
//  ViewController.m
//  PagaYa
//
//  Created by developer on 28/05/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ViewController.h"
#import "PagerViewController.h"
#import "LoginViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [Util appDelegate].rootNavigationViewController = self.navigationController;
    
    if (![Util isConnectableInternet]){
        [self gotoNextScreen];
        return;
    }
    PFUser *user = [PFUser currentUser];
    if (user){
        [PFUser logOutInBackgroundWithBlock:^(NSError *error){
            [self gotoNextScreen];
        }];
    } else {
        [self gotoNextScreen];
    }
}

- (void) gotoNextScreen {
    if (![Util getBoolValue:@"isFirst"]){
        [Util setBoolValue:@"isFirst" value:YES];
        [Util setLanguage:KEY_LANGUAGE_EN];
        
        NSString *msg = LOCALIZATION(@"choose_lng");
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = NO;
        [alert addButton:@"English" actionBlock:^(void) {
            [self setLanguage:KEY_LANGUAGE_EN];
        }];
        [alert addButton:@"العربية" actionBlock:^(void) {
            [self setLanguage:KEY_LANGUAGE_AR];
        }];
        [alert addButton:@"Français" actionBlock:^(void) {
            [self setLanguage:KEY_LANGUAGE_FR];
        }];
        [alert addButton:@"Español" actionBlock:^(void) {
            [self setLanguage:KEY_LANGUAGE_ES];
        }];
        [alert showQuestion:LOCALIZATION(@"lng") subTitle:msg closeButtonTitle:nil duration:0.0f];
    } else {
        LoginViewController *vc = (LoginViewController *)[Util getUIViewControllerFromStoryBoard:@"LoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) setLanguage:(NSString *) key {
    [Util setLanguage:key];
    [self openOnboards];
}

- (void) openOnboards{
    PagerViewController *vc = (PagerViewController *)[Util getUIViewControllerFromStoryBoard:@"PagerViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
