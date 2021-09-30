//
//  MediaViewController.m
//  Bmbrella
//
//  Created by gao on 4/24/18.
//  Copyright © 2018 Mikolaj Kudumov. All rights reserved.
//

#import "MediaViewController.h"
#import "ASBPlayerScrubbing.h"
#import "LMMediaPlayerView.h"

@interface MediaViewController ()<LMMediaPlayerViewDelegate>
{
    IBOutlet UIImageView *imgPhoto;
    
    IBOutlet UIView *videoView;
    IBOutlet UIButton *btnPlay;
    IBOutlet UIImageView *imgBackground;
    BOOL isPlaying;
    IBOutlet UITextView *txtDescription;
    
    LMMediaPlayerView *playerView_;
}
@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL isVideo = NO;
    if (self.video){
        isVideo = YES;
    } else {
        isVideo = NO;
    }
    if (isVideo){// video
        videoView.hidden = NO;
        btnPlay.hidden = NO;
        [self onPlayVideo:nil];
    } else if (self.image) { // image
        videoView.hidden = YES;
        btnPlay.hidden = YES;
        imgPhoto.hidden = NO;
        [imgPhoto setImage:self.image];
    } else {
        videoView.hidden = YES;
        btnPlay.hidden = YES;
        imgPhoto.hidden = YES;
        txtDescription.hidden = NO;
        [Util setBorderView:txtDescription color:[UIColor whiteColor] width:1.0];
        [Util setCornerView:txtDescription];
        
        txtDescription.dataDetectorTypes = UIDataDetectorTypeNone;
        txtDescription.editable = NO;
        txtDescription.dataDetectorTypes = UIDataDetectorTypeLink;
        txtDescription.text = self.txtDescriptionString;
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appdidActive:) name:NOTIFICATION_ACTIVE object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appdidbackground:) name:NOTIFICATION_BACKGROUND object:nil];
}

- (void) appdidActive:(NSNotification *) notif {
    if (self.video){
        videoView.hidden = NO;
        if (playerView_.mediaPlayer){
            isPlaying = NO;
            [playerView_.mediaPlayer pause];
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
        }
    }
}

- (void) appdidbackground:(NSNotification *) notif {
    if (self.video){
        if (playerView_.mediaPlayer){
            isPlaying = NO;
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
            [playerView_.mediaPlayer pause];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}
- (void) initializeVideo
{
    if(!playerView_){
        playerView_ = [LMMediaPlayerView sharedPlayerView];
        playerView_.frame = videoView.bounds;
        playerView_.delegate = self;
        [playerView_ setHeaderViewHidden:YES];
        [playerView_ setFooterViewHidden:NO];
        playerView_.previousButton.hidden = YES;
        playerView_.nextButton.hidden = YES;
        
        playerView_.delegate = self;
        
        videoView.backgroundColor = [UIColor blackColor];
        playerView_.frame = videoView.bounds;
        [videoView addSubview:playerView_];
    }
}
#pragma mark - LMMediaPlayerViewDelegate

- (BOOL)mediaPlayerViewWillStartPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media
{
    return YES;
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

- (IBAction)onPlayVideo:(id)sender {
    videoView.hidden = NO;
    imgPhoto.hidden = YES;
    if (isPlaying){
        if (playerView_.mediaPlayer){
            [playerView_.mediaPlayer pause];
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
        }
    } else {
        if (playerView_.mediaPlayer){
            [playerView_.mediaPlayer play];
        } else {
            [self playVideo];
        }
//        [btnPlay setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
        [btnPlay setHidden:YES];
    }
    isPlaying = !isPlaying;
}

- (void) playVideo {
    if (self.video){
        [self showVideoMoment:self.video];
    }
}

- (void) showVideoMoment:(PFFile *)file
{
    if (!file){
        if (playerView_.mediaPlayer){
            isPlaying = NO;
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
//            [playerView_.mediaPlayer seekToTime:kCMTimeZero];
            [playerView_.mediaPlayer pause];
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
    [self initializeVideo];
    LMMediaItem *item = [[LMMediaItem alloc] initWithInfo:@{LMMediaItemInfoURLKey:[NSURL fileURLWithPath:filePath], LMMediaItemInfoContentTypeKey:@(LMMediaItemContentTypeVideo)}];
    [playerView_.mediaPlayer removeAllMediaInQueue];
    [playerView_.mediaPlayer addMedia:item];
    [playerView_.mediaPlayer play];
    [btnPlay setHidden:YES];
    isPlaying = YES;
}

- (void)playerItemDidReachEnd:(NSNotification *) notification // video end notificaton
{
//    [self.avplayer seekToTime:kCMTimeZero];
//    [self.avplayer pause];
    [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    isPlaying = NO;
    [btnPlay setHidden:NO];
    //    AVPlayerItem *process = [notification object];
    //    [process seekToTime:kCMTimeZero];
}

- (NSString *) getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
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
