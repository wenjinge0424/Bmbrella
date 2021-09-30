//
//  MainViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "MainViewController.h"
#import "ProfileViewController.h"
#import "PostViewController.h"
#import "FriendsViewController.h"
#import "PostDetailViewController.h"
#import "AllCategoriesViewController.h"
#import "FeedCell.h"
#import "CircleImageView.h"
#import "FriendsListViewController.h"
#import "SettingsViewController.h"
#import "FriendsListViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import "ChatUsersViewController.h"
#import "RequestsViewController.h"
#import "RootViewController.h"

static MainViewController *_sharedViewController = nil;

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, FeedCellDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, PostDetailViewControllerDelegate>
{
    IBOutlet UILabel *lblTitle;
    
    NSMutableArray *dataArray;
    NSInteger currentCategory;
    IBOutlet UIView *viewContent;
    IBOutlet UITableView *tableview;
    
    IBOutlet UITextField *txtSearch;
    NSString *searchString;
    
    NSInteger rowCount;
    BOOL hideKeyboard, fromGoogle;
    IBOutlet UILabel *lblNoresult;
    IBOutlet UICollectionView *collectionview;
    IBOutlet UIImageView *ic_new_msg;
    IBOutlet UIImageView *imgBackground;
    IBOutlet UIImageView *ic_new_follow_req;
    IBOutlet UILabel *lblMsgCount;
    
    PFQuery *userQuery;
    PFGeoPoint *searchTarget;
    IBOutlet UIView *viewBack;
    
    BOOL needRefresh;
}
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    needRefresh = YES;
    _sharedViewController = self;
    
    dataArray = [[NSMutableArray alloc] init];
    currentCategory = 0;
    
    txtSearch.delegate = self;
    searchString = @"";
    rowCount = 0;
    
    hideKeyboard = NO;
    fromGoogle = NO;
    
    [Util setCornerView:viewBack];
    [Util setBorderView:viewBack color:[UIColor blackColor] width:1.0f];
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didSelectCategory:) name:NOTIFICATION_TAP_CATEGORY object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewMsg:) name:kChatReceiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRequest:) name:kReceivedFollowRequest object:nil];
    
    
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

- (void) onSearch {
    hideKeyboard = NO;
    [self onSearch:nil];
}

+ (MainViewController *) getInstance {
    return _sharedViewController;
}

- (void) receivedNewMsg:(NSNotification *) notif {
    lblMsgCount.text = [NSString stringWithFormat:@"%d", [AppStateManager sharedInstance].msgCount];
    lblMsgCount.hidden = NO;
    ic_new_msg.hidden = NO;
    [AppStateManager sharedInstance].msgCount++;
}

- (void) receivedRequest:(NSNotification *) notif {
    ic_new_follow_req.hidden = NO;
}

- (void) didSelectCategory:(NSNotification *) notif {
    NSDictionary *data = [notif userInfo];
    NSString *categoryIndex = [data objectForKey:@"category"];
    NSInteger index = [categoryIndex intValue] + 2;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [collectionview scrollToItemAtIndexPath:indexPath atScrollPosition:nil animated:YES];
    [self collectionView:collectionview didSelectItemAtIndexPath:indexPath];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshItems) name:kNewAdPosted object:nil];
    
    if (!fromGoogle){
//        txtSearch.text = @"";
//        searchString = @"";
        searchTarget = nil;
    } else {
//        fromGoogle = NO;
//        searchString = txtSearch.text;
    }
    if(needRefresh){
        [self refreshItems];
        
        [collectionview reloadData];
        [collectionview setContentOffset:CGPointZero];
        needRefresh = YES;
    }else{
        needRefresh = YES;
    }
}
- (void)PostDetailViewControllerDelegate_complete
{
    needRefresh = NO;
}

- (void) setContentOffset:(CGPoint)point
{
    [collectionview setContentOffset:CGPointZero];
    [tableview setContentOffset:CGPointZero];
}

