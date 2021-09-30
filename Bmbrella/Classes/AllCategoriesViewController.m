//
//  AllCategoriesViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 11/14/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "AllCategoriesViewController.h"
#import "RootViewController.h"

@interface AllCategoriesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    
    IBOutlet UICollectionView *collectionview;
    IBOutlet UIView *viewContent;
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation AllCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellCategory" forIndexPath:indexPath];
    UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblCategory = (UILabel *)[cell viewWithTag:2];
    lblCategory.text = [CATEGORY_ARRAY objectAtIndex:indexPath.row];
    imgCategory.image = [UIImage imageNamed:[CATEGORY_ICON_ARRAY objectAtIndex:indexPath.row]];
    
    return cell;
}

- (NSInteger ) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return CATEGORY_ARRAY.count;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *row = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:row, @"category", nil];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_TAP_CATEGORY object:nil userInfo:dic];
    [[RootViewController getInstance] setCurrentTab:TAB_HOME];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = viewContent.frame.size.width / 4.0;
    CGFloat height = width * 4 / 3;
    return CGSizeMake(width, height);
}

@end
