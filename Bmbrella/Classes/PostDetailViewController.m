//
//  PostDetailViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "PostDetailViewController.h"
#import "ChatViewController.h"
#import "ChatUsersViewController.h"
#import "CommentsViewController.h"
#import "ProfileViewController.h"
#import "FlagViewController.h"
#import "CircleImageView.h"
#import "ReadMoreTextView-Swift.h"
#import "MediaViewController.h"
#import "RootViewController.h"

@interface PostDetailViewController ()
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblUserTitle;
    IBOutlet UIImageView *imgPost;
    
    PFUser *owner;
    BOOL isMe;
    __weak IBOutlet UIImageView *img_liked;
    IBOutlet UIButton *btnAction;
    IBOutlet UILabel *lblLikes;
    IBOutlet UILabel *lblComments;
    
    NSMutableArray *likersArray;
    IBOutlet CircleImageView *imgAvatar;
    
    NSTimer *timer;
    IBOutlet UIView *videoView;
    IBOutlet UIButton *btnPlay;
    BOOL isPlaying;
    IBOutlet UITextView *txtDescriptio;
    IBOutlet UIImageView *imgBackground;
    
    BOOL needUpdate;
}
@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    needUpdate = NO;
    
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
    
    [Util setImage:imgPost imgFile:(PFFile *)self.object[PARSE_POST_IMAGE]];
    owner = self.object[PARSE_POST_OWNER];
    owner = [owner fetchIfNeeded];
    [Util setImage:imgAvatar imgFile:(PFFile *)owner[PARSE_USER_AVATAR]];
    NSInteger userType = [owner[PARSE_USER_TYPE] integerValue];
    if (userType == USER_TYPE_BUSINESS){
        lblName.text = owner[PARSE_USER_COMPANY_NAME];
    } else {
        lblName.text = owner[PARSE_USER_FULL_NAME];
    }
    
    lblUserTitle.text = owner[PARSE_USER_TITLE];
    isMe = [owner.objectId isEqualToString:[PFUser currentUser].objectId];
    
    if (isMe){
        [btnAction setImage:[UIImage imageNamed:@"ic_bin"] forState:UIControlStateNormal];
    } else {
        [btnAction setImage:[UIImage imageNamed:@"ic_flag"] forState:UIControlStateNormal];
    }
    
    [Util setBorderView:txtDescriptio color:[UIColor blackColor] width:1.0];
    [Util setCornerView:txtDescriptio];
    [self initData];
    
//    txtDescriptio.shouldTrim = YES;
//    txtDescriptio.maximumNumberOfLines = 1;
    txtDescriptio.scrollEnabled = YES;
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@" Read more"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0,10)];
    
    NSMutableAttributedString * string1 = [[NSMutableAttributedString alloc] initWithString:@" Read less"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0,10)];
    
//    txtDescriptio.attributedReadMoreText = string;
//    txtDescriptio.attributedReadLessText = string1;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appdidActive:) name:NOTIFICATION_ACTIVE object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appdidbackground:) name:NOTIFICATION_BACKGROUND object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onTapReadMore:) name:NOTIFICATION_TAP_READMORE object:nil];

}

- (void) appdidActive:(NSNotification *) notif {
    BOOL isVideo = [self.object[PARSE_POST_IS_VIDEO] boolValue];
    if (isVideo){
        videoView.hidden = NO;
        if (self.avplayer){
            isPlaying = NO;
            [self.avplayer pause];
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
        }
    }
}

- (IBAction)onDetails:(id)sender {
    BOOL isVideo = [self.object[PARSE_POST_IS_VIDEO] boolValue];
    MediaViewController *vc = (MediaViewController *)[Util getUIViewControllerFromStoryBoard:@"MediaViewController"];
    if (isVideo) {
        vc.video = (PFFile *)self.object[PARSE_POST_VIDEO];
        [[RootViewController getInstance].navigationController pushViewController:vc animated:YES];
    } else {
//        PFFile *filePhoto = (PFFile *)self.object[PARSE_POST_IMAGE];
//        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//        [filePhoto getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
//            if (!error) {
//                vc.image = [UIImage imageWithData:data];
//                [[RootViewController getInstance].navigationController pushViewController:vc animated:YES];
//            }
//        }];
        vc.image = imgPost.image;
        [[RootViewController getInstance].navigationController pushViewController:vc animated:YES];
    }
    
}

