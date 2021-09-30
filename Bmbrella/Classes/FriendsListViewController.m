//
//  FriendsListViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "FriendsListViewController.h"
#import "CircleImageView.h"
#import "ProfileViewController.h"

@interface FriendsListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    NSMutableArray *friendsArray;
    
    // all users
    NSMutableArray *userNameArray;
    NSMutableArray *allUsersArray;
    IBOutlet UITextField *textSearch;
    
    PFUser *me;
    IBOutlet UILabel *lblNodata;
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation FriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isFollowing){
        lblTitle.text = @"Following";
    }else{
        lblTitle.text = @"Followers";
    }
    
    [textSearch addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    lblNodata.hidden = YES;
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
    dataArray = [[NSMutableArray alloc] init];
    friendsArray = [[NSMutableArray alloc] init];
    userNameArray = [[NSMutableArray alloc] init];
    allUsersArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if (!self.user){
        self.user = me;
    }
    if (!self.isFollowing){
        [self.user fetchInBackgroundWithBlock:^(PFObject *obj, NSError *error){
            //        if (![SVProgressHUD isVisible])
            //            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            self.user = (PFUser *) obj;
            NSMutableArray *friends = obj[PARSE_USER_FRIEND_LIST];
            if (friends){
                for (PFUser *item in friends){
                    PFUser *friend = [item fetch];
                    [dataArray addObject:friend];
                    [friendsArray addObject:friend];
                }
            }
            PFQuery *query = [PFUser query];
            [query whereKey:PARSE_USER_TYPE notEqualTo:[NSNumber numberWithInteger:USER_TYPE_ADMIN]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (array){
                    lblNodata.hidden = (array.count != 0);
                    for (PFUser *userItem in array){
                        PFUser *user = [userItem fetchIfNeeded];
                        [allUsersArray addObject:user];
                        NSInteger type = [user[PARSE_USER_TYPE] integerValue];
                        if (type == USER_TYPE_CUSTOMER){
                            [userNameArray addObject:user[PARSE_USER_FULL_NAME]];
                        } else if (type == USER_TYPE_BUSINESS) {
                            [userNameArray addObject:user[PARSE_USER_COMPANY_NAME]];
                        }
                    }
                } else {
                }
                [SVProgressHUD dismiss];
                [tableview reloadData];
            }];
        }];
    } else {
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:PARSE_USER_FRIEND_LIST equalTo:self.user];
        [userQuery setLimit:1000];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
            if (error){
                [self showErrorMsg:[error localizedDescription]];
            } else {
                lblNodata.hidden = (results.count != 0);
                for (PFUser *userItem in results){
                    PFUser *user = [userItem fetchIfNeeded];
                    [allUsersArray addObject:user];
                    [dataArray addObject:user];
                    NSInteger type = [user[PARSE_USER_TYPE] integerValue];
                    if (type == USER_TYPE_CUSTOMER){
                        [userNameArray addObject:user[PARSE_USER_FULL_NAME]];
                    } else if (type == USER_TYPE_BUSINESS) {
                        [userNameArray addObject:user[PARSE_USER_COMPANY_NAME]];
                    }
                }
            }
            [SVProgressHUD dismiss];
            [tableview reloadData];
        }];
    }
    
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
    CircleImageView *imgAvatar = (CircleImageView *)[cell viewWithTag:1];
    UILabel *lblName = (UILabel *)[cell viewWithTag:2];
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:3];
    PFUser *target = [dataArray objectAtIndex:indexPath.row];
    [Util setImage:imgAvatar imgFile:(PFFile *)target[PARSE_USER_AVATAR]];
    NSInteger type = [target[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER)
        lblName.text = target[PARSE_USER_FULL_NAME];
    else
        lblName.text = target[PARSE_USER_COMPANY_NAME];
    lblTitle.text = target[PARSE_USER_TITLE];
    if (!target[PARSE_USER_TITLE]){
        lblTitle.text = target[PARSE_USER_DESCRIPTION];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *target = [dataArray objectAtIndex:indexPath.row];
//    ProfileViewController *vc = (ProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"ProfileViewController"];
//    vc.user = target;
//    [self.navigationController pushViewController:vc animated:YES];
    [self gotoProfileView:target];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)textFieldDidChange :(UITextField *) textField {
    NSString *text = textSearch.text;
    dataArray = [[NSMutableArray alloc] init];
    if (text.length == 0){
        for (int i=0;i<friendsArray.count;i++){
            [dataArray addObject:[friendsArray objectAtIndex:i]];
        }
        lblNodata.hidden = (dataArray.count != 0);
        [tableview reloadData];
        return;
    }
    for (int i=0;i<userNameArray.count;i++){
        NSString *name = [userNameArray objectAtIndex:i];
        if ([name containsString:text]){
            [dataArray addObject:[allUsersArray objectAtIndex:i]];
        }
    }
    lblNodata.hidden = (dataArray.count != 0);
    [tableview reloadData];
}

@end
