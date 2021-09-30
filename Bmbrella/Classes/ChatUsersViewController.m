//
//  ChatUsersViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "ChatUsersViewController.h"
#import "CircleImageView.h"
#import "ProfileViewController.h"
#import "ChatViewController.h"
#import "RootViewController.h"
#import "ChatDetailsViewController.h"

ChatUsersViewController *_sharedViewController;
@interface ChatUsersViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
    IBOutlet UILabel *lblTitle;
    
    PFUser *me;
    IBOutlet UILabel *lblNoResult;
    IBOutlet UIImageView *imgBackground;
    
    NSMutableDictionary * unreadCounts;
    int calcIndex;
    
    BOOL needUpdateReadCount;
}
@end

@implementation ChatUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    me = [PFUser currentUser];
    
    _sharedViewController = self;
    
    needUpdateReadCount = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRoommsWithNotify:) name:kChatReceiveNotificationUsers object:nil];

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (ChatUsersViewController *)getInstance{
    return _sharedViewController;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[RootViewController getInstance] hideChatLabel];
    
    lblNoResult.text = LOCALIZATION(@"no_record");
    [self refreshRooms];
}
- (void) refreshRoommsWithNotify:(NSNotification *) notif
{
    if ([ChatDetailsViewController getInstance]){
        return;
    }
    [self refreshRooms];
}
- (void) refreshRooms {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    if (![SVProgressHUD isVisible])
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
    [query1 whereKey:PARSE_ROOM_SENDER equalTo:me];
    
    PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
    [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:me];
    
    NSMutableArray *queries = [[NSMutableArray alloc] init];
    [queries addObject:query1];
    [queries addObject:query2];
    PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
    [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
    [query includeKey:PARSE_ROOM_RECEIVER];
    [query includeKey:PARSE_ROOM_SENDER];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query whereKeyExists:PARSE_ROOM_LAST_MESSAGE];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        
        unreadCounts = [NSMutableDictionary new];
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) array;
            lblNoResult.hidden = !(dataArray.count == 0);
            calcIndex = 0;
            [self getUnreadCount:dataArray :calcIndex];
        }
    }];
}
- (void) getUnreadCount:(NSMutableArray *) roomArray :(int)index
{
    if(index >= roomArray.count){
        [SVProgressHUD dismiss];
        [tableview reloadData];
    }else{
        calcIndex = index;
        PFObject * rommDict = [roomArray objectAtIndex:index];
        PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_HISTORY];
        [query whereKey:PARSE_HISTORY_ROOM equalTo:rommDict];
        [query whereKey:PARSE_HISTORY_SENDER notEqualTo:[PFUser currentUser]];
        [query whereKey:PARSE_ROOM_IS_READ equalTo:[NSNumber numberWithBool:NO]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            if(array.count > 0){
                [unreadCounts setObject:[NSNumber numberWithInt:(int)array.count] forKey:rommDict.objectId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(needUpdateReadCount){
                    int totalUnreadCount = 0;
                    for(NSNumber * subDict  in unreadCounts.allValues){
                        totalUnreadCount += [subDict intValue];
                    }
                    [AppStateManager sharedInstance].msgCount = totalUnreadCount;
                    [[RootViewController getInstance] setChatCount:[AppStateManager sharedInstance].msgCount];
                }
                
                calcIndex ++;
                [self getUnreadCount:roomArray :calcIndex];
            });
        }];
    }
}

