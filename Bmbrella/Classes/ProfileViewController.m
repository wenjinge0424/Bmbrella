//
//  ProfileViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "ChatUsersViewController.h"
#import "ChatViewController.h"
#import "FriendsListViewController.h"
#import "CircleImageView.h"
#import "PostDetailViewController.h"
#import "FeedCell.h"
#import "FlagViewController.h"
#import "RootViewController.h"

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource, FeedCellDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet CircleImageView *imgAvatar;
    
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lbltitle;
    IBOutlet UILabel *lblEducation;
    IBOutlet UILabel *lblJob;
    IBOutlet UILabel *lblDescription;
    IBOutlet UILabel *lblFriends;
    __weak IBOutlet UITextView *txt_description;
    
    IBOutlet UIButton *btnMessages;
    IBOutlet UIButton *btnAddFriend;
    IBOutlet UILabel *lblCntFriends;
    
    BOOL isMe;
    IBOutlet UIButton *btnAction;
    
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
    
    NSInteger rowCount;
    IBOutlet UIButton *btnCall;
    IBOutlet UIButton *btnDirection;
    IBOutlet UILabel *lblFollowing;
    IBOutlet UILabel *lblFollowers;
    IBOutlet UIImageView *imgBackground;
    
}
@end

@implementation ProfileViewController
@synthesize user;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataArray = [[NSMutableArray alloc] init];
    rowCount = 0;
    if (!user){
        user = [PFUser currentUser];
        btnAddFriend.hidden = YES;
        isMe = YES;
        [btnAction setImage:[UIImage imageNamed:@"ic_settings"] forState:UIControlStateNormal];
//        btnCall.enabled = NO;
//        btnCall.enabled = NO;
    } else {
        isMe = NO;
        [btnAction setImage:[UIImage imageNamed:@"ic_flag"] forState:UIControlStateNormal];
        
    }
    [Util setBorderView:imgAvatar color:[UIColor whiteColor] width:1.0];
    
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
    
    [self initData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configLanguage];
    
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if ([self isFriend]){
//        btnAddFriend.enabled = NO;
        [btnAddFriend setImage:[UIImage imageNamed:@"btn_remove_friend"] forState:UIControlStateNormal];
    } else {
        [btnAddFriend setImage:[UIImage imageNamed:@"btn_add_friend"] forState:UIControlStateNormal];
    }
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [SVProgressHUD dismiss];
        user = (PFUser *) object;
        [self initData];
    }];
}

- (void) configLanguage {
    lblFriends.text = LOCALIZATION(@"friends");
    [btnCall setTitle:LOCALIZATION(@"call") forState:UIControlStateNormal];
    [btnDirection setTitle:LOCALIZATION(@"direction") forState:UIControlStateNormal];

}

- (IBAction)onDirection:(id)sender {
    PFUser *me = [PFUser currentUser];
//    if ([me.objectId isEqualToString:user.objectId]){
//        return;
//    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            PFGeoPoint *target = user[PARSE_USER_LOCATION];
            
            NSString *string = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%1.6f,%1.6f&saddr=%1.6f,%1.6f", target.latitude, target.longitude, geoPoint.latitude, geoPoint.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
        }
    }];
}

