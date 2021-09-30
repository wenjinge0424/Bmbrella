//
//  ReportedUsersViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "ReportedUsersViewController.h"
#import "ReportedUserDetailViewController.h"

@interface ReportedUsersViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
}
@end

@implementation ReportedUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REPORT];
    [query whereKey:PARSE_REPORT_TYPE equalTo:[NSNumber numberWithInteger:REPORT_TYPE_USER]];
    [query includeKey:PARSE_REPORT_OWNER];
    [query includeKey:PARSE_REPORT_REPORTER];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) array;
            [tableview reloadData];
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    UILabel *lblUser = (UILabel *)[cell viewWithTag:1];
    PFObject *obj = [dataArray objectAtIndex:indexPath.row];
    PFUser *owner = obj[PARSE_REPORT_OWNER];
    NSInteger type = [owner[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        lblUser.text = owner[PARSE_USER_FULL_NAME];
    } else {
        lblUser.text = owner[PARSE_USER_COMPANY_NAME];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ReportedUserDetailViewController *vc = (ReportedUserDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"ReportedUserDetailViewController"];
    vc.object = [dataArray objectAtIndex:indexPath.row];
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