- (IBAction)onback:(id)sender {
    _sharedViewController = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNewChat:(id)sender {
    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return dataArray.count;
    return dataArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *room = [dataArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    CircleImageView *imgAvatar = (CircleImageView *)[cell viewWithTag:1];
    UIButton *btn_profile = (UIButton *)[cell viewWithTag:20];
    UIImageView *ic_dot = (UIImageView *)[cell viewWithTag:50];
    UILabel *lblName = (UILabel *)[cell viewWithTag:2];
    UILabel *lblMsg = (UILabel *)[cell viewWithTag:3];
    UILabel *lblDate = (UILabel *)[cell viewWithTag:4];
    UILabel * lblUnreadCount = (UILabel *)[cell viewWithTag:100];
    ic_dot.hidden = YES;
    lblUnreadCount.hidden = YES;
    
    [btn_profile addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    PFUser *sender = room[PARSE_ROOM_SENDER];
    PFUser *toUser;
    if ([sender.objectId isEqualToString:me.objectId]){
        toUser = room[PARSE_ROOM_RECEIVER];
    } else {
        sender = me;
        toUser = room[PARSE_ROOM_SENDER];
    }
    [Util setImage:imgAvatar imgFile:(PFFile *)toUser[PARSE_USER_AVATAR]];
    NSInteger userType = [toUser[PARSE_USER_TYPE] integerValue];
    if (userType == USER_TYPE_BUSINESS){
        lblName.text = toUser[PARSE_USER_COMPANY_NAME];
    } else {
        lblName.text = toUser[PARSE_USER_FULL_NAME];
    }
    
    if (room[PARSE_ROOM_LAST_MESSAGE]){
        lblMsg.text = room[PARSE_ROOM_LAST_MESSAGE];
        lblDate.text = [Util convertDate2String:room.updatedAt];
    };
    if (![room[PARSE_ROOM_IS_READ] boolValue]){
        PFUser *lastSender = room[PARSE_ROOM_LAST_SENDER];
        if (![lastSender.objectId isEqualToString:me.objectId]){
            ic_dot.hidden = NO;
        }
    }
    int unreadCount = [[unreadCounts objectForKey:room.objectId] intValue];
    if(unreadCount > 0 && !ic_dot.isHidden){
        [lblUnreadCount setHidden:NO];
        lblUnreadCount.text = [NSString stringWithFormat:@"%d", unreadCount];
    }

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
        
    } else if (tag == 20){ // User
        PFObject *room = [dataArray objectAtIndex:indexPath.row];
        PFUser *sender = room[PARSE_ROOM_SENDER];
        PFUser *toUser;
        if ([sender.objectId isEqualToString:me.objectId]){
            toUser = room[PARSE_ROOM_RECEIVER];
        } else {
            sender = me;
            toUser = room[PARSE_ROOM_SENDER];
        }
        [self gotoProfileView:toUser];
//        ProfileViewController *vc = (ProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"ProfileViewController"];
//        vc.user = toUser;
//        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *room = [dataArray objectAtIndex:indexPath.row];
    PFUser *sender = room[PARSE_ROOM_SENDER];
    PFUser *toUser;
    if ([sender.objectId isEqualToString:me.objectId]){
        toUser = room[PARSE_ROOM_RECEIVER];
    } else {
        toUser = room[PARSE_ROOM_SENDER];
    }
    if (![room[PARSE_ROOM_IS_READ] boolValue]){
        PFUser *lastSender = room[PARSE_ROOM_LAST_SENDER];
        if (![lastSender.objectId isEqualToString:me.objectId]){
            room[PARSE_ROOM_IS_READ] = @YES;
            [room saveInBackground];
        }
    }
    int unreadCount = [[unreadCounts objectForKey:room.objectId] intValue];
    [AppStateManager sharedInstance].msgCount = [AppStateManager sharedInstance].msgCount - unreadCount;
    [[RootViewController getInstance] setChatCount:[AppStateManager sharedInstance].msgCount];
    
    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
    vc.room = room;
    vc.toUser = toUser;
    [self.navigationController pushViewController:vc animated:YES];
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
    PFObject *room = [dataArray objectAtIndex:indexPath.row];
    room[PARSE_ROOM_ENABLED] = @NO;
    room[PARSE_ROOM_LAST_MESSAGE] = @"";
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_HISTORY];
        [query whereKey:PARSE_HISTORY_ROOM equalTo:room];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
            for (int i=0;i<results.count;i++){
                PFObject *item = [results objectAtIndex:i];
                [item deleteInBackground];
            }
            [self refreshRooms];
        }];
    }];
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
