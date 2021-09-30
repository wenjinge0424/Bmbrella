//
//  FriendsViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "FriendsViewController.h"
#import "CircleImageView.h"
#import "PostDetailViewController.h"
#import "ProfileViewController.h"
#import "PostDetailViewController.h"

@interface FriendsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    PFUser *me;
    IBOutlet UILabel *lblNoResult;
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation FriendsViewController

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
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    me = [me fetch];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_POST];
    [query whereKey:PARSE_POST_OWNER containedIn:me[PARSE_USER_FRIEND_LIST]];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [query includeKey:PARSE_POST_OWNER];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) array;
            if (dataArray.count == 0){
                lblNoResult.hidden = NO;
            } else {
                lblNoResult.hidden = YES;
            }
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellFriend"];
    CircleImageView *imgAvatar = (CircleImageView *)[cell viewWithTag:1];
    UILabel *lblName = (UILabel *)[cell viewWithTag:2];
    UIImageView *imgPost = (UIImageView *)[cell viewWithTag:50];
    UILabel *lblTime = (UILabel *)[cell viewWithTag:3];
    
    UIButton *buttonPost = (UIButton *)[cell viewWithTag:100];
    UIButton *buttonUser = (UIButton *)[cell viewWithTag:200];
    UIImageView *btn_play = (UIImageView *)[cell viewWithTag:300];
    
    [buttonPost addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonUser addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    PFUser *owner = object[PARSE_POST_OWNER];
    NSInteger userType = [owner[PARSE_USER_TYPE] integerValue];
    if (userType == USER_TYPE_CUSTOMER)
        lblName.text = owner[PARSE_USER_FULL_NAME];
    else
        lblName.text = owner[PARSE_USER_COMPANY_NAME];
    [Util setImage:imgAvatar imgFile:(PFFile *)owner[PARSE_USER_AVATAR]];
    lblTime.text = [Util convertDate2String:object.createdAt];
    [Util setImage:imgPost imgFile:(PFFile *)object[PARSE_POST_IMAGE]];
    [Util setCornerView:imgPost];
    btn_play.hidden = ![object[PARSE_POST_IS_VIDEO] boolValue];
    
    return cell;
}

- (void)checkButtonTapped:(id)sender
{
    NSInteger tag = [sender tag];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableview];
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:buttonPosition];
    if (!indexPath){
        return;
    }
    if (tag == 100){ // Post
        PFObject *object = [dataArray objectAtIndex:indexPath.row];
        PostDetailViewController *vc = (PostDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"PostDetailViewController"];
        vc.object = object;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (tag == 200){ // User
//        ProfileViewController *vc = (ProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"ProfileViewController"];
        PFObject *object = [dataArray objectAtIndex:indexPath.row];
        PFUser *owner = object[PARSE_POST_OWNER];
//        vc.user = owner;
//        [self.navigationController pushViewController:vc animated:YES];
        [self gotoProfileView:owner];
    }
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