- (IBAction)onCallPhone:(id)sender {
    if (user[PARSE_USER_PHONE_NUMBER]){
        NSString *phone = [NSString stringWithFormat:@"tel://%@", user[PARSE_USER_PHONE_NUMBER]];
        NSURL *url = [NSURL URLWithString:phone];
        if ([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [self showErrorMsg:@"You cannot make call on this device."];
        }
    }else{
        [self showErrorMsg:@"This user don't regist phone number yet."];
    }
}

- (IBAction)onMap:(id)sender {
    NSInteger type = [user[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        return;
    }
    PFGeoPoint *geoPoint = user[PARSE_USER_LOCATION];
    double lat = geoPoint.latitude;
    double lon = geoPoint.longitude;
    NSString *string = [NSString stringWithFormat:@"http://maps.google.com/maps?ll=%f,%f", lat, lon];
    NSURL *url = [NSURL URLWithString:string];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    } else {
        [self showErrorMsg:@"You cannot open map on this device"];
    }
}

- (void) initData {
    NSInteger type = [user[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        lblName.text = user[PARSE_USER_FULL_NAME];
    } else {
        lblName.text = user[PARSE_USER_COMPANY_NAME];
//        if (user[PARSE_USER_PHONE_NUMBER]){
//            lblName.text = [NSString stringWithFormat:@"%@\n%@", user[PARSE_USER_COMPANY_NAME], user[PARSE_USER_PHONE_NUMBER]];
//        }
    }
    
    lbltitle.text = user[PARSE_USER_TITLE];
//    lblDescription.text = user[PARSE_USER_DESCRIPTION];
    txt_description.text = user[PARSE_USER_DESCRIPTION];
    txt_description.dataDetectorTypes = UIDataDetectorTypeNone;
    txt_description.dataDetectorTypes = UIDataDetectorTypeLink;
    
//    NSInteger education = [user[PARSE_USER_EDUCATION] integerValue];
//    if (education != -1){
//        lblEducation.text = [EDUCATION_ATTAINMENT objectAtIndex:[user[PARSE_USER_EDUCATION] integerValue]];
//        
//        if (type == USER_TYPE_BUSINESS){
//            lblEducation.text = [NSString stringWithFormat:@"%@", user[PARSE_USER_ADDRESS]];
//        }
//    }
    [Util setImage:imgAvatar imgFile:user[PARSE_USER_AVATAR]];
    if (user[PARSE_USER_YEARS]){
        NSMutableArray *years = user[PARSE_USER_YEARS];
        NSMutableArray *jobs = user[PARSE_USER_POSITION];
        NSString *jobsString = @"";
        if (years.count > 0){
            jobsString = [NSString stringWithFormat:@"%@-%@", jobs[0], years[0]];
            for (int i=1;i<years.count;i++){
                jobsString = [NSString stringWithFormat:@"%@,%@-%@", jobsString, jobs[i], years[i]];
            }
        }
//        lblJob.text = [NSString stringWithFormat:@"%@ %@", LOCALIZATION(@"job_position"), yearsString];
        lblJob.text = jobsString;
    }
    if (user[PARSE_USER_FRIEND_LIST]){
        NSMutableArray *friends = user[PARSE_USER_FRIEND_LIST];
//        lblCntFriends.text =
        lblFollowers.text = [NSString stringWithFormat:@"Followers(%ld)", (unsigned long)friends.count];
    } else {
//        lblCntFriends.text = [NSString stringWithFormat:@"(%d)", 0];
        lblFollowers.text = [NSString stringWithFormat:@"Followers(%ld)", (unsigned long)0];
    }
    
    [self refreshItems];
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:PARSE_USER_FRIEND_LIST equalTo:self.user];
    [userQuery setLimit:1000];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            lblFollowing.text = [NSString stringWithFormat:@"Following(%lu)", (unsigned long)results.count];
            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_POST];
            [query whereKey:PARSE_POST_OWNER equalTo:self.user];
            [query orderByDescending:PARSE_FIELD_CREATED_AT];
            [query includeKey:PARSE_POST_OWNER];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                [SVProgressHUD dismiss];
                if (error){
                    [self showErrorMsg:[error localizedDescription]];
                } else {
                    dataArray = (NSMutableArray *) array;
                }
                [tableview reloadData];
            }];
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

