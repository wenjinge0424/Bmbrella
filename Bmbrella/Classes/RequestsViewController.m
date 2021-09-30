//
//  RequestsViewController.m
//  Bmbrella
//
//  Created by gao on 4/24/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "RequestsViewController.h"
#import "CircleImageView.h"
#import "ProfileViewController.h"

@interface RequestsViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    IBOutlet UIImageView *imgBackground;
    IBOutlet UITableView *tableview;
    
    IBOutlet UILabel *lblNoResult;
    
    __weak IBOutlet UITextField *edt_Search;
    NSMutableArray *dataArray;
    NSMutableArray * userArray;
    NSMutableArray *searchedArray;
    
    NSString * searchString;
}
@end

@implementation RequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    edt_Search.delegate = self;
    dataArray = [[NSMutableArray alloc] init];
    searchString = @"";
    
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
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == edt_Search){
        NSString * newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        searchString = newString;
        [self refreshItems];
    }
    return YES;
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == edt_Search){
        edt_Search.text = [Util trim:edt_Search.text];
        searchString = edt_Search.text;
        [self refreshItems];
    }
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}
- (void) refreshItems {
    userArray = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query whereKey:PARSE_FOLLOW_TO equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_FOLLOW_ACTIVE equalTo:@NO];
    [query includeKey:PARSE_FOLLOW_FROM];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)array;
            searchedArray = [NSMutableArray new];
            if([searchString isEqual:@""]){
                searchedArray = [[NSMutableArray alloc] initWithArray:dataArray];
            }else{
                for (PFObject * obj in dataArray) {
                    PFUser * user = obj[PARSE_FOLLOW_FROM];
                    NSString * fuleName = user[PARSE_USER_FULL_NAME];
                    if([fuleName rangeOfString:searchString options:NSCaseInsensitiveSearch].length != 0){
                        [searchedArray addObject:obj];
                    }
                }
            }
            NSMutableArray * searcheduserId = [NSMutableArray new];
            for (PFObject * obj in dataArray) {
                PFUser * user = obj[PARSE_FOLLOW_FROM];
                [searcheduserId addObject:user.objectId];
            }
            [searcheduserId addObject:[PFUser currentUser].objectId];
            
            PFQuery *query = [PFUser query];
            if(![searchString isEqual:@""]){
                [query whereKey:PARSE_USER_FULL_NAME matchesRegex:searchString modifiers:@"i"];
            }
            [query orderByAscending:PARSE_USER_FULL_NAME];
            [query whereKey:PARSE_USER_TYPE lessThan:[NSNumber numberWithInteger:300]];
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                [SVProgressHUD dismiss];
                if (error){
                    [self showErrorMsg:[error localizedDescription]];
                } else {
                    userArray = [NSMutableArray new];
                    for (int i=0;i<array.count;i++){
                        PFUser *owner = [array objectAtIndex:i];
                        if(![self stringContainsInArray:searcheduserId :owner.objectId]){
                            [userArray addObject:owner];
                        }
                    }
                    NSArray * sortedArray = [userArray sortedArrayUsingComparator:^NSComparisonResult(PFUser* obj1, PFUser * obj2){
                        NSString * userName1 = obj1[PARSE_USER_FULL_NAME];
                        if ([obj1[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
                            userName1 = obj1[PARSE_USER_FULL_NAME];
                        } else {
                            userName1 = obj1[PARSE_USER_COMPANY_NAME];
                        }
                        NSString * userName2 = obj2[PARSE_USER_FULL_NAME];
                        if ([obj2[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
                            userName2 = obj2[PARSE_USER_FULL_NAME];
                        } else {
                            userName2 = obj2[PARSE_USER_COMPANY_NAME];
                        }
                        userName1 = [userName1 lowercaseString];
                        userName2 = [userName2 lowercaseString];
                        return [userName1 compare:userName2];
                    }];
                    userArray = [NSMutableArray new];
                    userArray = [[NSMutableArray alloc] initWithArray:sortedArray];
                    
                    lblNoResult.hidden = !((searchedArray.count == 0) && (userArray.count == 0));
                    [tableview reloadData];
                    
                }
            }];
            
            
        }
    }];
}
- (BOOL)stringContainsInArray:(NSArray*)array :(NSString*)val
{
    for(NSString * str in array){
        if([val isEqualToString:str])
            return YES;
    }
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    
    CircleImageView *imgAvatar = (CircleImageView *)[cell viewWithTag:1];
    UILabel *lblName = (UILabel *)[cell viewWithTag:2];
    UIButton *btnAccept = (UIButton *)[cell viewWithTag:3];
    [Util setCornerView:btnAccept];
    
    UIButton *btnDecline = (UIButton *)[cell viewWithTag:10];
    [Util setCornerView:btnDecline];
    
    PFObject *object = nil;
    if(indexPath.row < searchedArray.count)
        object = [searchedArray objectAtIndex:indexPath.row];
    else
        object = [userArray objectAtIndex:indexPath.row - searchedArray.count];
    PFUser *user = nil;
    if([object isKindOfClass:[PFUser class]]){
        user = (PFUser*) object;
        [btnAccept setHidden:YES];
        [btnDecline setHidden:YES];
    }else{
        user = object[PARSE_FOLLOW_FROM];
        [btnAccept setHidden:NO];
        [btnDecline setHidden:NO];
    }

    NSString *fullName = @"";
    if ([user[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
        fullName = user[PARSE_USER_FULL_NAME];
    } else {
        fullName = user[PARSE_USER_COMPANY_NAME];
    }
    
    
    
    lblName.text = fullName;
    [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
    
    [btnAccept addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnDecline addTarget:self action:@selector(declineClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchedArray.count + userArray.count;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row < searchedArray.count)
        return;
    PFUser * owner = [userArray objectAtIndex:indexPath.row - searchedArray.count];
    ProfileViewController *vc = (ProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"ProfileViewController"];
    vc.user = owner;
    [self gotoProfileView:owner];
}
- (void) declineClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableview];
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:buttonPosition];
    if (!indexPath){
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFObject *object = [searchedArray objectAtIndex:indexPath.row];
    [object deleteInBackgroundWithBlock:^(BOOL success, NSError* error){
        [SVProgressHUD dismiss];
        if(error){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription] finish:nil];
        }else{
            [Util showAlertTitle:self title:@"" message:@"Request rejected." finish:^(void){
                [self refreshItems];
            }];
        }
    }];
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
        
    } else if (tag == 3){ // User
        PFObject *followObj = [searchedArray objectAtIndex:indexPath.row];
        PFUser *user = followObj[PARSE_FOLLOW_FROM];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [PFUser currentUser].objectId, @"fromId",
                              user.objectId, @"toId",
                              @YES, @"isConnected",
                              nil];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        PFUser * me = [PFUser currentUser];
        NSMutableArray * friends = me[PARSE_USER_FRIEND_LIST];
        if(!friends) friends = [NSMutableArray new];
        [friends addObject:user];
        me[PARSE_USER_FRIEND_LIST] = friends;
        
        [me saveInBackgroundWithBlock:^(BOOL success, NSError * err){
            if (err) {
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[err localizedDescription] finish:nil];
            } else{
                followObj[PARSE_FOLLOW_ACTIVE] = @YES;
                [followObj saveInBackgroundWithBlock:^(BOOL success, NSError * err){
                    if (err) {
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[err localizedDescription] finish:nil];
                    } else{
                        PFUser *me = [PFUser currentUser];
                        NSString *fullName = @"";
                        if ([me[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
                            fullName = me[PARSE_USER_FULL_NAME];
                        } else {
                            fullName = me[PARSE_USER_COMPANY_NAME];
                        }
                        NSString *pushMsg = [NSString stringWithFormat:@"%@ accepted your 'Follow' request.", fullName];
                        NSDictionary *data = @{
                                               @"alert" : pushMsg,
                                               @"badge" : @"Increment",
                                               @"sound" : @"cheering.caf",
                                               @"email" : user.username,
                                               @"type"  : [NSNumber numberWithInt:PUSH_TYPE_FOLLOW_ACCEPTED],
                                               };
                        [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                            [SVProgressHUD dismiss];
                            followObj[PARSE_FOLLOW_ACTIVE] = @YES;
                            [followObj saveInBackground];
                            if (err) {
                                NSLog(@"Fail APNS: %@", @"send ban push");
                            } else {
                                NSLog(@"Success APNS: %@", @"send ban push");
                            }
                            
                            [Util showAlertTitle:self title:LOCALIZATION(@"add_friend") message:LOCALIZATION(@"success") finish:^(void){
                                [self refreshItems];
                            }];
                        }];
                    }
                }];
            }
        }];
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
