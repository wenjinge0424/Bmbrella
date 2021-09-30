//
//  AllNotifyViewController.m
//  Bmbrella
//
//  Created by Techsviewer on 8/9/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "AllNotifyViewController.h"
#import "CircleImageView.h"
#import "PostDetailViewController.h"

@interface AllNotifyViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIImageView *imgBackground;
    IBOutlet UITableView *tableview;
    
    IBOutlet UILabel *lblNoResult;
    
    NSMutableArray *dataArray;
}

@end

@implementation AllNotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    
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
    
    [self refreshItems];
}
- (void) refreshItems {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [query whereKey:PARSE_NOTIFICATION_TO equalTo:[PFUser currentUser]];
//    [query whereKey:PARSE_NOTIFICATION_ISREAD equalTo:@NO];
    [query includeKey:PARSE_NOTIFICATION_FROM];
    [query includeKey:PARSE_NOTIFICATION_LINK];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)array;
            for(PFObject * obj in dataArray){
                BOOL isRead = [obj[PARSE_NOTIFICATION_ISREAD] boolValue];
                if(!isRead){
                    obj[PARSE_NOTIFICATION_ISREAD] = [NSNumber numberWithBool:YES];
                    [obj saveInBackground];
                }
            }
            lblNoResult.hidden = !(dataArray.count == 0);
            [tableview reloadData];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    PFUser *user = object[PARSE_NOTIFICATION_FROM];
    
    NSString *fullName = @"";
    if ([user[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
        fullName = user[PARSE_USER_FULL_NAME];
    } else {
        fullName = user[PARSE_USER_COMPANY_NAME];
    }
    
    CircleImageView *imgAvatar = (CircleImageView *)[cell viewWithTag:1];
    UILabel *lblName = (UILabel *)[cell viewWithTag:2];
    UILabel *lblTime = (UILabel *)[cell viewWithTag:20];
    
    NSString * alertString = fullName;
    int notifyType = [object[PARSE_NOTIFICATION_TYPE] intValue];
    if(notifyType == SYSTEM_NOTIFICATION_TYPE_COMMENT){
        alertString = [alertString stringByAppendingFormat:@" add comment to your post."];
    }else if(notifyType == SYSTEM_NOTIFICATION_TYPE_LIKE){
        alertString = [alertString stringByAppendingFormat:@" like your post."];
    }
    lblName.text = alertString;
    lblTime.text = [Util convertDate2String:object.updatedAt];
    [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"");
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFObject *notify = [dataArray objectAtIndex:indexPath.row];
    [notify deleteInBackgroundWithBlock:^(BOOL success, NSError* error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            [self refreshItems];
        }
    }];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PostDetailViewController *vc = (PostDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"PostDetailViewController"];
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    vc.object = object[PARSE_NOTIFICATION_LINK];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