- (void) viewWillDisappear:(BOOL)animated {
    hideKeyboard = YES;
    [self.view endEditing:YES];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kNewAdPosted object:nil];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLocation:(id)sender {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    
    PFUser *me = [PFUser currentUser];
    
    PFQuery *userQuery1 = [PFUser query];
    PFQuery *userQuery2 = [PFUser query];
    PFQuery *userQuery3 = [PFUser query];
    PFQuery *userQuery4 = [PFUser query];
    PFQuery *userQuery5 = [PFUser query];
    PFQuery *userQuery6 = [PFUser query];
    PFQuery *userQuery7 = [PFUser query];
    
    
    if (searchTarget != nil){
        fromGoogle = NO;
        [userQuery6 whereKey:PARSE_USER_LOCATION nearGeoPoint:searchTarget withinMiles:100];
        if (searchString.length > 0){
            [userQuery1 whereKey:PARSE_USER_ADDRESS matchesRegex:searchString modifiers:@"i"];
            [userQuery2 whereKey:PARSE_USER_CITY matchesRegex:searchString modifiers:@"i"];
            [userQuery3 whereKey:PARSE_USER_ZIP_CODE matchesRegex:searchString modifiers:@"i"];
            [userQuery4 whereKey:PARSE_USER_FULL_NAME matchesRegex:searchString modifiers:@"i"];
            [userQuery5 whereKey:PARSE_USER_COMPANY_NAME matchesRegex:searchString modifiers:@"i"];
            [userQuery7 whereKey:PARSE_USER_DESCRIPTION matchesRegex:searchString modifiers:@"i"];
            userQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery1, userQuery2, userQuery3, userQuery4, userQuery5, userQuery7, nil]];
        } else {
            userQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery6, nil]];
        }
        
        PFQuery * pUQuery = [PFQuery queryWithClassName:PARSE_TABLE_POST];
        [pUQuery whereKey:PARSE_POST_OWNER matchesQuery:userQuery];
        PFQuery * query = nil;
        if (searchString.length>0){
            PFQuery * pDQuery = [PFQuery queryWithClassName:PARSE_TABLE_POST];
            [pDQuery whereKey:PARSE_POST_DESCRIPTION matchesRegex:searchString modifiers:@"i"];
            PFQuery * pTQuery = [PFQuery queryWithClassName:PARSE_TABLE_POST];
            [pTQuery whereKey:PARSE_POST_TITLE matchesRegex:searchString modifiers:@"i"];
            query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:pTQuery, pDQuery, pUQuery, nil]];
        }else{
            query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:pUQuery, nil]];
        }
        [query whereKey:PARSE_POST_IS_PRIVATE notEqualTo:@YES];
        [query orderByDescending:PARSE_FIELD_CREATED_AT];
        [query includeKey:PARSE_POST_OWNER];
        if (currentCategory != 0){
            NSString *categoryString = [CATEGORY_BAR_ARRAY objectAtIndex:currentCategory];
            NSInteger categoryId = [CATEGORY_ARRAY indexOfObject:categoryString];
            if (categoryId != NSNotFound)
                [query whereKey:PARSE_POST_CATEGORY equalTo:[NSNumber numberWithInteger:categoryId]];
        }
        if (![Util isConnectableInternet]){
            [self showNetworkErr];
            return;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            [SVProgressHUD dismiss];
            dataArray = [[NSMutableArray alloc] init];
            if (error){
                [self showErrorMsg:[error localizedDescription]];
            } else {
                dataArray = (NSMutableArray *) array;
            }
            [tableview reloadData];
            [tableview setContentOffset:CGPointZero animated:YES];
            lblNoresult.hidden = !(dataArray.count == 0);
            searchTarget = nil;
        }];
        
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
            if (error){
                [SVProgressHUD dismiss];
                [self showErrorMsg:[error localizedDescription]];
            } else {
                
                me[PARSE_USER_LOCATION] = geoPoint;
                [me saveInBackground];
                [userQuery6 whereKey:PARSE_USER_LOCATION nearGeoPoint:geoPoint withinMiles:100];
                if (searchString.length > 0){
                    [userQuery1 whereKey:PARSE_USER_ADDRESS matchesRegex:searchString modifiers:@"i"];
                    [userQuery2 whereKey:PARSE_USER_CITY matchesRegex:searchString modifiers:@"i"];
                    [userQuery3 whereKey:PARSE_USER_ZIP_CODE matchesRegex:searchString modifiers:@"i"];
                    [userQuery4 whereKey:PARSE_USER_FULL_NAME matchesRegex:searchString modifiers:@"i"];
                    [userQuery5 whereKey:PARSE_USER_COMPANY_NAME matchesRegex:searchString modifiers:@"i"];
                    userQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery1, userQuery2, userQuery3, userQuery4, userQuery5, /* userQuery6, */ nil]];
                } else {
                    userQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery6, nil]];
                    
                }
                PFQuery * pUQuery = [PFQuery queryWithClassName:PARSE_TABLE_POST];
                [pUQuery whereKey:PARSE_POST_OWNER matchesQuery:userQuery];
                PFQuery * query = nil;
                if (searchString.length>0){
                    PFQuery * pDQuery = [PFQuery queryWithClassName:PARSE_TABLE_POST];
                    [pDQuery whereKey:PARSE_POST_DESCRIPTION matchesRegex:searchString modifiers:@"i"];
                    PFQuery * pTQuery = [PFQuery queryWithClassName:PARSE_TABLE_POST];
                    [pTQuery whereKey:PARSE_POST_TITLE matchesRegex:searchString modifiers:@"i"];
                    query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:pTQuery, pDQuery, pUQuery, nil]];
                }else{
                    query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:pUQuery, nil]];
                }
                [query whereKey:PARSE_POST_IS_PRIVATE notEqualTo:@YES];
                [query orderByDescending:PARSE_FIELD_CREATED_AT];
                [query includeKey:PARSE_POST_OWNER];
                if (currentCategory != 0){
                    NSString *categoryString = [CATEGORY_BAR_ARRAY objectAtIndex:currentCategory];
                    NSInteger categoryId = [CATEGORY_ARRAY indexOfObject:categoryString];
                    if (categoryId != NSNotFound)
                        [query whereKey:PARSE_POST_CATEGORY equalTo:[NSNumber numberWithInteger:categoryId]];
                }
                if (![Util isConnectableInternet]){
                    [SVProgressHUD dismiss];
                    [self showNetworkErr];
                    return;
                }
                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                    [SVProgressHUD dismiss];
                    dataArray = [[NSMutableArray alloc] init];
                    if (error){
                        [self showErrorMsg:[error localizedDescription]];
                    } else {
                        dataArray = (NSMutableArray *) array;
                    }
                    [tableview reloadData];
                    [tableview setContentOffset:CGPointZero animated:YES];
                    lblNoresult.hidden = !(dataArray.count == 0);
                }];
            }
        }];
    }
    
    
}

