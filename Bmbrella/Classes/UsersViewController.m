//
//  UsersViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "UsersViewController.h"
#import "UserDetailViewController.h"
#import "HTHorizontalSelectionList.h"

@interface UsersViewController ()<UITableViewDelegate, UITableViewDataSource, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    IBOutlet HTHorizontalSelectionList *topbarList;
}
@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    topbarList.delegate = self;
    topbarList.dataSource = self;
    topbarList.backgroundColor = [UIColor clearColor];
    
    topbarList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    topbarList.selectionIndicatorColor = MAIN_COLOR;
    
    [topbarList setTitleColor:MAIN_COLOR forState:UIControlStateHighlighted];
    [topbarList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [topbarList setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:17] forState:UIControlStateNormal];
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:20] forState:UIControlStateSelected];
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:20] forState:UIControlStateHighlighted];
    
    dataArray = [[NSMutableArray alloc] init];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshItems {
    dataArray = [[NSMutableArray alloc] init];
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        [tableview reloadData];
        return;
    }
    
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_TYPE notEqualTo:[NSNumber numberWithInteger:USER_TYPE_ADMIN]];
    [query orderByAscending:PARSE_USER_FULL_NAME];
    if (topbarList.selectedButtonIndex == 1){
        [query whereKey:PARSE_USER_IS_BANNED equalTo:[NSNumber numberWithBool:YES]];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [self showErrorMsg:[error localizedDescription]];
            [tableview reloadData];
        } else {
            dataArray = [[NSMutableArray alloc] init];
            for (PFUser *item in array){
                PFUser *user = [item fetchIfNeeded];
                [dataArray addObject:user];
            }
            
            NSArray * sortedArray = [dataArray sortedArrayUsingComparator:^NSComparisonResult(PFObject* obj1, PFObject * obj2){
                NSString * userName1 = [NSString stringWithFormat:@"%@", obj1[PARSE_USER_FULL_NAME]];
                int type1 = [obj1[PARSE_USER_TYPE] intValue];
                if (type1 != USER_TYPE_CUSTOMER){
                    userName1 = obj1[PARSE_USER_COMPANY_NAME];
                }
                NSString * userName2 = [NSString stringWithFormat:@"%@", obj2[PARSE_USER_FULL_NAME]];
                int type2 = [obj2[PARSE_USER_TYPE] intValue];
                if (type2 != USER_TYPE_CUSTOMER){
                    userName2 = obj2[PARSE_USER_COMPANY_NAME];
                }
                userName1 = [userName1 lowercaseString];
                userName2 = [userName2 lowercaseString];
                return [userName1 compare:userName2];
            }];
            dataArray = [[NSMutableArray alloc] initWithArray:sortedArray];
            
            [SVProgressHUD dismiss];
            [tableview reloadData];
        }
    }];
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
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellUser"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    PFUser *user = [dataArray objectAtIndex:indexPath.row];
    NSInteger type = [user[PARSE_USER_TYPE] integerValue];
    if (type == USER_TYPE_CUSTOMER){
        lblName.text = user[PARSE_USER_FULL_NAME];
    } else {
        lblName.text = user[PARSE_USER_COMPANY_NAME];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserDetailViewController *vc = (UserDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"UserDetailViewController"];
    vc.user = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return 2;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    if (index == 0){
        return @"All users";
    } else {
        return @"Banned users";
    }
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods
- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    [self refreshItems];
}
@end
