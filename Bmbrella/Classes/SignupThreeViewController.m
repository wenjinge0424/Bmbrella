//
//  SignupThreeViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SignupThreeViewController.h"
#import "SignUpFourViewController.h"
#import "SignUpFourBusinessViewController.h"

@interface SignupThreeViewController ()
{
    IBOutlet UITextField *txtRepassword;
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIButton *btnMatch;
    IBOutlet UILabel *lblMatch;
    IBOutlet UIButton *btnNext;
}
@end

@implementation SignupThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [txtRepassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    txtRepassword.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblTitle.text = LOCALIZATION(@"sign_up");
    txtRepassword.placeholder = LOCALIZATION(@"re_enter_pwd");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    lblMatch.text = LOCALIZATION(@"pwd_five");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onNext:(id)sender {
    int type = [self.user[PARSE_USER_TYPE] intValue];
    if (type == USER_TYPE_CUSTOMER){
        SignUpFourViewController *vc = (SignUpFourViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFourViewController"];
        vc.user = self.user;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == USER_TYPE_BUSINESS){
        SignUpFourBusinessViewController *vc = (SignUpFourBusinessViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFourBusinessViewController"];
        vc.user = self.user;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidChange :(UITextField *) textField{
    btnMatch.selected = [self.user[PARSE_USER_PASSWORD] isEqualToString:txtRepassword.text];
    btnNext.enabled = btnMatch.selected;
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
