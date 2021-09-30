//
//  SignUpFiveViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SignUpFiveViewController.h"
#import "IQDropDownTextField.h"
#import "MainViewController.h"
#import "RootViewController.h"

@interface SignUpFiveViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet IQDropDownTextField *txtAttainment;
    IBOutlet UITableView *tableview;
    NSInteger counts;
    NSMutableArray *dateItems;
}
@end

@implementation SignUpFiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtAttainment.itemList = EDUCATION_ATTAINMENT;
    counts = 1;
    
    dateItems = [[NSMutableArray alloc] init];
    for (int year = 0;year<51;year++){
        NSString *itemYear = @"";
        if (year == 0){
            itemYear = @"";
        } else if (year == 1){
            itemYear = [NSString stringWithFormat:@"%d Year", year];
        } else {
            itemYear = [NSString stringWithFormat:@"%d Years", year];
        }
        for (int month = 0;month<12;month++){
            NSString *item = itemYear;
            if (month == 0){
                
            } else if (month == 1){
                item = [NSString stringWithFormat:@"%@ %d Month", itemYear, month];
            } else {
                item = [NSString stringWithFormat:@"%@ %d Months", itemYear, month];
            }
            if (item.length>0)
                [dateItems addObject:item];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCreate:(id)sender {
    if (![self isValid]){
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    NSMutableArray *positionArray = [[NSMutableArray alloc] init];
    NSMutableArray *companyArray = [[NSMutableArray alloc] init];
    NSMutableArray *yearsArray = [[NSMutableArray alloc] init];
    for (NSInteger i=0;i<counts;i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
        UITextField *txtPosition = (UITextField *)[cell viewWithTag:1];
        UITextField *txtCompany = (UITextField *)[cell viewWithTag:2];
        IQDropDownTextField *txtYear = (IQDropDownTextField *)[cell viewWithTag:3];
        txtPosition.text = [Util trim:txtPosition.text];
        txtCompany.text = [Util trim:txtCompany.text];
        if (txtPosition.text.length == 0 || txtCompany.text.length == 0 || txtYear.selectedRow == -1 || txtPosition.text.length > 50 || (txtPosition.text.length>0 && txtCompany.text.length == 0) || (txtPosition.text.length>0 && txtYear.selectedRow == -1)||txtCompany.text.length > 50){
            continue;
        }
        [positionArray addObject:txtPosition.text];
        [companyArray addObject:txtCompany.text];
        [yearsArray addObject:txtYear.selectedItem];
    }
    self.user[PARSE_USER_EDUCATION] = [NSNumber numberWithInteger:txtAttainment.selectedRow];
    self.user[PARSE_USER_POSITION] = positionArray;
    self.user[PARSE_USER_JOB_COMPANY] = companyArray;
    self.user[PARSE_USER_IS_BANNED] = @NO;
    self.user[PARSE_USER_YEARS] = yearsArray;
    self.user[PARSE_USER_FRIEND_LIST] = [NSMutableArray new];
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util setLoginUserName:self.user[PARSE_USER_EMAIL] password:self.user[PARSE_USER_PASSWORD]];
            NSString *message = LOCALIZATION(@"success_sign_up");
            [Util showAlertTitle:self title:LOCALIZATION(@"success") message:message finish:^(void){
                RootViewController *vc = (RootViewController *)[Util getUIViewControllerFromStoryBoard:@"RootViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            NSString *errMsg = [error localizedDescription];
            if ([errMsg containsString:@"already exist"]){
                [self showErrorMsg:@"Account already exists for this email."];
            } else {
                [self showErrorMsg:errMsg];
            }
        }
    }];
}

- (IBAction)onSkip:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    self.user[PARSE_USER_EDUCATION] = [NSNumber numberWithInteger:-1];
    self.user[PARSE_USER_POSITION] = [NSMutableArray new];
    self.user[PARSE_USER_JOB_COMPANY] = [NSMutableArray new];
    self.user[PARSE_USER_YEARS] = [NSMutableArray new];
    self.user[PARSE_USER_FRIEND_LIST] = [NSMutableArray new];
    self.user[PARSE_USER_IS_BANNED] = @NO;
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util setLoginUserName:self.user[PARSE_USER_EMAIL] password:self.user[PARSE_USER_PASSWORD]];
            NSString *message = LOCALIZATION(@"success_sign_up");
            [Util showAlertTitle:self title:LOCALIZATION(@"success") message:message finish:^(void){
                RootViewController *vc = (RootViewController *)[Util getUIViewControllerFromStoryBoard:@"RootViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            [self showErrorMsg:[error localizedDescription]];
        }
    }];
}

- (IBAction)onAddmore:(id)sender {
    NSInteger count = [tableview numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
    [tableview beginUpdates];
    [tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cellAddFood"];
    UITextField *txtPosition = (UITextField *)[cell viewWithTag:1];
    UITextField *txtCompany = (UITextField *)[cell viewWithTag:2];
    IQDropDownTextField *txtYear = (IQDropDownTextField *)[cell viewWithTag:3];
    txtPosition.text = @"";
    txtCompany.text = @"";
    txtYear.selectedRow = -1;
    
    counts++;
    [tableview endUpdates];
}

- (BOOL) isValid {
    if (txtAttainment.selectedRow == -1){
        return NO;
    }
    return YES;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellJob"];
    UITextField *txtPosition = (UITextField *)[cell viewWithTag:1];
    UITextField *txtCompany = (UITextField *)[cell viewWithTag:2];
    IQDropDownTextField *txtYear = (IQDropDownTextField *)[cell viewWithTag:3];
    txtYear.itemList = dateItems;
    return cell;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return counts;
}
@end