- (IBAction)onProfile:(id)sender {
    if (!ic_new_follow_req.hidden){
        ic_new_follow_req.hidden = YES;
        if ([AppStateManager sharedInstance].isRequest){
            RequestsViewController *vc = (RequestsViewController *)[Util getUIViewControllerFromStoryBoard:@"RequestsViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            FriendsViewController *vc = (FriendsViewController *)[Util getUIViewControllerFromStoryBoard:@"FriendsViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        ProfileViewController *vc = (ProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"ProfileViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)onFriends:(id)sender {
    //    FriendsListViewController *vc = (FriendsListViewController *)[Util getUIViewControllerFromStoryBoard:@"FriendsListViewController"];
    FriendsViewController *vc = (FriendsViewController *)[Util getUIViewControllerFromStoryBoard:@"FriendsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onPost:(id)sender {
    PostViewController *vc = (PostViewController *)[Util getUIViewControllerFromStoryBoard:@"PostViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger div = (NSInteger)(dataArray.count / 8);
    NSInteger remain = dataArray.count - 8 * div;
    if (remain == 0){
        rowCount = div;
        return div;
    } else {
        rowCount = div + 1;
    }
    return rowCount;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == rowCount - 1){
        NSInteger div = (NSInteger)(dataArray.count / 8);
        NSInteger remain = dataArray.count - 8 * div;
        if (remain == 0){
            return 900;
        } else if (remain == 1 || remain == 2){
            return 300;
        } else if (remain == 3 || remain == 4 || remain == 5){
            return 200 + 300;
        } else {
            return 900;
        }
    }
    return 900;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:@"cellPost"];
    cell.delegate = self;
    UIImageView *imgOne = (UIImageView *)[cell viewWithTag:1];
    UIImageView *imgTwo = (UIImageView *)[cell viewWithTag:2];
    UIImageView *imgThree = (UIImageView *)[cell viewWithTag:3];
    UIImageView *imgFour = (UIImageView *)[cell viewWithTag:4];
    UIImageView *imgFive = (UIImageView *)[cell viewWithTag:5];
    UIImageView *imgSix = (UIImageView *)[cell viewWithTag:6];
    UIImageView *imgSeven = (UIImageView *)[cell viewWithTag:7];
    UIImageView *imgEight = (UIImageView *)[cell viewWithTag:8];
    CircleImageView *imgAvatarOne = (CircleImageView *)[cell viewWithTag:401];
    UILabel *lblNameOne = (UILabel *)[cell viewWithTag:501];
    CircleImageView *imgAvatarTwo = (CircleImageView *)[cell viewWithTag:402];
    UILabel *lblNameTwo = (UILabel *)[cell viewWithTag:502];
    CircleImageView *imgAvatarThree = (CircleImageView *)[cell viewWithTag:403];
    UILabel *lblNameThree = (UILabel *)[cell viewWithTag:503];
    CircleImageView *imgAvatarFour = (CircleImageView *)[cell viewWithTag:404];
    UILabel *lblNameFour = (UILabel *)[cell viewWithTag:504];
    CircleImageView *imgAvatarFive = (CircleImageView *)[cell viewWithTag:405];
    UILabel *lblNameFive = (UILabel *)[cell viewWithTag:505];
    CircleImageView *imgAvatarSix = (CircleImageView *)[cell viewWithTag:406];
    UILabel *lblNameSix = (UILabel *)[cell viewWithTag:506];
    CircleImageView *imgAvatarSeven = (CircleImageView *)[cell viewWithTag:407];
    UILabel *lblNameSeven = (UILabel *)[cell viewWithTag:507];
    CircleImageView *imgAvatarEight = (CircleImageView *)[cell viewWithTag:408];
    UILabel *lblNameEight = (UILabel *)[cell viewWithTag:508];
    
    UIImageView *btnPlayOne = (UIImageView *)[cell viewWithTag:601];
    UIImageView *btnPlayTwo = (UIImageView *)[cell viewWithTag:602];
    UIImageView *btnPlayThree = (UIImageView *)[cell viewWithTag:603];
    UIImageView *btnPlayFour = (UIImageView *)[cell viewWithTag:604];
    UIImageView *btnPlayFive = (UIImageView *)[cell viewWithTag:605];
    UIImageView *btnPlaySix = (UIImageView *)[cell viewWithTag:606];
    UIImageView *btnPlaySeven = (UIImageView *)[cell viewWithTag:607];
    UIImageView *btnPlayEight = (UIImageView *)[cell viewWithTag:608];
    
    [Util setBorderView:imgOne color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgTwo color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgThree color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgFour color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgFive color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgSix color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgSeven color:[UIColor whiteColor] width:1];
    [Util setBorderView:imgEight color:[UIColor whiteColor] width:1];
    
    NSInteger index = 8 * indexPath.row;
    [self setPostCell:index :imgOne :(UIImageView *)[cell viewWithTag:101] :(UIButton *)[cell viewWithTag:201] :imgAvatarOne :lblNameOne :btnPlayOne];
    [self setPostCell:index+1 :imgTwo :(UIImageView *)[cell viewWithTag:102] :(UIButton *)[cell viewWithTag:202] :imgAvatarTwo :lblNameTwo :btnPlayTwo];
    [self setPostCell:index+2 :imgThree :(UIImageView *)[cell viewWithTag:103] :(UIButton *)[cell viewWithTag:203]:imgAvatarThree :lblNameThree :btnPlayThree];
    [self setPostCell:index+3 :imgFour :(UIImageView *)[cell viewWithTag:104] :(UIButton *)[cell viewWithTag:204]:imgAvatarFour :lblNameFour :btnPlayFour];
    [self setPostCell:index+4 :imgFive :(UIImageView *)[cell viewWithTag:105] :(UIButton *)[cell viewWithTag:205]:imgAvatarFive :lblNameFive :btnPlayFive];
    [self setPostCell:index+5 :imgSix :(UIImageView *)[cell viewWithTag:106] :(UIButton *)[cell viewWithTag:206]:imgAvatarSix :lblNameSix :btnPlaySix];
    [self setPostCell:index+6 :imgSeven :(UIImageView *)[cell viewWithTag:107] :(UIButton *)[cell viewWithTag:207]:imgAvatarSeven :lblNameSeven :btnPlaySeven];
    [self setPostCell:index+7 :imgEight :(UIImageView *)[cell viewWithTag:108] :(UIButton *)[cell viewWithTag:208]:imgAvatarEight :lblNameEight :btnPlayEight];
    
    return cell;
}

- (void) setPostCell:(NSInteger) index :(UIImageView *) imageView :(UIImageView *) shadow :(UIButton *)shareButton :(CircleImageView *) imgAvatar :(UILabel *) lblName :(UIImageView *)btnPlay{
    imageView.image = nil;
    if (dataArray.count == 1 && index == 0){
        PFObject *post = dataArray[index];
        PFObject *user = post[PARSE_POST_OWNER];
        [Util setImage:imageView imgFile:(PFFile *) post[PARSE_POST_IMAGE]];
        [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
        BOOL isVideo = [post[PARSE_POST_IS_VIDEO] boolValue];
        btnPlay.hidden = !isVideo;
        NSInteger type = [user[PARSE_USER_TYPE] integerValue];
        if (type == USER_TYPE_BUSINESS)
            lblName.text = user[PARSE_USER_COMPANY_NAME];
        else
            lblName.text = user[PARSE_USER_FULL_NAME];
        shadow.hidden = NO;
        shareButton.hidden = NO;
        imgAvatar.hidden = NO;
        lblName.hidden = NO;
        return;
    }
    if (index > dataArray.count - 1){
        shadow.hidden = YES;
        shareButton.hidden = YES;
        [Util setBorderView:imageView color:[UIColor clearColor] width:0.5];
        imgAvatar.hidden = YES;
        lblName.hidden = YES;
        btnPlay.hidden = YES;
        return;
    }
    if (dataArray[index]){
        PFObject *post = dataArray[index];
        PFObject *user = post[PARSE_POST_OWNER];
        [Util setImage:imageView imgFile:(PFFile *) post[PARSE_POST_IMAGE]];
        [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
        BOOL isVideo = [post[PARSE_POST_IS_VIDEO] boolValue];
        btnPlay.hidden = !isVideo;
        NSInteger type = [user[PARSE_USER_TYPE] integerValue];
        if (type == USER_TYPE_BUSINESS)
            lblName.text = user[PARSE_USER_COMPANY_NAME];
        else
            lblName.text = user[PARSE_USER_FULL_NAME];
        
        shadow.hidden = NO;
        shareButton.hidden = NO;
        imgAvatar.hidden = NO;
        lblName.hidden = NO;
    } else {
        shadow.hidden = YES;
        shareButton.hidden = YES;
        [Util setBorderView:imageView color:[UIColor clearColor] width:0.5];
        imgAvatar.hidden = YES;
        lblName.hidden = YES;
        btnPlay.hidden = YES;
    }
}

- (void) gotoPostDetailScene:(NSInteger )index{
    if (index > dataArray.count - 1){
        return;
    }
    if (dataArray[index]){
        PFObject *post = dataArray[index];
        PostDetailViewController *vc = (PostDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"PostDetailViewController"];
        vc.object = post;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) shareImage:(NSInteger) index {
    if (index > dataArray.count - 1){
        return;
    }
    if (dataArray[index]){
        NSMutableArray *activityItems = [[NSMutableArray alloc] init];
        PFObject *post = dataArray[index];
        PFFile *file = post[PARSE_POST_IMAGE];
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
    }
}

#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return CATEGORY_BAR_ARRAY.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellCategory" forIndexPath:indexPath];
    UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblCategory = (UILabel *)[cell viewWithTag:2];
    lblCategory.text = [CATEGORY_BAR_ARRAY objectAtIndex:indexPath.row];
    if (currentCategory == indexPath.row){
        [Util setBorderView:imgCategory color:[UIColor yellowColor] width:2];
    } else {
        [Util setBorderView:imgCategory color:[UIColor clearColor] width:2];
    }
    imgCategory.image = [UIImage imageNamed:[CATEGORY_IC_ARRAY objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    currentCategory = indexPath.row;
    
    if (indexPath.row == 1){
        [[RootViewController getInstance] setCurrentTab:TAB_CATEGORY];
        return;
    }
    
    // clear bounds
    for (NSInteger i=0;i<CATEGORY_BAR_ARRAY.count;i++){
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
        [Util setBorderView:imgCategory color:[UIColor clearColor] width:2];
    }
    // draw bound
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
    [Util setBorderView:imgCategory color:[UIColor yellowColor] width:2];
    
    if (indexPath.row == 0){
        txtSearch.text = @"";
        searchString = @"";
    }
    
    [self refreshItems];
}

#pragma FeedCellDelegate
- (void) onTapImageOne:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:index];
    
}

- (void) onTapImageTwo:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+1)];
}

- (void) onTapImageThree:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    if (dataArray.count < 2){  // I dont know this reason for the first image
        [self gotoPostDetailScene:index];
    } else {
        if (index + 2 > dataArray.count){ // I dont know this reason too for the last image
            [self gotoPostDetailScene:(dataArray.count-1)];
        } else {
            [self gotoPostDetailScene:(index+2)];
        }
    }
}

- (void) onTapImageFour:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+3)];
}

