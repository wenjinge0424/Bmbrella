//
//  AddTextViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "AddTextViewController.h"
#import "TOCropViewController.h"
#import "IQDropDownTextField.h"

@interface AddTextViewController ()<TOCropViewDelegate, IQDropDownTextFieldDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *imgPost;
    
    IBOutlet UITextField *txtTitle;
    IBOutlet UIImageView *bg_background;
    IBOutlet UIView *viewContent;
    __weak IBOutlet IQDropDownTextField *edt_fontSize;
    
    UIView *clearView;
    NSInteger colorIndex;
    IBOutlet UIView *videoView;
    IBOutlet UIButton *btnPlay;
    BOOL isPlaying;
    BOOL isVideo;
    IBOutlet UIImageView *imgBackground;
    __weak IBOutlet UIButton *btn_font1;
    __weak IBOutlet UIButton *btn_font2;
    __weak IBOutlet UIButton *btn_font3;
    __weak IBOutlet UIButton *btn_font4;
    
    int currentFontSize;
}
@end

@implementation AddTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    imgPost.image = self.image;
    [Util setCornerView:imgPost];
    
    clearView = [[UIView alloc] initWithFrame:txtTitle.frame];
    [clearView setTag:501];
    [viewContent addSubview:clearView];
    
    colorIndex = -1;
    txtTitle.text = @"";
    
    isVideo = (self.videoData);
    if (isVideo){
        btnPlay.hidden = NO;
    } else {
        videoView.hidden = YES;
        imgPost.hidden = NO;
        btnPlay.hidden = YES;
    }
    
    currentFontSize = 19;
    NSMutableArray * fontSizeArray = [NSMutableArray new];
    for(int i=15;i<=50;i++){
        [fontSizeArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    edt_fontSize.itemList = fontSizeArray;
    edt_fontSize.delegate = self;
    
    [self onSelectFont1:nil];
    
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

-(void)textField:(nonnull IQDropDownTextField*)textField didSelectItem:(nullable NSString*)item
{
    currentFontSize = [item intValue];
    NSString * fontFamily = txtTitle.font.fontName;
    [txtTitle setFont:[UIFont fontWithName:fontFamily size:currentFontSize]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    txtTitle.hidden = NO;
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender {
    if (isVideo){
        [self addLayerToVideo];
    } else {
        txtTitle.text = [Util trim:txtTitle.text];
        if (txtTitle.text.length == 0){
            txtTitle.hidden = YES;
        } else {
            txtTitle.hidden = NO;
        }
        UIGraphicsBeginImageContextWithOptions(viewContent.bounds.size, viewContent.opaque, 0.0);
        [viewContent.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        TOCropViewController *vc = [[TOCropViewController alloc] initWithImage:img];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) addLayerToVideo{
    self.videoAsset = [AVAsset assetWithURL:self.videoUrl];
    // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration)
                        ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    // 4 - Get path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [SVProgressHUD showWithStatus:@"Processing..." maskType:SVProgressHUDMaskTypeClear];
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
//  https://www.raywenderlich.com/30200/avfoundation-tutorial-adding-overlays-and-animations-to-videos
    
    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFont:@"Helvetica-Bold"];
    [subtitle1Text setFontSize:36];
//    [subtitle1Text setFrame:txtTitle.frame];
    [subtitle1Text setFrame:CGRectMake(0, 0, size.width, 100)];
    
    [subtitle1Text setString:txtTitle.text];
    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    if (colorIndex != -1){
        [subtitle1Text setForegroundColor:[Util colorWithHexString:[COLOR_ARRAY objectAtIndex:colorIndex]].CGColor];
    } else {
        [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    }
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitle1Text];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}


- (void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Processing Failed"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        if (self.delegate){
                            [self.delegate setVideoUrl:outputURL];
                        }
                        [self onback:nil];
                    }
                });
            }];
        }
    }
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
            [self playVideo:self.videoUrl];
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

- (IBAction)onSelectFont1:(id)sender {
    btn_font1.selected = YES;
    btn_font2.selected = NO;
    btn_font3.selected = NO;
    btn_font4.selected = NO;
    txtTitle.font = [UIFont fontWithName:btn_font1.titleLabel.font.familyName size:currentFontSize];
    
}
- (IBAction)onSelectFont2:(id)sender {
    btn_font1.selected = NO;
    btn_font2.selected = YES;
    btn_font3.selected = NO;
    btn_font4.selected = NO;
    txtTitle.font = [UIFont fontWithName:btn_font2.titleLabel.font.familyName size:currentFontSize];
}
- (IBAction)onSelectFont3:(id)sender {
    btn_font1.selected = NO;
    btn_font2.selected = NO;
    btn_font3.selected = YES;
    btn_font4.selected = NO;
    txtTitle.font = [UIFont fontWithName:btn_font3.titleLabel.font.familyName size:currentFontSize];
}
- (IBAction)onSelectFont4:(id)sender {
    btn_font1.selected = NO;
    btn_font2.selected = NO;
    btn_font3.selected = NO;
    btn_font4.selected = YES;
    txtTitle.font = [UIFont fontWithName:btn_font4.titleLabel.font.familyName size:currentFontSize];
}

- (IBAction)onColorSelect:(id)sender {
    colorIndex = [sender tag] - 1;
    txtTitle.textColor = [Util colorWithHexString:[COLOR_ARRAY objectAtIndex:colorIndex]];
    [txtTitle setValue:[Util colorWithHexString:[COLOR_ARRAY objectAtIndex:colorIndex]] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([[touch view] tag] ==501 && [touch tapCount] == 2){
        [txtTitle becomeFirstResponder];
    }
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:viewContent];
    float x = location.x;
    float y = location.y;
    float w = txtTitle.frame.size.width;
    float h = txtTitle.frame.size.height;
    float h_b = viewContent.frame.size.height;
    float w_b = viewContent.frame.size.width;
    
    CGSize textSize = [[txtTitle text] sizeWithAttributes:@{NSFontAttributeName:[txtTitle font]}];
    CGFloat ww = textSize.width;
    if (ww == 0){
        textSize = [[NSString stringWithFormat:@"Text here"] sizeWithAttributes:@{NSFontAttributeName:[txtTitle font]}];
        ww = textSize.width;
    }
    
    if ( y<10 || y>h_b-h-5 || x<ww/2 || x>w_b - ww/2){
        return;
    }
    
    if ([[touch view] tag] == 501){
        txtTitle.center = location;
        NSLog(@"%f",location.x);
        [[touch view] setCenter:location];
    }
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    imgPost.image = image;
    [cropViewController.navigationController popViewControllerAnimated:YES];
    if (self.delegate){
//        if (!txtTitle.text){
//            txtTitle.text = @"";
//        }
//        [self.delegate setTitle:txtTitle.text];
//        [self.delegate setColor:colorIndex];
        [self.delegate setImage:imgPost.image];
    }
    [self onback:nil];
}

- (void) cropViewDidBecomeResettable:(TOCropView *)cropView {
}

//- (void) textFieldDidEndEditing:(UITextField *)textField {
//    [txtTitle removeFromSuperview];
//    txtTitle.frame = clearView.frame;
//    [viewContent addSubview:txtTitle];
//    [txtTitle setCenter:center];
//    NSLog(@"");
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
