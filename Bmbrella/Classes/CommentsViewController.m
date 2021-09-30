//
//  CommentsViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "CommentsViewController.h"
#import "CircleImageView.h"
#import "ProfileViewController.h"

@interface CommentsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITextField *txtComment;
    IBOutlet UILabel *lblTitle;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    NSMutableArray *heightArray;
    
    NSTimer *timer;
    NSInteger commentCount;
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataArray = [[NSMutableArray alloc] init];
    heightArray = [[NSMutableArray alloc] init];
    [self refreshItems];
    
    commentCount = [self.object[PARSE_POST_COMMENT_COUNT] integerValue];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!timer){
        timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                 target:self
                                               selector:@selector(targetMethod)
                                               userInfo:nil
                                                repeats:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([timer isValid]){
        [timer invalidate];
        timer = nil;
    }
}

- (void) targetMethod {
    self.object = [self.object fetch];
    NSInteger count = [self.object[PARSE_POST_COMMENT_COUNT] integerValue];
    if (count != commentCount && ![SVProgressHUD isVisible]){
        commentCount = count;
        [self refreshItems];
    }
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_COMMENT];
    [query whereKey:PARSE_COMMENT_POST equalTo:self.object];
    [query includeKey:PARSE_COMMENT_USER];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)array;
            heightArray = [[NSMutableArray alloc] init];
            for (int i=0;i<dataArray.count;i++){
                [heightArray addObject:[NSString stringWithFormat:@"%f", [self getHeight:i]]];
            }
            [tableview reloadData];
        }
    }];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onPostComment:(id)sender {
    [self.view endEditing:YES];
    txtComment.text = [Util trim:txtComment.text];
    NSString *comment = txtComment.text;
    if (comment.length == 0){
        [self showErrorMsg:LOCALIZATION(@"no_comment")];
        return;
    }
    if (comment.length > 500){
        [self showErrorMsg:LOCALIZATION(@"long_comment")];
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    txtComment.text = @"";
    PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_COMMENT];
    obj[PARSE_COMMENT_POST] = self.object;
    obj[PARSE_COMMENT_USER] = [PFUser currentUser];
    obj[PARSE_COMMENT_TEXT] = comment;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        } else {
            int count = [self.object[PARSE_POST_COMMENT_COUNT] intValue];
            self.object[PARSE_POST_COMMENT_COUNT] = [NSNumber numberWithInt:(count+1)];
            [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                commentCount++;
                
                PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                notificationObj[PARSE_NOTIFICATION_FROM] = [PFUser currentUser];
                notificationObj[PARSE_NOTIFICATION_TO] = self.object[PARSE_POST_OWNER];
                notificationObj[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_COMMENT];
                notificationObj[PARSE_NOTIFICATION_ISREAD] = [NSNumber numberWithBool:NO];
                notificationObj[PARSE_NOTIFICATION_LINK] = self.object;
                [notificationObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                    [SVProgressHUD dismiss];
                    
                    NSString *fullName = @"";
                    PFUser *me = [PFUser currentUser];
                    if ([me[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
                        fullName = me[PARSE_USER_FULL_NAME];
                    } else {
                        fullName = me[PARSE_USER_COMPANY_NAME];
                    }
                    
                    [self sendNotification:self.object[PARSE_POST_OWNER] message:[NSString stringWithFormat:@"%@ comment to your post.", fullName]];
                    [self refreshItems];
                }];
            }];
        }
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    CircleImageView *imgAvatar = (CircleImageView *)[cell viewWithTag:1];
    UILabel *lblName = (UILabel *)[cell viewWithTag:2];
    UITextView *txtComment = (UITextView *)[cell viewWithTag:3];
    UILabel *lblDate = (UILabel *)[cell viewWithTag:4];
    PFObject *object = dataArray[indexPath.row];
    PFUser *user = object[PARSE_COMMENT_USER];
    [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
    NSInteger userType = [user[PARSE_USER_TYPE] integerValue];
    if (userType == USER_TYPE_CUSTOMER){
        lblName.text = user[PARSE_USER_FULL_NAME];
    } else {
        lblName.text = user[PARSE_USER_COMPANY_NAME];
    }
    txtComment.text = object[PARSE_COMMENT_TEXT];
    lblDate.text = [Util getParseCommentDate:object.createdAt];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[heightArray objectAtIndex:indexPath.row] floatValue];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *object = dataArray[indexPath.row];
    PFUser *user = object[PARSE_COMMENT_USER];
//    ProfileViewController *vc = (ProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"ProfileViewController"];
//    vc.user = user;
//    [self.navigationController pushViewController:vc animated:YES];
    [self gotoProfileView:user];
}

- (CGFloat) getHeight:(NSInteger)row {
    UITextView *textView = [[UITextView alloc] init];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(265, 40);
    textView.frame = newFrame;
    
    PFObject *feed = [dataArray objectAtIndex:row];
    NSString *text = feed[PARSE_COMMENT_TEXT];
    textView.text = text;
    
    textView.translatesAutoresizingMaskIntoConstraints = YES;
    [textView sizeToFit];
    textView.scrollEnabled =NO;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize new = [Util calculateHeightForString:text];
    CGRect newFrame1 = textView.frame;
    newFrame.size = CGSizeMake(fixedWidth, new.height);
    textView.frame = newFrame1;
    
    return 80 + new.height;
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
