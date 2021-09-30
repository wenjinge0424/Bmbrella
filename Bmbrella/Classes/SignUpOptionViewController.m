//
//  SignUpOptionViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SignUpOptionViewController.h"
#import "SignUpOneViewController.h"
#import "SignUpPhoneInputViewController.h"

@interface SignUpOptionViewController ()
{
    PFUser *user;
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblDesc;
    IBOutlet UILabel *lblPerson;
    IBOutlet UILabel *lblBusiness;
}
@end

@implementation SignUpOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [PFUser user];
    lblTitle.text = LOCALIZATION(@"sign_up");
    [Util setCornerView:lblPerson];
    [Util setCornerView:lblBusiness];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configLanguage];
}

- (void) configLanguage {
    lblTitle.text = LOCALIZATION(@"sign_up");
    lblDesc.text = LOCALIZATION(@"select_type");
    lblPerson.text = LOCALIZATION(@"personal");
    lblBusiness.text = LOCALIZATION(@"business");
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChoose:(id)sender {
    UIButton *button = (UIButton *) sender;
    NSInteger tag = [button tag];
    user[PARSE_USER_TYPE] = [NSNumber numberWithInteger:tag];
    
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"singup_email") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        SignUpOneViewController *vc = (SignUpOneViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOneViewController"];
        vc.user = user;
        [self.navigationController pushViewController:vc animated:YES];
        
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"singup_phone") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        SignUpPhoneInputViewController *vc = (SignUpPhoneInputViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpPhoneInputViewController"];
        vc.user = user;
        [self.navigationController pushViewController:vc animated:YES];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
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
