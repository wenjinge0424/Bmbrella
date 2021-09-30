//
//  ReportedPostDetailViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "ReportedPostDetailViewController.h"
#import "LMMediaPlayerView.h"

@interface ReportedPostDetailViewController ()<LMMediaPlayerViewDelegate>
{
    IBOutlet UIButton *btnBan;
    IBOutlet UIButton *btnDelAd;
    IBOutlet UIButton *btnDelReport;
    IBOutlet UITextView *txtDescription;
    IBOutlet UILabel *lblUser;
    __weak IBOutlet UIImageView *img_thumb;
    __weak IBOutlet UIView *view_videoPlay;
    
    LMMediaPlayerView *playerView_;
    
    PFObject * postInfo;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_play;
@end

@implementation ReportedPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Util setCornerView:btnBan];
    [Util setCornerView:btnDelAd];
    [Util setCornerView:btnDelReport];
    
    PFUser *reporter = self.object[PARSE_REPORT_REPORTER];
    
    NSInteger type = [reporter[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        lblUser.text = [NSString stringWithFormat:@"Reported by %@", reporter[PARSE_USER_FULL_NAME]];
    } else {
        lblUser.text = [NSString stringWithFormat:@"Reported by %@", reporter[PARSE_USER_COMPANY_NAME]];
    }
    txtDescription.text = self.object[PARSE_REPORT_DESCRIPTION];
    txtDescription.textColor = [UIColor whiteColor];
    
    [view_videoPlay setHidden:YES];
    [_btn_play setHidden:YES];
    
    [self fetchData];
}
- (void)fetchData
{
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    PFObject * postObj = self.object[PARSE_REPORT_POST];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [postObj fetchInBackgroundWithBlock:^(PFObject * postObject, NSError * error){
        [SVProgressHUD dismiss];
        if(error){
            [self showErrorMsg:[error localizedDescription]];
        }else{
            postInfo = postObj;
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util setImage:img_thumb imgFile:(PFFile *) postObject[PARSE_POST_IMAGE]];
            });
            BOOL isVideo = [postObject[PARSE_POST_IS_VIDEO] boolValue];
            if(!isVideo){
                [view_videoPlay setHidden:YES];
                [_btn_play setHidden:YES];
            }else{
                [view_videoPlay setHidden:NO];
                [_btn_play setHidden:NO];
            }
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    if(playerView_){
        [playerView_.mediaPlayer stop];
        playerView_.delegate = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) initializeVideo
{
    if(!playerView_){
        playerView_ = [LMMediaPlayerView sharedPlayerView];
        playerView_.frame = view_videoPlay.bounds;
        playerView_.delegate = self;
        [playerView_ setHeaderViewHidden:YES];
        [playerView_ setFooterViewHidden:NO];
        playerView_.previousButton.hidden = YES;
        playerView_.nextButton.hidden = YES;
        
        playerView_.delegate = self;
        
        view_videoPlay.backgroundColor = [UIColor blackColor];
        playerView_.frame = view_videoPlay.bounds;
        [view_videoPlay addSubview:playerView_];
    }
}
#pragma mark - LMMediaPlayerViewDelegate

- (BOOL)mediaPlayerViewWillStartPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media
{
    return YES;
}
- (NSString *) getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}
- (void) showVideoMoment:(PFFile *)file
{
    if (!file){
        if (playerView_.mediaPlayer){
            [self.btn_play setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [self.btn_play setHidden:NO];
            //            [playerView_.mediaPlayer seekToTime:kCMTimeZero];
            [playerView_.mediaPlayer pause];
        }
        return;
    }
    
    NSString *docPath = [self getDocumentDirectoryPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, file.name];
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
    [self initializeVideo];
    LMMediaItem *item = [[LMMediaItem alloc] initWithInfo:@{LMMediaItemInfoURLKey:[NSURL fileURLWithPath:filePath], LMMediaItemInfoContentTypeKey:@(LMMediaItemContentTypeVideo)}];
    [playerView_.mediaPlayer addMedia:item];
    [playerView_.mediaPlayer play];
    [_btn_play setHidden:YES];
}
- (IBAction)onPlayVideo:(id)sender {
    PFFile * videoFile = postInfo[PARSE_POST_VIDEO];
    [self showVideoMoment:videoFile];
}

- (IBAction)onDelReport:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.object deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [self showErrorMsg:[error localizedDescription]];
            } else {
                [Util showAlertTitle:self title:@"" message:@"Sucess" finish:^(void){
                    [self onback:nil];
                }];
            }
        }];
    }];
    [alert addButton:@"Cancel" actionBlock:^(void) {
        
    }];
    [alert showError:@"Delete Ad" subTitle:@"Are you sure want to delete this report?" closeButtonTitle:nil duration:0.0f];
}

- (IBAction)onDelPost:(id)sender {
    PFObject *post = self.object[PARSE_REPORT_POST];
    if (!post){
        [self showErrorMsg:@"This Ad was already deleted."];
        return;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [post deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            if (error){
                [SVProgressHUD dismiss];
                [self showErrorMsg:[error localizedDescription]];
            } else {
                [self.object deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                    [SVProgressHUD dismiss];
                    if (error){
                        [self showErrorMsg:[error localizedDescription]];
                    } else {
                        [Util showAlertTitle:self title:@"" message:@"Sucess" finish:^(void){
                            [self onback:nil];
                        }];
                    }
                }];
            }
        }];
        
    }];
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert showError:@"Delete Ad" subTitle:@"Are you sure want to delete this Ad?" closeButtonTitle:nil duration:0.0f];
}

- (IBAction)onBanUser:(id)sender {
    PFUser *owner = self.object[PARSE_REPORT_OWNER];
    BOOL isBanned = [owner[PARSE_USER_IS_BANNED] boolValue];
    if (isBanned){
        [self showErrorMsg:@"This user is already banned."];
        return;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
            return;
        }
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              owner.username, @"email",
                              YES, @"isBanned",
                              nil];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [PFCloud callFunctionInBackground:@"resetBanned" withParameters:data block:^(id object, NSError *err) {
            if (err) {
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[err localizedDescription] finish:nil];
            } else {
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self onback:nil];
                }];
            }
        }];
    }];
    [alert addButton:@"Cancel" actionBlock:^(void) {
        
    }];
    [alert showError:@"Ban User" subTitle:@"Are you sure want to ban this user?" closeButtonTitle:nil duration:0.0f];
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