- (void) onTapImageFive:(FeedCell *)cell {
    
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    if (dataArray.count < 3){
        if (dataArray.count == 2){
            [self gotoPostDetailScene:index];
        } else {
            [self gotoPostDetailScene:(index+2)];
        }
    } else if (index + 2 == dataArray.count){
        [self gotoPostDetailScene:(index+1)];
    } else{
        [self gotoPostDetailScene:(index+4)];
    }
}

- (void) onTapImageSix:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+5)];
}

- (void) onTapImageSeven:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+6)];
}

- (void) onTapImageEight:(FeedCell *)cell {
    if (dataArray.count == 1){
        [self gotoPostDetailScene:0];
        return;
    }
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self gotoPostDetailScene:(index+7)];
}

- (void) onShareImageOne:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self shareImage:(index)];
}

- (void) onShareImageTwo:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self shareImage:(index+1)];
}

- (void) onShareImageThree:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self shareImage:(index+2)];
}

- (void) onShareImageFour:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self shareImage:(index+3)];
}

- (void) onShareImageFive:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self shareImage:(index+4)];
}

- (void) onShareImageSix:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self shareImage:(index+5)];
}

- (void) onShareImageSeven:(FeedCell *)cell {
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    NSInteger index = 8 * indexPath.row;
    [self shareImage:(index+6)];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtSearch){
        NSString * newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        searchString = newString;
        [self refreshItems];
    }
    return YES;
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (hideKeyboard){
        hideKeyboard = NO;
        return;
    }
    if (textField == txtSearch){
        txtSearch.text = [Util trim:txtSearch.text];
        searchString = txtSearch.text;
        [self refreshItems];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}