- (IBAction)onSettings:(id)sender {
    if (isMe){
        [[RootViewController getInstance] setCurrentTab:TAB_SETTING];
    } else { // report
        PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_REPORT];
        obj[PARSE_REPORT_REPORTER] = [PFUser currentUser];
        obj[PARSE_REPORT_OWNER] = self.user;
        obj[PARSE_REPORT_TYPE] = [NSNumber numberWithInteger:REPORT_TYPE_USER];
        FlagViewController *vc = (FlagViewController *)[Util getUIViewControllerFromStoryBoard:@"FlagViewController"];
        vc.object = obj;
        [self.navigationController pushViewController:vc animated:YES];
        
        
//        NSString *msg = LOCALIZATION(@"confirm_report_user");
//        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//        alert.customViewColor = MAIN_COLOR;
//        alert.horizontalButtons = YES;
//        [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
//            if (![Util isConnectableInternet]){
//                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
//                return;
//            }
//            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REPORT];
//            [query whereKey:PARSE_REPORT_TYPE equalTo:[NSNumber numberWithInteger:REPORT_TYPE_USER]];
//            [query whereKey:PARSE_REPORT_REPORTER equalTo:[PFUser currentUser]];
//            [query whereKey:PARSE_REPORT_OWNER equalTo:self.user];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *err){
//                if (err){
//                    [SVProgressHUD dismiss];
//                    [self showErrorMsg:[err localizedDescription]];
//                } else {
//                    if (array.count>0){
//                        [SVProgressHUD dismiss];
//                        [self showErrorMsg:LOCALIZATION(@"already_reported_user")];
//                    } else {
//                        PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_REPORT];
//                        obj[PARSE_REPORT_REPORTER] = [PFUser currentUser];
//                        obj[PARSE_REPORT_OWNER] = self.user;
//                        obj[PARSE_REPORT_TYPE] = [NSNumber numberWithInteger:REPORT_TYPE_USER];
//                        [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
//                            [SVProgressHUD dismiss];
//                            if (error){
//                                [self showErrorMsg:[error localizedDescription]];
//                            } else {
//                                [Util showAlertTitle:self title:LOCALIZATION(@"report_user") message:LOCALIZATION(@"success")];
//                            }
//                        }];
//                    }
//                }
//            }];
//        }];
//        [alert addButton:LOCALIZATION(@"no") actionBlock:^(void) {
//            
//        }];
//        [alert showQuestion:LOCALIZATION(@"warning") subTitle:msg closeButtonTitle:nil duration:0.0f];
    }
}

- (IBAction)onMessages:(id)sender {
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]){
//        ChatUsersViewController *vc = (ChatUsersViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatUsersViewController"];
//        [self.navigationController pushViewController:vc animated:YES];
        [[RootViewController getInstance] setCurrentTab:TAB_CHAT];
        
    } else {
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
        vc.toUser = user;
        PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query1 whereKey:PARSE_ROOM_SENDER equalTo:[PFUser currentUser]];
        [query1 whereKey:PARSE_ROOM_RECEIVER equalTo:user];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:[PFUser currentUser]];
        [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:user];
        
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        [queries addObject:query1];
        [queries addObject:query2];
        PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
//        [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
        [query includeKey:PARSE_ROOM_RECEIVER];
        [query includeKey:PARSE_ROOM_SENDER];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
//            if (error && object == nil){
//                [SVProgressHUD dismiss];
//                [self showErrorMsg:[error localizedDescription]];
//                return;
//            }
            if (object){
                if (![object[PARSE_ROOM_ENABLED] boolValue]){
                    object[PARSE_ROOM_ENABLED] = @YES;
                    [object saveInBackground];
                }
                [SVProgressHUD dismiss];
                vc.room = object;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
                obj[PARSE_ROOM_SENDER] = [PFUser currentUser];
                obj[PARSE_ROOM_RECEIVER] = user;
                obj[PARSE_ROOM_ENABLED] = @YES;
                obj[PARSE_ROOM_LAST_MESSAGE] = @"";
                obj[PARSE_ROOM_IS_READ] = @YES;
                [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *err){
                    [SVProgressHUD dismiss];
                    vc.room = obj;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
            }
        }];
    }
    
}