- (void) onTapReadMore:(NSNotification *) notif {
    NSLog(@"");
    MediaViewController *vc = (MediaViewController *)[Util getUIViewControllerFromStoryBoard:@"MediaViewController"];
    vc.txtDescriptionString = self.object[PARSE_POST_DESCRIPTION];
    [[RootViewController getInstance].navigationController pushViewController:vc animated:YES];
}

- (IBAction)onReadMore:(id)sender {
    [self onTapReadMore:nil];
}

- (void) appdidbackground:(NSNotification *) notif {
    BOOL isVideo = [self.object[PARSE_POST_IS_VIDEO] boolValue];
    if (isVideo){
        if (self.avplayer){
            isPlaying = NO;
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
            [self.avplayer pause];
        }
    }
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
    
    self.object = [self.object fetchIfNeeded];
    [self initData];
}

- (void) targetMethod {
    self.object = [self.object fetch];
    BOOL isVideo = [self.object[PARSE_POST_IS_VIDEO] boolValue];
    if (!isVideo)
        [self initData];
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([timer isValid]){
        [timer invalidate];
        timer = nil;
    }
}

- (void) initData {
    if (!self.object){
        if ([timer isValid]){
            [timer invalidate];
            timer = nil;
        }
        [self onback:nil];
        return;
    }
    likersArray = self.object[PARSE_POST_LIKES];
    if (likersArray.count > 1)
        lblLikes.text = [NSString stringWithFormat:@"%ld %@", likersArray.count, LOCALIZATION(@"likes")];
    else
        lblLikes.text = [NSString stringWithFormat:@"%ld %@", likersArray.count, LOCALIZATION(@"like")];
    
    BOOL alreadyLiked = NO;
    for(PFUser * user in likersArray){
        PFUser * me = [PFUser currentUser];
        if([[user objectId] isEqualToString:[me objectId]]){
            alreadyLiked = YES;
        }
    }
    if(alreadyLiked){
        [img_liked setImage:[UIImage imageNamed:@"ico_liked"]];
    }else{
        [img_liked setImage:[UIImage imageNamed:@"ic_heart"]];
    }
    
    int commentCnt = [self.object[PARSE_POST_COMMENT_COUNT] intValue];
    if (commentCnt > 1)
        lblComments.text = [NSString stringWithFormat:@"%d %@", commentCnt, LOCALIZATION(@"comments")];
    else
        lblComments.text = [NSString stringWithFormat:@"%d %@", commentCnt, LOCALIZATION(@"comment")];
    
    txtDescriptio.text = self.object[PARSE_POST_DESCRIPTION];
    txtDescriptio.dataDetectorTypes = UIDataDetectorTypeNone;
    txtDescriptio.dataDetectorTypes = UIDataDetectorTypeLink;
    
    
    BOOL isVideo = [self.object[PARSE_POST_IS_VIDEO] boolValue];
    if (isVideo){
        btnPlay.hidden = NO;
    } else {
        videoView.hidden = YES;
        imgPost.hidden = NO;
        btnPlay.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayVideo:(id)sender {
    videoView.hidden = NO;
    imgPost.hidden = YES;
    if (isPlaying){
        if (self.avplayer){
            [self.avplayer pause];
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
        }
    } else {
        if (self.avplayer){
            [self.avplayer play];
        } else {
            [self playVideo];
        }
//        [btnPlay setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
        [btnPlay setHidden:YES];
    }
    isPlaying = !isPlaying;

}

- (void) playVideo {
    if (self.object[PARSE_POST_VIDEO]){
        [self showVideoMoment:(PFFile *)self.object[PARSE_POST_VIDEO]];
    }
}

- (void) showVideoMoment:(PFFile *)file
{
    if (!file){
        if (self.avplayer){
            isPlaying = NO;
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
            [self.avplayer seekToTime:kCMTimeZero];
            [self.avplayer pause];
        }
        return;
    }
    
    NSString *docPath = [self getDocumentDirectoryPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, file.name];
    self.filePath = filePath;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists){
        [self playVideo:filePath];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                NSLog(@"Error get Video Data from Server");
            } else {
                [data writeToFile:filePath atomically:YES];
                [self playVideo:filePath];
            }
        }];
    }
}