- (IBAction)onHome:(id)sender {
}
- (IBAction)onCategory:(id)sender {
    AllCategoriesViewController *vc = (AllCategoriesViewController *)[Util getUIViewControllerFromStoryBoard:@"AllCategoriesViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onSearch:(id)sender {
    [txtSearch becomeFirstResponder];
}
- (IBAction)onFriendsMenu:(id)sender {
    //    FriendsListViewController *vc = (FriendsListViewController *)[Util getUIViewControllerFromStoryBoard:@"FriendsListViewController"];
    //    vc.user = [PFUser currentUser];
    //    [self.navigationController pushViewController:vc animated:YES];
    
    [AppStateManager sharedInstance].msgCount = 1;
    
    ChatUsersViewController *vc = (ChatUsersViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatUsersViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    ic_new_msg.hidden = YES;
    lblMsgCount.hidden = YES;
}
- (IBAction)onSettings:(id)sender {
    ic_new_follow_req.hidden = YES;
    SettingsViewController *vc = (SettingsViewController *)[Util getUIViewControllerFromStoryBoard:@"SettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    NSString *placeName = place.name;
    //    NSMutableArray *componenets = (NSMutableArray *)place.addressComponents;
    //    for (GMSAddressComponent *item in componenets){
    //        NSString *type = item.type;
    //        NSLog(@"%@", type);
    //        if ([type isEqualToString:@"city"]){
    //            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
    //        } else if ([type isEqualToString:@"locality"]) {
    //            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
    //        } else if ([type isEqualToString:@"postal_code"]){
    //        }
    ////        else if ([type isEqualToString:@"country"]){
    ////            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
    ////        }
    //    }
    fromGoogle = YES;
    txtSearch.text = placeName;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