- (void) unFollow {
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
        PFUser *me = [PFUser currentUser];
        NSMutableArray *friends = me[PARSE_USER_FRIEND_LIST];
        int index = -1;
        for (int i=0;i<friends.count;i++){
            PFUser *friend = friends[i];
            if ([friend.objectId isEqualToString:user.objectId]){
                index = i;
            }
        }
        if (index != -1){
            [friends removeObjectAtIndex:index];
        }
        me[PARSE_USER_FRIEND_LIST] = friends;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            if (succeed){
                // Send Push
                NSString *fullName = @"";
                if ([me[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
                    fullName = me[PARSE_USER_FULL_NAME];
                } else {
                    fullName = me[PARSE_USER_COMPANY_NAME];
                }
                NSString *pushMsg = [NSString stringWithFormat:@"%@ unfollowed you.", fullName];
                NSDictionary *data = @{
                                       @"alert" : pushMsg,
                                       @"badge" : @"Increment",
                                       @"sound" : @"cheering.caf",
                                       @"email" : user.username,
                                       @"data"  : user.objectId,
                                       @"type"  : [NSNumber numberWithInt:PUSH_TYPE_UNFOLLOW],
                                       };
                [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                    if (err) {
                        NSLog(@"Fail APNS: %@", @"send ban push");
                    } else {
                        NSLog(@"Success APNS: %@", @"send ban push");
                    }
                }];
                
                PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
                [query1 whereKey:PARSE_FOLLOW_TO equalTo:[PFUser currentUser]];
                [query1 whereKey:PARSE_FOLLOW_FROM equalTo:user];
                
                PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
                [query2 whereKey:PARSE_FOLLOW_FROM equalTo:[PFUser currentUser]];
                [query2 whereKey:PARSE_FOLLOW_TO equalTo:user];
                
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query1, query2, nil]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                    [SVProgressHUD dismiss];
                    if (error){
                        [self showErrorMsg:[error localizedDescription]];
                    } else {
                        NSMutableArray *saveAllOfMe = [NSMutableArray new];
                        for (PFObject *object in array) {
                            object[PARSE_FOLLOW_ACTIVE] = @NO;
                            [saveAllOfMe addObject:object];
                        }
                        [PFObject saveAllInBackground:saveAllOfMe block:^(BOOL success, NSError *error) {
                            // Check result of the operation, all objects should have been saved by now
                        }];
                        [self onback:nil];
                    }
                }];
            } else {
                [SVProgressHUD dismiss];
                [self showErrorMsg:[error localizedDescription]];
            }
        }];
    }];
    [alert addButton:LOCALIZATION(@"no") actionBlock:^(void) {
        
    }];
    [alert showError:@"Hello" subTitle:LOCALIZATION(@"confirm_unfollow") closeButtonTitle:nil duration:0.0f];
}

- (IBAction)onAddFriend:(id)sender {
    if ([self isFriend]){
        [self unFollow];
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    PFUser *me = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query whereKey:PARSE_FOLLOW_FROM equalTo:me];
    [query whereKey:PARSE_FOLLOW_TO equalTo:self.user];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        } else {
            if (array.count > 0){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:LOCALIZATION(@"success") message:LOCALIZATION(@"sent_follow_request")];
            } else {
                PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_FOLLOW];
                object[PARSE_FOLLOW_FROM] = [PFUser currentUser];
                object[PARSE_FOLLOW_TO] = self.user;
                object[PARSE_FOLLOW_ACTIVE] = @NO;
                
                [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *err){
                    [SVProgressHUD dismiss];
                    if (err){
                        [self showErrorMsg:[err localizedDescription]];
                    } else {
                        [Util showAlertTitle:self title:LOCALIZATION(@"success") message:LOCALIZATION(@"sent_follow_request")];
                        
                        // Send Push
                        NSString *fullName = @"";
                        if ([me[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
                            fullName = me[PARSE_USER_FULL_NAME];
                        } else {
                            fullName = me[PARSE_USER_COMPANY_NAME];
                        }
                        NSString *pushMsg = [NSString stringWithFormat:@"%@ sent you 'Follow' request.", fullName];
                        NSDictionary *data = @{
                                               @"alert" : pushMsg,
                                               @"badge" : @"Increment",
                                               @"sound" : @"cheering.caf",
                                               @"email" : self.user.username,
                                               @"type"  : [NSNumber numberWithInt:PUSH_TYPE_FOLLOW_REQUEST],
                                               };
                        [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                            if (err) {
                                NSLog(@"Fail APNS: %@", @"send ban push");
                            } else {
                                NSLog(@"Success APNS: %@", @"send ban push");
                            }
                        }];
                    }
                }];
            }
        }
    }];
    
