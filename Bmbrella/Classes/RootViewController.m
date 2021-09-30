//
//  RootViewController.m
//  Bmbrella
//
//  Created by gao on 5/17/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "RootViewController.h"
#import "ChatDetailsViewController.h"
#import "ChatUsersViewController.h"

static RootViewController *_sharedViewController = nil;


@interface RootViewController ()<UITabBarControllerDelegate>
{
    IBOutlet UIButton *btnHome;
    IBOutlet UIButton *btnCategory;
    IBOutlet UIButton *btnSearch;
    IBOutlet UIButton *btnChat;
    IBOutlet UIButton *btnSettings;
    
    IBOutlet UIImageView *ic_home;
    IBOutlet UIImageView *ic_category;
    IBOutlet UIImageView *ic_search;
    IBOutlet UIImageView *ic_chat;
    IBOutlet UIImageView *ic_settings;
    
    IBOutlet UILabel *lblChatNum;
    NSInteger currentIndex;
    IBOutlet UIImageView *ic_new_msg;
    
}
@end

@implementation RootViewController
@synthesize tabbarController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sharedViewController = self;
    [self getUnreadCount];
    
    tabbarController.delegate = self;
    currentIndex = 0;
    [tabbarController setSelectedIndex:currentIndex];
    
    [self selectTabButton:currentIndex+1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMsg:) name:kChatReceiveNotificationUsers object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) setCurrentTab:(NSInteger) tabIndex {
    currentIndex = tabIndex - 1;
    [tabbarController setSelectedIndex:currentIndex];
    
    [self selectTabButton:tabIndex];
}

- (void) getUnreadCount
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    
    PFUser * me = [PFUser currentUser];
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
        
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        } else {
            int unreadCount = 0;
            NSMutableArray * dataArray = (NSMutableArray *) array;
            int calcIndex = 0;
            [self getUnreadCount:dataArray :calcIndex :unreadCount];
        }
    }];
}
- (void) getUnreadCount:(NSMutableArray *) roomArray :(int)index :(int)unreadCount
{
    if(index >= roomArray.count){
        [SVProgressHUD dismiss];
        [AppStateManager sharedInstance].msgCount = unreadCount;
        [[RootViewController getInstance] setChatCount:[AppStateManager sharedInstance].msgCount];
    }else{
        
        PFObject * rommDict = [roomArray objectAtIndex:index];
        PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_HISTORY];
        [query whereKey:PARSE_HISTORY_ROOM equalTo:rommDict];
        [query whereKey:PARSE_HISTORY_SENDER notEqualTo:[PFUser currentUser]];
        [query whereKey:PARSE_ROOM_IS_READ equalTo:[NSNumber numberWithBool:NO]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            int calcIndex = index;
            int totalUnreadCount = unreadCount;
            if(array.count > 0){
                totalUnreadCount += (int)array.count;
            }
            calcIndex ++;
            [self getUnreadCount:roomArray :calcIndex :totalUnreadCount];
        }];
    }
}

- (void) receivedNewMsg:(NSNotification *) notif {
    if ([ChatDetailsViewController getInstance]){
        NSString *roomId = [notif.object objectForKey:@"data"];
        if ([roomId isEqualToString:[AppStateManager sharedInstance].chatRoomId]){
            return;
        }else{
            [AppStateManager sharedInstance].msgCount++;
            if([AppStateManager sharedInstance].msgCount > 0){
                lblChatNum.text = [NSString stringWithFormat:@"%d", [AppStateManager sharedInstance].msgCount];
                lblChatNum.hidden = NO;
                ic_new_msg.hidden = NO;
            }else{
                lblChatNum.text = @"";
                lblChatNum.hidden = YES;
                ic_new_msg.hidden = YES;
            }
            return;
        }
    }
//    if ([ChatUsersViewController getInstance]){
//        return;
//    }
    if([AppStateManager sharedInstance].msgCount > 0){
        lblChatNum.text = [NSString stringWithFormat:@"%d", [AppStateManager sharedInstance].msgCount];
        lblChatNum.hidden = NO;
        ic_new_msg.hidden = NO;
    }else{
        lblChatNum.text = @"";
        lblChatNum.hidden = YES;
        ic_new_msg.hidden = YES;
    }
    [AppStateManager sharedInstance].msgCount++;
}
- (void) setChatCount:(int)count
{
    lblChatNum.text = [NSString stringWithFormat:@"%d", [AppStateManager sharedInstance].msgCount];
    if(count <= 0){
        lblChatNum.text = @"";
        lblChatNum.hidden = YES;
        ic_new_msg.hidden = YES;
    }else{
        lblChatNum.text = [NSString stringWithFormat:@"%d", [AppStateManager sharedInstance].msgCount];
        lblChatNum.hidden = NO;
        ic_new_msg.hidden = NO;
    }
}
- (IBAction)onSelectTab:(id)sender {
    NSInteger tag = [sender tag];
    currentIndex = tag - 1;
    if (tag != TAB_SEARCH){
        [tabbarController setSelectedIndex:currentIndex];
    } else {
        [tabbarController setSelectedIndex:0];
    }
    
    [self selectTabButton:tag];
}

+ (RootViewController *)getInstance{
    return _sharedViewController;
}


- (void) selectTabButton:(NSInteger)tag {
    [ic_home setImage:[UIImage imageNamed:@"ic_opt_home"]];
    [ic_category setImage:[UIImage imageNamed:@"ic_opt_category"]];
    [ic_search setImage:[UIImage imageNamed:@"ic_opt_search"]];
    [ic_chat setImage:[UIImage imageNamed:@"ic_opt_chat"]];
    [ic_settings setImage:[UIImage imageNamed:@"ic_opt_settings"]];
    
    switch (tag) {
        case TAB_HOME:
            [NSNotificationCenter.defaultCenter postNotificationName:kHomeTapped object:nil];
            [ic_home setImage:[UIImage imageNamed:@"ic_opt_home_sel"]];
            break;
        case TAB_CATEGORY:
            [ic_category setImage:[UIImage imageNamed:@"ic_opt_category_sel"]];
            break;
        case TAB_SEARCH:
            [NSNotificationCenter.defaultCenter postNotificationName:kHomeTapped object:nil];
            [[MainViewController getInstance] onSearch];
//            [ic_search setImage:[UIImage imageNamed:@"ic_opt_search_sel"]];
            [ic_home setImage:[UIImage imageNamed:@"ic_opt_home_sel"]];
            break;
        case TAB_CHAT:
            [AppStateManager sharedInstance].msgCount = 1;
            ic_new_msg.hidden = YES;
            lblChatNum.hidden = YES;
            [ic_chat setImage:[UIImage imageNamed:@"ic_opt_chat_sel"]];
            break;
        case TAB_SETTING:
            [ic_settings setImage:[UIImage imageNamed:@"ic_opt_settings_sel"]];
            break;
        default:
            [ic_home setImage:[UIImage imageNamed:@"ic_opt_home_sel"]];
            break;
    }
}

- (void) hideChatLabel {
//    [AppStateManager sharedInstance].msgCount = 1;
//    ic_new_msg.hidden = YES;
//    lblChatNum.hidden = YES;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        tabbarController = segue.destinationViewController;
        [tabbarController setHidesBottomBarWhenPushed:YES];
    }
}


@end
