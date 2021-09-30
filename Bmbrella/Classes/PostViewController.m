//
//  PostViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "PostViewController.h"
#import "IQDropDownTextField.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "NSString+Hyperlink.h"

@interface PostViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, SetDataDelegate, DBCameraViewControllerDelegate>
{
    IBOutlet IQDropDownTextField *txtCategory;
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIImageView *imgPost;
    UIImage * imageData;
    
    BOOL hadPhoto;
    BOOL hadVideo;
    BOOL isPhotoOpen;
    BOOL isCameraOpen;
    IBOutlet UIButton *btnEdit;
    IBOutlet UIButton *btnPost;
    
    NSURL *videoUrl;
    NSData *videoData;
    IBOutlet UIView *videoView;
    
    BOOL isVideo;
    BOOL isPhoto;
    IBOutlet UIButton *btnPlay;
    BOOL isPlaying;
    
    BOOL isAddedVideo;
    IBOutlet UIPlaceHolderTextView *txtDescription;
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtCategory.itemList = CATEGORY_ARRAY;
    self.colorIndex = 0;
    
    txtDescription.placeholder = @"Please enter your description.";
    [Util setBorderView:txtDescription color:[UIColor blackColor] width:1.0];
    [Util setCornerView:txtDescription];
    
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

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblTitle.text = LOCALIZATION(@"new_post");
    [btnPost setTitle:LOCALIZATION(@"post") forState:UIControlStateNormal];
}

- (IBAction)onPost:(id)sender {
    if (![self isValid]){
        return;
    }
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"public") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onSavePost:YES];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"only_for_you") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onSavePost:NO];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (NSArray*) getHyperLinkes:(NSString*)string
{
    NSError * error = nil;
    NSDataDetector * detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray * matches = [detector matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableArray * matchedStrings = [NSMutableArray new];
    for(int i=0;i<matches.count;i++){
        NSTextCheckingResult * textResult = [matches objectAtIndex:i];
        NSURL * url = textResult.URL;
        [matchedStrings addObject:url.absoluteString];
    }
    return matchedStrings;
}

- (void) onSavePost:(BOOL) isPublic {
    if (![self isValid]){
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_POST];
    object[PARSE_POST_OWNER] = [PFUser currentUser];
    object[PARSE_POST_LIKES] = [NSMutableArray new];
    object[PARSE_POST_DESCRIPTION] = txtDescription.text;
    object[PARSE_POST_COMMENT_COUNT] = [NSNumber numberWithInteger:0];
    object[PARSE_POST_CATEGORY] = [NSNumber numberWithInteger:txtCategory.selectedRow];
    object[PARSE_POST_IS_PRIVATE] = isPublic?@NO:@YES;
    UIImage *imgae = [Util getUploadingImageFromImage:imageData];
    NSData *imageData = UIImageJPEGRepresentation(imgae, 0.8);
    object[PARSE_POST_IMAGE] = [PFFile fileWithName:@"post.png" data:imageData];
    if (isVideo){
        if (self.avplayer){
            [self.avplayer pause];
            [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
            [btnPlay setHidden:NO];
        }
        object[PARSE_POST_VIDEO] = [PFFile fileWithName:@"video.mov" data:videoData];
        object[PARSE_POST_IS_VIDEO] = @YES;
    } else {
        object[PARSE_POST_IS_VIDEO] = @NO;
    }
    if (self.title.length > 0){
        object[PARSE_POST_TITLE] = self.title;
        object[PARSE_POST_TITLE_COLOR] = [NSNumber numberWithInteger:self.colorIndex];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            if (isPublic){
                // Send push
                NSString *fullName = @"";
                PFUser *me = [PFUser currentUser];
                if ([me[PARSE_USER_TYPE] integerValue] == USER_TYPE_CUSTOMER){
                    fullName = me[PARSE_USER_FULL_NAME];
                } else {
                    fullName = me[PARSE_USER_COMPANY_NAME];
                }
                NSMutableArray * friendList = [NSMutableArray new];
                for(PFUser * friend in me[PARSE_USER_FRIEND_LIST]){
                    [friendList addObject:friend.objectId];
                }
                
                
                NSString *pushMsg = [NSString stringWithFormat:@"%@ posted new Ad", fullName];
                NSDictionary *data = @{
                                       @"alert" : pushMsg,
                                       @"badge" : @"Increment",
                                       @"sound" : @"cheering.caf",
                                       @"email" : me.username,
                                       @"idlist" : friendList,
                                       @"type"  : [NSNumber numberWithInt:PUSH_TYPE_NEW_POST],
                                       };
                
                [PFCloud callFunctionInBackground:@"SendPushList" withParameters:data block:^(id object, NSError *err) {
                    if (err) {
                        NSLog(@"Fail APNS: %@", @"send ban push");
                    } else {
                        NSLog(@"Success APNS: %@", @"send ban push");
                    }
                }];
            }
            [self deleteVideo];
            
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"success") finish:^(void){
                [self onback:nil];
            }];
        }
    }];
}