//    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
//            [PFUser currentUser].objectId, @"fromId",
//            self.user.objectId, @"toId",
//            @YES, @"isConnected",
//            nil];
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//    [PFCloud callFunctionInBackground:@"setConnection" withParameters:data block:^(id object, NSError *err) {
//        if (err) {
//            [SVProgressHUD dismiss];
//            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[err localizedDescription] finish:nil];
//        } else {
//            btnAddFriend.enabled = NO;
//            [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *err){
//                user = (PFUser *) object;
//                [SVProgressHUD dismiss];
//                [Util showAlertTitle:self title:LOCALIZATION(@"add_friend") message:LOCALIZATION(@"success") finish:^(void){
//                    [self initData];
//                }];
//            }];
//        }
//    }];
}

- (BOOL) isFriend {
    PFUser *me = [PFUser currentUser];
    me = [me fetchIfNeeded];
    NSMutableArray *friends = me[PARSE_USER_FRIEND_LIST];
    for (int i=0;i<friends.count;i++){
        PFUser *friend = friends[i];
        if ([friend.objectId isEqualToString:user.objectId]){
            return YES;
        }
    }
    return NO;
}

- (IBAction)onFriends:(id)sender {
    FriendsListViewController *vc = (FriendsListViewController *)[Util getUIViewControllerFromStoryBoard:@"FriendsListViewController"];
    vc.isFollowing = NO;
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onFollowing:(id)sender
{
    FriendsListViewController *vc = (FriendsListViewController *)[Util getUIViewControllerFromStoryBoard:@"FriendsListViewController"];
    vc.isFollowing = YES;
    vc.user = self.user;
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger div = (NSInteger)(dataArray.count / 8);
    NSInteger remain = dataArray.count - 8 * div;
    if (remain == 0){
        rowCount = div;
        return div;
    } else {
        rowCount = div + 1;
    }
    return rowCount;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == rowCount - 1){
        NSInteger div = (NSInteger)(dataArray.count / 8);
        NSInteger remain = dataArray.count - 8 * div;
        if (remain == 0){
            return 900;
        } else if (remain == 1 || remain == 2){
            return 300;
        } else if (remain == 3 || remain == 4 || remain == 5){
            return 200 + 300;
        } else {
            return 900;
        }
    }
    return 900;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:@"cellPost"];
    cell.delegate = self;
    UIImageView *imgOne = (UIImageView *)[cell viewWithTag:1];
    UIImageView *imgTwo = (UIImageView *)[cell viewWithTag:2];
    UIImageView *imgThree = (UIImageView *)[cell viewWithTag:3];
    UIImageView *imgFour = (UIImageView *)[cell viewWithTag:4];
    UIImageView *imgFive = (UIImageView *)[cell viewWithTag:5];
    UIImageView *imgSix = (UIImageView *)[cell viewWithTag:6];
    UIImageView *imgSeven = (UIImageView *)[cell viewWithTag:7];
    UIImageView *imgEight = (UIImageView *)[cell viewWithTag:8];
    CircleImageView *imgAvatarOne = (CircleImageView *)[cell viewWithTag:401];
    UILabel *lblNameOne = (UILabel *)[cell viewWithTag:501];
    CircleImageView *imgAvatarTwo = (CircleImageView *)[cell viewWithTag:402];
    UILabel *lblNameTwo = (UILabel *)[cell viewWithTag:502];
    CircleImageView *imgAvatarThree = (CircleImageView *)[cell viewWithTag:403];
    UILabel *lblNameThree = (UILabel *)[cell viewWithTag:503];
    CircleImageView *imgAvatarFour = (CircleImageView *)[cell viewWithTag:404];
    UILabel *lblNameFour = (UILabel *)[cell viewWithTag:504];
    CircleImageView *imgAvatarFive = (CircleImageView *)[cell viewWithTag:405];
    UILabel *lblNameFive = (UILabel *)[cell viewWithTag:505];
    CircleImageView *imgAvatarSix = (CircleImageView *)[cell viewWithTag:406];
    UILabel *lblNameSix = (UILabel *)[cell viewWithTag:506];
    CircleImageView *imgAvatarSeven = (CircleImageView *)[cell viewWithTag:407];
    UILabel *lblNameSeven = (UILabel *)[cell viewWithTag:507];
    CircleImageView *imgAvatarEight = (CircleImageView *)[cell viewWithTag:408];
    UILabel *lblNameEight = (UILabel *)[cell viewWithTag:508];
    
    UIImageView *btnPlayOne = (UIImageView *)[cell viewWithTag:601];
    UIImageView *btnPlayTwo = (UIImageView *)[cell viewWithTag:602];
    UIImageView *btnPlayThree = (UIImageView *)[cell viewWithTag:603];
    UIImageView *btnPlayFour = (UIImageView *)[cell viewWithTag:604];
    UIImageView *btnPlayFive = (UIImageView *)[cell viewWithTag:605];
    UIImageView *btnPlaySix = (UIImageView *)[cell viewWithTag:606];
    UIImageView *btnPlaySeven = (UIImageView *)[cell viewWithTag:607];
    UIImageView *btnPlayEight = (UIImageView *)[cell viewWithTag:608];
    
    [Util setBorderView:imgOne color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgTwo color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgThree color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgFour color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgFive color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgSix color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgSeven color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgEight color:[UIColor whiteColor] width:1];
    
    NSInteger index = 8 * indexPath.row;
    [self setPostCell:index :imgOne :(UIImageView *)[cell viewWithTag:101] :(UIButton *)[cell viewWithTag:201] :imgAvatarOne :lblNameOne :btnPlayOne];
    [self setPostCell:index+1 :imgTwo :(UIImageView *)[cell viewWithTag:102] :(UIButton *)[cell viewWithTag:202] :imgAvatarTwo :lblNameTwo :btnPlayTwo];
    [self setPostCell:index+2 :imgThree :(UIImageView *)[cell viewWithTag:103] :(UIButton *)[cell viewWithTag:203]:imgAvatarThree :lblNameThree :btnPlayThree];
    [self setPostCell:index+3 :imgFour :(UIImageView *)[cell viewWithTag:104] :(UIButton *)[cell viewWithTag:204]:imgAvatarFour :lblNameFour :btnPlayFour];
    [self setPostCell:index+4 :imgFive :(UIImageView *)[cell viewWithTag:105] :(UIButton *)[cell viewWithTag:205]:imgAvatarFive :lblNameFive :btnPlayFive];
    [self setPostCell:index+5 :imgSix :(UIImageView *)[cell viewWithTag:106] :(UIButton *)[cell viewWithTag:206]:imgAvatarSix :lblNameSix :btnPlaySix];
    [self setPostCell:index+6 :imgSeven :(UIImageView *)[cell viewWithTag:107] :(UIButton *)[cell viewWithTag:207]:imgAvatarSeven :lblNameSeven :btnPlaySeven];
    [self setPostCell:index+7 :imgEight :(UIImageView *)[cell viewWithTag:108] :(UIButton *)[cell viewWithTag:208]:imgAvatarEight :lblNameEight :btnPlayEight];
    
    return cell;
}

