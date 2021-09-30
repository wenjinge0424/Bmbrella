//
//  SignUpOneViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SignUpOneViewController.h"
#import "SignUpTwoViewController.h"

@interface SignUpOneViewController ()
{
    IBOutlet UITextField *txtEmail;
    
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnRegister;
    IBOutlet UIButton *btnValid;
    IBOutlet UILabel *lblNotuse;
    IBOutlet UILabel *lblValid;
    
    NSMutableArray *dataArray;
}
@end

@implementation SignUpOneViewController
@synthesize user;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [txtEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [Util setCornerView:btnNext];
    if (![Util isConnectableInternet]){
        [self showErrorMsg:LOCALIZATION(@"network_error")];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [dataArray addObject:owner.username];
            }
        }
    }];
}

-(void)textFieldDidChange :(UITextField *) textField{
    txtEmail.text = [Util trim:txtEmail.text.lowercaseString];
    NSString *email = txtEmail.text;
    btnValid.selected = [email isEmail];
    if (![email isEmail]){
        btnRegister.selected = NO;
        btnNext.enabled = NO;
        return;
    }
    if ([email containsString:@".."]){
        btnValid.selected = NO;
        btnRegister.selected = NO;
        btnNext.enabled = NO;
        return;
    }
    if ([dataArray containsObject:email]){
        btnRegister.selected = NO;
        btnNext.enabled = NO;
    } else if ([email isEmail]){
        btnRegister.selected = YES;
        btnNext.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    txtEmail.placeholder = LOCALIZATION(@"enter_email");
    lblNotuse.text = LOCALIZATION(@"not_use");
    lblValid.text = LOCALIZATION(@"valid_email");
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    user[PARSE_USER_EMAIL] = txtEmail.text;
    user.username = txtEmail.text;
    SignUpTwoViewController *vc = (SignUpTwoViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpTwoViewController"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if (email.length == 0){
        return NO;
    }
    if (![email isEmail]){
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
