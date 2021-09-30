//
//  ChatViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatDetailsViewController.h"
#import "IQDropDownTextField.h"

@interface ChatViewController ()<IQDropDownTextFieldDelegate>
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet IQDropDownTextField *txtUsername;
    IBOutlet UIView *viewUsername;
    
    NSMutableArray *usersArray;
    PFUser *me;
    NSMutableArray *dataArray;
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.toUser){
        NSInteger userType = [self.toUser[PARSE_USER_TYPE] integerValue];
        if (userType == USER_TYPE_CUSTOMER)
            lblTitle.text = self.toUser[PARSE_USER_FULL_NAME];
        else
            lblTitle.text = self.toUser[PARSE_USER_COMPANY_NAME];
        viewUsername.hidden = YES;
    } else {
        txtUsername.delegate = self;
        lblTitle.text = LOCALIZATION(@"new_message");
        viewUsername.hidden = NO;
        
        me = [PFUser currentUser];
        [me fetchIfNeeded];
        usersArray = [[NSMutableArray alloc] init];
        dataArray = [[NSMutableArray alloc] init];
        usersArray = [[NSMutableArray alloc] initWithArray:me[PARSE_USER_FRIEND_LIST]];
        // get friend unregistered
        [self initMembers];
    }
    
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
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void) initMembers {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me fetchIfNeededInBackgroundWithBlock:^(PFObject* newMe, NSError * error){
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        }else{
            me = (PFUser*)newMe;
            usersArray = [[NSMutableArray alloc] initWithArray:me[PARSE_USER_FRIEND_LIST]];
            
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
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [self showErrorMsg:[error localizedDescription]];
                } else {
                    NSMutableArray *resultArray = (NSMutableArray *) array;
                    for (NSInteger i=0;i<resultArray.count;i++){
                        PFObject *room = [resultArray objectAtIndex:i];
                        PFUser *sender = (PFUser *) room[PARSE_ROOM_SENDER];
                        PFUser *toUser;
                        if ([sender.objectId isEqualToString:me.objectId]){
                            toUser = (PFUser *) room[PARSE_ROOM_RECEIVER];
                        } else {
                            toUser = sender;
                        }
                        
                        [self isContainedinFriends:toUser];
                    }
                    dataArray = [[NSMutableArray alloc] init];
                    for (PFUser *item in usersArray){
                        PFUser *user = [item fetchIfNeeded];
                        NSInteger type = [user[PARSE_USER_TYPE] integerValue];
                        if (type == USER_TYPE_CUSTOMER)
                            [dataArray addObject:user[PARSE_USER_FULL_NAME]];
                        else
                            [dataArray addObject:user[PARSE_USER_COMPANY_NAME]];
                    }
                    txtUsername.itemList = dataArray;
                    [SVProgressHUD dismiss];
                }
            }];
        }
    }];
}

- (void) isContainedinFriends:(PFUser *)user {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i=0;i<usersArray.count;i++){
        [tempArray addObject:[usersArray objectAtIndex:i]];
    }
    for (PFUser *item in tempArray){
        if ([item.objectId isEqualToString:user.objectId]){
            [usersArray removeObject:item];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatDetailsViewController *vc = (ChatDetailsViewController *) segue.destinationViewController;
        vc.toUser = self.toUser;
        vc.room = self.room;
    }
}

- (void) textField:(IQDropDownTextField *)textField didSelectItem:(NSString *)item {
    NSLog(@"SELETECT %@", item);
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == txtUsername){
        NSInteger currentIndex = [dataArray indexOfObject:txtUsername.selectedItem];
        if (currentIndex == NSNotFound){
            return;
        }
        
        PFUser *user = [usersArray objectAtIndex:currentIndex];
        if (!user){
            return;
        }
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        
        viewUsername.hidden = YES;
        NSInteger type = [user[PARSE_USER_TYPE] integerValue];
        if (type == USER_TYPE_CUSTOMER)
            lblTitle.text = user[PARSE_USER_FULL_NAME];
        else
            lblTitle.text = user[PARSE_USER_COMPANY_NAME];
        PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query1 whereKey:PARSE_ROOM_SENDER equalTo:me];
        [query1 whereKey:PARSE_ROOM_RECEIVER equalTo:user];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:me];
        [query2 whereKey:PARSE_ROOM_SENDER equalTo:user];
        
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        [queries addObject:query1];
        [queries addObject:query2];
        PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
        [query whereKey:PARSE_ROOM_ENABLED equalTo:@NO];
        [query includeKey:PARSE_ROOM_RECEIVER];
        [query includeKey:PARSE_ROOM_SENDER];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            if (error){
                [SVProgressHUD dismiss];
                [self showErrorMsg:[error localizedDescription]];
            } else {
                if (array.count > 0){
                    PFObject *room = (PFObject *)[array objectAtIndex:0];
                    room[PARSE_ROOM_ENABLED] = @YES;
                    [room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                        [SVProgressHUD dismiss];
                        [[ChatDetailsViewController getInstance] setRoom:room User:user];
                    }];
                } else {
                    PFObject *room = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
                    room[PARSE_ROOM_SENDER] = me;
                    room[PARSE_ROOM_RECEIVER] = user;
                    room[PARSE_ROOM_LAST_MESSAGE] = @"";
                    room[PARSE_ROOM_ENABLED] = @YES;
                    room[PARSE_ROOM_IS_READ] = @YES;
                    [room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                        [SVProgressHUD dismiss];
                        [[ChatDetailsViewController getInstance] setRoom:room User:user];
                    }];
                }
            }
        }];
    }
}

@end