- (void) setPostCell:(NSInteger) index :(UIImageView *) imageView :(UIImageView *) shadow :(UIButton *)shareButton :(CircleImageView *) imgAvatar :(UILabel *) lblName :(UIImageView *)btnPlay{
    imageView.image = nil;
    [imgAvatar setHidden:YES];
    [lblName setHidden:YES];
    if (dataArray.count == 1 && index == 0){
        PFObject *post = dataArray[index];
        PFObject *user = post[PARSE_POST_OWNER];
        [Util setImage:imageView imgFile:(PFFile *) post[PARSE_POST_IMAGE]];
        [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
        BOOL isVideo = [post[PARSE_POST_IS_VIDEO] boolValue];
        btnPlay.hidden = !isVideo;
        NSInteger type = [user[PARSE_USER_TYPE] integerValue];
        if (type == USER_TYPE_BUSINESS)
            lblName.text = user[PARSE_USER_COMPANY_NAME];
        else
            lblName.text = user[PARSE_USER_FULL_NAME];
        shadow.hidden = NO;
        shareButton.hidden = NO;
        imgAvatar.hidden = NO;
        lblName.hidden = NO;
        return;
    }
    if (index > dataArray.count - 1){
        shadow.hidden = YES;
        shareButton.hidden = YES;
        [Util setBorderView:imageView color:[UIColor clearColor] width:0.5];
        imgAvatar.hidden = YES;
        lblName.hidden = YES;
        btnPlay.hidden = YES;
        return;
    }
    if (dataArray[index]){
        PFObject *post = dataArray[index];
        PFObject *user = post[PARSE_POST_OWNER];
        [Util setImage:imageView imgFile:(PFFile *) post[PARSE_POST_IMAGE]];
        [imgAvatar setHidden:YES];
//        [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
        BOOL isVideo = [post[PARSE_POST_IS_VIDEO] boolValue];
        btnPlay.hidden = !isVideo;
        NSInteger type = [user[PARSE_USER_TYPE] integerValue];
        if (type == USER_TYPE_BUSINESS)
            lblName.text = user[PARSE_USER_COMPANY_NAME];
        else
            lblName.text = user[PARSE_USER_FULL_NAME];
        [lblName setHidden:YES];
        
        shadow.hidden = NO;
        shareButton.hidden = NO;
        imgAvatar.hidden = NO;
        lblName.hidden = NO;
    } else {
        shadow.hidden = YES;
        shareButton.hidden = YES;
        [Util setBorderView:imageView color:[UIColor clearColor] width:0.5];
        imgAvatar.hidden = YES;
        lblName.hidden = YES;
        btnPlay.hidden = YES;
    }
}

- (void) gotoPostDetailScene:(NSInteger )index{
    if (index > dataArray.count - 1){
        return;
    }
    if (dataArray[index]){
        PFObject *post = dataArray[index];
        PostDetailViewController *vc = (PostDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"PostDetailViewController"];
        vc.object = post;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma FeedCellDelegate
- (void) onTapImageOne:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:index];
    
}

- (void) onTapImageTwo:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+1)];
}