- (void)playVideo:(NSString *)filePath
{
    [self.avplayer pause];
    self.avplayer = nil;
    //play video
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.avplayer = [AVPlayer playerWithURL:url];
    
    //    [self.avplayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    self.avplayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.avplayer setMuted:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avplayer currentItem]];
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    videoLayer.frame = CGRectMake(0, 0, videoView.bounds.size.width, videoView.bounds.size.height);
//    videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [videoView.layer addSublayer:videoLayer];
    [self.avplayer play];
    
//    [btnPlay setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
    [btnPlay setHidden:YES];
    isPlaying = YES;
    //    [self playAt:kCMTimeZero];
}

- (void)playerItemDidReachEnd:(NSNotification *) notification // video end notificaton
{
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer pause];
    [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    [btnPlay setHidden:NO];
    isPlaying = NO;
//    AVPlayerItem *process = [notification object];
//    [process seekToTime:kCMTimeZero];
}

- (NSString *) getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}


- (IBAction)onback:(id)sender {
    if(!needUpdate){
        if(self.delegate){
            [self.delegate PostDetailViewControllerDelegate_complete];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMessages:(id)sender {
    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
    if (!isMe){
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        vc.toUser = owner;
        PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query1 whereKey:PARSE_ROOM_SENDER equalTo:[PFUser currentUser]];
        [query1 whereKey:PARSE_ROOM_RECEIVER equalTo:owner];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:[PFUser currentUser]];
        [query2 whereKey:PARSE_ROOM_SENDER equalTo:owner];
        
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        [queries addObject:query1];
        [queries addObject:query2];
        PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
//        [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
        [query includeKey:PARSE_ROOM_RECEIVER];
        [query includeKey:PARSE_ROOM_SENDER];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (object){
                [SVProgressHUD dismiss];
                if ([object[PARSE_ROOM_ENABLED] boolValue]){

                } else {
                    object[PARSE_ROOM_ENABLED] = @YES;
                    [object saveInBackground];
                }
                vc.room = object;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
                obj[PARSE_ROOM_SENDER] = [PFUser currentUser];
                obj[PARSE_ROOM_RECEIVER] = owner;
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
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)onComments:(id)sender {
    CommentsViewController *vc = (CommentsViewController *)[Util getUIViewControllerFromStoryBoard:@"CommentsViewController"];
    vc.object = self.object;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onLike:(id)sender {
//    if (isMe){
//        [self showErrorMsg:LOCALIZATION(@"own_like_warnig")];
//        return;
//    }
    if ([self isLikedofMe]){
        [self showErrorMsg:LOCALIZATION(@"already_liked")];
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [likersArray addObject:[PFUser currentUser]];
    self.object[PARSE_POST_LIKES] = likersArray;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self.object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
        } else {
            PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
            notificationObj[PARSE_NOTIFICATION_FROM] = [PFUser currentUser];
            notificationObj[PARSE_NOTIFICATION_TO] = self.object[PARSE_POST_OWNER];
            notificationObj[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_LIKE];
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
                
                [self sendNotification:self.object[PARSE_POST_OWNER] message:[NSString stringWithFormat:@"%@ like your post.", fullName]];
                
                [self initData];
            }];
        }
    }];
}