- (BOOL) isValid {
    if (txtCategory.selectedRow == -1){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_category") finish:^(void){
            [txtCategory becomeFirstResponder];
        }];
        return NO;
    }
    if (!hadPhoto && !hadVideo){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_photo") finish:^(void){
            [self onAttachment:nil];
        }];
        return NO;
    }
    txtDescription.text = [Util trim:txtDescription.text];
    NSString *text = txtDescription.text;
//    if (text.length == 0){
//        [Util showAlertTitle:self title:@"Error" message:@"Please enter your description."];
//        return NO;
//    }
    return YES;
}

- (IBAction)onAttachment:(id)sender {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"upload_photo") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self openCamera];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"upload_video") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self openVideoCamera];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (void) openVideoCamera {
    isPhotoOpen = YES;
    isCameraOpen = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
    [self.parentViewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) openCamera {
    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [cameraContainer setFullScreenMode];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)onPlayVideo:(id)sender {
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
            [self playVideo:videoUrl];
        }
//        [btnPlay setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
        [btnPlay setHidden:YES];
    }
    isPlaying = !isPlaying;
    
    
}

- (void)playVideo:(NSURL *) url
{
    [self.avplayer pause];
    self.avplayer = nil;
    //play video
    self.avplayer = [AVPlayer playerWithURL:url];
    
    //    [self.avplayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    self.avplayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.avplayer setMuted:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avplayer currentItem]];
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    videoLayer.frame = CGRectMake(0, 0, videoView.bounds.size.width, videoView.bounds.size.height);
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [videoView.layer addSublayer:videoLayer];
    [self.avplayer play];
    
//    [btnPlay setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
    [btnPlay setHidden:YES];
    isPlaying = YES;
}

- (void)playerItemDidReachEnd:(NSNotification *) notification // video end notificaton
{
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer pause];
    [btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    [btnPlay setHidden:NO];
    isPlaying = NO;
}


- (IBAction)onEdit:(id)sender {
    if (!hadPhoto && !hadVideo){
        return;
    }
    AddTextViewController *vc = (AddTextViewController *)[Util getUIViewControllerFromStoryBoard:@"AddTextViewController"];
    vc.delegate = self;
    vc.image = imageData;
    vc.videoData = videoData;
    vc.videoUrl = videoUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (![Util isCameraAvailable] && isCameraOpen){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Camera"];
        return;
    }
    if (isPhotoOpen && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeMovie]){
        
        videoUrl = info[UIImagePickerControllerMediaURL];
        videoData = [NSData dataWithContentsOfURL:videoUrl];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){ // pick video from Libary
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
            CMTime new = playerItem.asset.duration;
            float seconds = CMTimeGetSeconds(new);
            NSLog(@"duration: %.2f", seconds);
        }
        
        float filesize = (float)videoData.length/1024.0f/1024.0f;
        NSLog(@"File size is : %.2f MB",filesize);
        
        if (filesize > 20.0){
            [Util showAlertTitle:self title:@"Error" message:@"You cannot upload larger than 20 MB"];
            return;
        }
        
        imgPost.hidden = NO;
        videoView.hidden = NO;
        btnPlay.hidden = NO;
        
        UIImage *image = [self getThumbnailWithUrl:videoUrl];
        imgPost.image = image;
        imageData = image;
        isVideo = YES;
        isPhoto = NO;
        
        hadPhoto = NO;
        hadVideo = YES;
        btnEdit.hidden = NO;
    }
}

- (UIImage *) getThumbnailWithUrl:(NSURL *) contentURL
{
    //    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:contentURL];
    //    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    //    player = nil;
    //    return thumbnail;
    AVAsset *asset = [AVAsset assetWithURL:contentURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbnail;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (![Util isPhotoAvaileble] && isPhotoOpen){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (![Util isCameraAvailable] && isCameraOpen){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Camera"];
        return;
    }
}

#pragma mark - AddTextViewDelegate
- (void) setTitle:(NSString *)title {
    self.title = title;
}

- (void)setColor:(NSInteger) colorIndex{
    self.colorIndex = colorIndex;
}

- (void)setImage:(UIImage *) image {
    if (image){
        imgPost.image = image;
        imageData = image;
    }
}

- (void) setVideoUrl:(NSURL *)url {
    videoUrl = url;
    videoData = [NSData dataWithContentsOfURL:videoUrl];
    imageData = [self getThumbnailWithUrl:videoUrl];
    imgPost.image = imageData;
    isAddedVideo = YES;
}

#pragma mark -DBCameraViewControllerDelegate
-(void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    imageData = image;
    imgPost.image = image;
    hadPhoto = YES;
    hadVideo = NO;
    videoUrl = nil;
    videoData = nil;
    btnEdit.hidden = NO;
    
    videoView.hidden = YES;
    btnPlay.hidden = YES;
    
    isVideo = NO;
    isPhoto = YES;
    if (isAddedVideo){
        [self deleteVideo];
        isAddedVideo = NO;
    }
}

- (void)dismissCamera:(id)cameraViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) deleteVideo{
    if (!isAddedVideo){
        return;
    }
    NSFileManager *fileManger = [NSFileManager defaultManager];
    [fileManger removeItemAtURL:videoUrl error:NULL];
}

@end