- (void) onTapImageThree:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    if (dataArray.count < 2){  // I dont know this reason for the first image
        [self gotoPostDetailScene:index];
    } else {
        if (index + 2 > dataArray.count){ // I dont know this reason too for the last image
            [self gotoPostDetailScene:(dataArray.count-1)];
        } else {
            [self gotoPostDetailScene:(index+2)];
        }
    }
}

- (void) onTapImageFour:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+3)];
}

- (void) onTapImageFive:(FeedCell *)cell {
    
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    if (dataArray.count < 3){
        if (dataArray.count == 2){
            [self gotoPostDetailScene:index];
        } else {
            [self gotoPostDetailScene:(index+2)];
        }
    } else if (index + 2 == dataArray.count){
        [self gotoPostDetailScene:(index+1)];
    } else{
        [self gotoPostDetailScene:(index+4)];
    }
}

- (void) onTapImageSix:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+5)];
}

- (void) onTapImageSeven:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+6)];
}

- (void) onTapImageEight:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+7)];
}

- (void) onShareImageOne:(FeedCell *)cell {}
- (void) onShareImageTwo:(FeedCell *)cell {}
- (void) onShareImageThree:(FeedCell *)cell {}
- (void) onShareImageFour:(FeedCell *)cell {}
- (void) onShareImageFive:(FeedCell *)cell {}
- (void) onShareImageSix:(FeedCell *)cell {}
- (void) onShareImageSeven:(FeedCell *)cell {}
@end