- (IBAction)onUser:(id)sender {
    ProfileViewController *vc = (ProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"ProfileViewController"];
    if (!isMe){
        vc.user = owner;
        [self gotoProfileView:owner];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)doAction:(id)sender {
    if (isMe){
        [self deletePost];
    } else {
        [self reportPost];
    }
}

- (void) deletePost {
    NSString *msg = LOCALIZATION(@"confirm_del_post");
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        
        BOOL isPublic = ![self.object[PARSE_POST_IS_PRIVATE] boolValue];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            needUpdate = YES;
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"success") finish:^(void){
                [self onback:nil];
            }];
            
        }];
    }];
    [alert addButton:LOCALIZATION(@"no") actionBlock:^(void) {
        
    }];
    [alert showQuestion:LOCALIZATION(@"warning") subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (IBAction)onShare:(id)sender {
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    BOOL isVideo = [self.object[PARSE_POST_IS_VIDEO] boolValue];
    if (!isVideo){
        PFFile *file = self.object[PARSE_POST_IMAGE];
        NSString *link = file.url;
        [activityItems addObject:link];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (error){
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            } else {
                UIImage *img = [UIImage imageWithData:data];
                [activityItems addObject:img];
                UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                activityViewControntroller.excludedActivityTypes = @[];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    activityViewControntroller.popoverPresentationController.sourceView = self.view;
                    activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
                }
                
                [self presentViewController:activityViewControntroller animated:YES completion:nil];
                [SVProgressHUD dismiss];
            }
        }];
    } else {
        PFFile *file = (PFFile *)self.object[PARSE_POST_VIDEO];
        if (!file){
            return;
        }
        NSString* link = file.url;
        [activityItems addObject:link];
        
        NSString *docPath = [self getDocumentDirectoryPath];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, file.name];
        self.filePath = filePath;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists){
            [activityItems addObject:[NSURL fileURLWithPath:filePath]];
            UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activityViewControntroller.excludedActivityTypes = @[];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                activityViewControntroller.popoverPresentationController.sourceView = self.view;
                activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
            }
            
            [self presentViewController:activityViewControntroller animated:YES completion:nil];
        } else {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                [SVProgressHUD dismiss];
                if (error){
                    NSLog(@"Error get Video Data from Server");
                } else {
                    [data writeToFile:filePath atomically:YES];
                    [activityItems addObject:[NSURL fileURLWithPath:filePath]];
                    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                    activityViewControntroller.excludedActivityTypes = @[];
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        activityViewControntroller.popoverPresentationController.sourceView = self.view;
                        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
                    }
                    
                    [self presentViewController:activityViewControntroller animated:YES completion:nil];
                }
            }];
        }
    }
}

- (void) reportPost {
    PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_REPORT];
    obj[PARSE_REPORT_REPORTER] = [PFUser currentUser];
    obj[PARSE_REPORT_OWNER] = owner;
    obj[PARSE_REPORT_POST] = self.object;
    obj[PARSE_REPORT_TYPE] = [NSNumber numberWithInteger:REPORT_TYPE_POST];
    FlagViewController *vc = (FlagViewController *) [Util getUIViewControllerFromStoryBoard:@"FlagViewController"];
    vc.object = obj;
    [self.navigationController pushViewController:vc animated:YES];
    
//    NSString *msg = LOCALIZATION(@"confirm_report_post");
//    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//    alert.customViewColor = MAIN_COLOR;
//    alert.horizontalButtons = YES;
//    [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
//        if (![Util isConnectableInternet]){
//            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
//            return;
//        }
//        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REPORT];
//        [query whereKey:PARSE_REPORT_POST equalTo:self.object];
//        [query whereKey:PARSE_REPORT_REPORTER equalTo:[PFUser currentUser]];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *err){
//            if (err){
//                [SVProgressHUD dismiss];
//                [self showErrorMsg:[err localizedDescription]];
//            } else {
//                if (array.count>0){
//                    [SVProgressHUD dismiss];
//                    [self showErrorMsg:LOCALIZATION(@"already_reported")];
//                } else {
//                    PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_REPORT];
//                    obj[PARSE_REPORT_REPORTER] = [PFUser currentUser];
//                    obj[PARSE_REPORT_OWNER] = owner;
//                    obj[PARSE_REPORT_POST] = self.object;
//                    obj[PARSE_REPORT_TYPE] = [NSNumber numberWithInteger:REPORT_TYPE_POST];
//                    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
//                        [SVProgressHUD dismiss];
//                        if (error){
//                            [self showErrorMsg:[error localizedDescription]];
//                        } else {
//                            [Util showAlertTitle:self title:LOCALIZATION(@"report_post") message:LOCALIZATION(@"success")];
//                        }
//                    }];
//                }
//            }
//        }];
//    }];
//    [alert addButton:LOCALIZATION(@"no") actionBlock:^(void) {
//        
//    }];
//    [alert showQuestion:LOCALIZATION(@"warning") subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (BOOL) isLikedofMe {
    for (int i=0;i<likersArray.count;i++){
        PFUser *user = [likersArray objectAtIndex:i];
        if ([user.objectId isEqualToString:[PFUser currentUser].objectId]){
            return YES;
        }
    }
    return NO;
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
