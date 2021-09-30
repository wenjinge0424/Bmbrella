//
//  EditPersonalViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "EditPersonalViewController.h"
#import "CircleImageView.h"
#import "IQDropDownTextField.h"
#import <GooglePlaces/GooglePlaces.h>
#import "CountryListViewController.h"

@interface EditPersonalViewController ()<CircleImageAddDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, CountryListViewDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet CircleImageView *imgAvatar;
    
    IBOutlet UITextField *txtFirstname;
    IBOutlet UITextField *txtTitle;
    IBOutlet UITextField *txtLocation;
    IBOutlet UILabel *lblAddress;
    IBOutlet UIImageView *bgSemi;
    IBOutlet UIPlaceHolderTextView *txtDescription;
    PFUser *me;
    IBOutlet UIButton *btnAddmore;
    IBOutlet UILabel *lblJob;
    
    IBOutlet UITableView *tableview;
    
    NSMutableArray *jobArray;
    NSMutableArray *companyArray;
    NSMutableArray *yearsArray;
    NSInteger counts;
    
    NSMutableArray *tmpjobArray;
    NSMutableArray *tmpcompanyArray;
    NSMutableArray *tmpyearsArray;
    
    BOOL isCamera;
    BOOL isGallery;
    
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    
    BOOL isChangedLocation;
    BOOL isChangedPhoto;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtRepassword;
    IBOutlet UIImageView *imgBackground;
    IBOutlet UITextField *txtPhone;
    IBOutlet UIButton *btnPhoneCode;
    NSString *phone_code;
    
    NSMutableArray * userFullNames;
}
@end

@implementation EditPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    me = [PFUser currentUser];
    [self initdata];
    imgAvatar.delegate = self;
    [Util setBorderView:imgAvatar color:[UIColor whiteColor] width:1.0];
    isChangedLocation = NO;
    isChangedPhoto = NO;
    
    txtFirstname.delegate = self;
    txtTitle.delegate = self;
    txtEmail.delegate = self;
    txtPassword.delegate = self;
    txtRepassword.delegate = self;
    
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
    
    userFullNames = [NSMutableArray new];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [userFullNames addObject:[NSString stringWithFormat:@"%@%@", owner[PARSE_USER_FIRST_NAME], owner[PARSE_USER_LAST_NAME]]];
            }
        }
    }];
}
- (BOOL) stringContainsInArray:(NSString*)str :(NSMutableArray*)array
{
    for(NSString * subString in array){
        if([str isEqualToString:subString]){
            return YES;
        }
    }
    return NO;
}
- (void) initdata {
    lblTitle.text = LOCALIZATION(@"edit_profile");
    [Util setImage:imgAvatar imgFile:(PFFile *)me[PARSE_USER_AVATAR]];
    txtFirstname.text = me[PARSE_USER_FIRST_NAME];
    txtTitle.text = me[PARSE_USER_TITLE];
    txtLocation.hidden = YES;
    lblAddress.text = me[PARSE_USER_ADDRESS];
    if(lblAddress.text.length == 0){
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
            if (error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Error" message:@"Unable to use GPS. Please check your permission in Settings > Privacy > Location Service"];
            } else {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                CLGeocoder* geocoder = [CLGeocoder new];
                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
                 {
                     if (error == nil && [placemarks count] > 0)
                     {
                         CLPlacemark *placemark = [placemarks lastObject];
                         NSString *placeName = [NSString stringWithFormat:@"%@, %@", placemark.name, placemark.country];
                         me[PARSE_USER_LOCATION] = geoPoint;
                         me[PARSE_USER_ADDRESS] = placeName;
                         txtLocation.hidden = YES;
                         lblAddress.text = placeName;
                         lonLat = geoPoint;
                         isChangedLocation = YES;
                         [SVProgressHUD dismiss];
                     }
                 }];
            }
        }];
    }
    [Util setCornerView:bgSemi];
    txtDescription.placeholder = LOCALIZATION(@"brief_description");
    txtDescription.placeholderColor = [UIColor blackColor];
    txtDescription.text = me[PARSE_USER_DESCRIPTION];
    [btnAddmore setTitle:LOCALIZATION(@"add_more") forState:UIControlStateNormal];
    lblJob.text = LOCALIZATION(@"job_experience");
    jobArray = me[PARSE_USER_POSITION];
    companyArray = me[PARSE_USER_JOB_COMPANY];
    yearsArray = me[PARSE_USER_YEARS];
    phone_code = me[PARSE_USER_PHONE_CODE];
    if (phone_code == nil || phone_code.length == 0){
        phone_code = @"+1";
    }
    [btnPhoneCode setTitle:phone_code forState:UIControlStateNormal];
    
    if (me[PARSE_USER_PHONE_NUMBER]){
        NSString *full_number = me[PARSE_USER_PHONE_NUMBER];
        txtPhone.text = [full_number stringByReplacingOccurrencesOfString:phone_code withString:@""];
    }
    
    
    
    if (!jobArray)
        jobArray = [[NSMutableArray alloc] init];
    if (!companyArray)
        companyArray = [[NSMutableArray alloc] init];
    if (!yearsArray)
        yearsArray = [[NSMutableArray alloc] init];
    counts = jobArray.count;
    
    tmpjobArray = [[NSMutableArray alloc] init];
    tmpyearsArray = [[NSMutableArray alloc] init];
    tmpcompanyArray = [[NSMutableArray alloc] init];
    
    for (int i=0;i<jobArray.count;i++){
        [tmpjobArray addObject:[jobArray objectAtIndex:i]];
        [tmpyearsArray addObject:[yearsArray objectAtIndex:i]];
        [tmpcompanyArray addObject:[companyArray objectAtIndex:i]];
    }
    
    txtEmail.text = [Util getLoginUserName];
    if ([[Util getLoginUserName] containsString:@"+"]){
        txtEmail.text = @"";
    }
    txtEmail.enabled = NO;
    txtPassword.text = [Util getLoginUserPassword];
    txtRepassword.text = [Util getLoginUserPassword];
    
    if([me.username isEqualToString:[NSString stringWithFormat:@"%@@bmbrella.com",txtPhone.text]]){
        [btnPhoneCode setUserInteractionEnabled:NO];
        [txtPhone setUserInteractionEnabled:NO];
        txtEmail.text = @"";
    }
    
    [tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPhoneCode:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:nil];
}

- (void) didSelectCountry:(NSDictionary *)country{
    [btnPhoneCode setTitle:[NSString stringWithFormat:@"%@", country[@"dial_code"]] forState:UIControlStateNormal];
    phone_code = [Util clearString:country[@"dial_code"]];
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

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender {
    if (![self isValid]){
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    me[PARSE_USER_FIRST_NAME] = txtFirstname.text;
    txtPhone.text = [Util trim:txtPhone.text];
    if (txtPhone.text.length>0){
        me[PARSE_USER_PHONE_NUMBER] = [NSString stringWithFormat:@"%@%@", phone_code, txtPhone.text];
        me[PARSE_USER_PHONE_CODE] = phone_code;
    }
    me[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@", txtFirstname.text];
    me[PARSE_USER_TITLE] = txtTitle.text;
    me[PARSE_USER_DESCRIPTION] = txtDescription.text;
    if (isChangedPhoto){
        UIImage *profileImage = [Util getUploadingImageFromImage:imgAvatar.image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        me[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
    }
    if (isChangedLocation){
        me[PARSE_USER_LOCATION] = lonLat;
        me[PARSE_USER_ADDRESS] = lblAddress.text;
    }
    
    me[PARSE_USER_POSITION] = tmpjobArray;
    me[PARSE_USER_JOB_COMPANY] = tmpcompanyArray;
    me[PARSE_USER_YEARS] = tmpyearsArray;
    [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            me = [me fetch];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription] finish:^(void){
                [self initdata];
            }];
        } else {
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"success") finish:^(void){
                [self onback:nil];
            }];
        }
    }];
}

- (BOOL) isValid {
    [self removeHighlight];
    txtFirstname.text = [Util trim:txtFirstname.text];
    txtTitle.text = [Util trim:txtTitle.text];
    txtDescription.text = [Util trim:txtDescription.text];
    txtEmail.text = [Util trim:txtEmail.text];
    
    NSString *firstName = txtFirstname.text;
    NSString *title = txtTitle.text;
    NSString *desc = txtDescription.text;
    NSString *email = txtEmail.text;
    NSString *password = txtPassword.text;
    NSString *rePassword = txtRepassword.text;
    
    int errCount = 0;
    if (firstName.length < 2 || firstName.length > 50){
        [Util setBorderView:txtFirstname color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (title.length < 2 || title.length > 50){
        [Util setBorderView:txtTitle color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (desc.length > 1000){
        [Util setBorderView:txtDescription color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (email.length == 0 || ![email isEmail]){
        [Util setBorderView:txtEmail color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (password.length < 6){
        [Util setBorderView:txtPassword color:[UIColor redColor] width:0.6];
        errCount++;
    }
//    if (![Util isContainsLowerCase:password]){
//        [Util setBorderView:txtPassword color:[UIColor redColor] width:0.6];
//        errCount++;
//    }
//    if (![Util isContainsUpperCase:password]){
//        [Util setBorderView:txtPassword color:[UIColor redColor] width:0.6];
//        errCount++;
//    }
//    if (![Util isContainsNumber:password]){
//        [Util setBorderView:txtPassword color:[UIColor redColor] width:0.6];
//        errCount++;
//    }
    if (rePassword.length < 6){
        [Util setBorderView:txtRepassword color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (![rePassword isEqualToString:password]){
        [Util setBorderView:txtPassword color:[UIColor redColor] width:0.6];
        [Util setBorderView:txtRepassword color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (errCount == 1){
        [self showErrorMsg:LOCALIZATION(@"err_single")];
        return NO;
    } else if (errCount > 1){
        [self showErrorMsg:LOCALIZATION(@"err_multi")];
        return NO;
    }
    if([self stringContainsInArray:[NSString stringWithFormat:@"%@", firstName] :userFullNames]){
        [self showErrorMsg:LOCALIZATION(@"err_dupli_name")];
        return NO;
    }
//    NSMutableArray *tmpArrayJob = [[NSMutableArray alloc] init];
//    NSMutableArray *tmpArrayYear = [[NSMutableArray alloc] init];
//    NSMutableArray *tmpArrayCompany = [[NSMutableArray alloc] init];
    
    tmpjobArray = [[NSMutableArray alloc] init];
    tmpyearsArray = [[NSMutableArray alloc] init];
    tmpcompanyArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i=0;i<counts;i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
        UITextField *txtPosition = (UITextField *)[cell viewWithTag:1];
        UITextField *txtCompany = (UITextField *)[cell viewWithTag:2];
        IQDropDownTextField *txtYear = (IQDropDownTextField *)[cell viewWithTag:3];
        NSString *job = [Util trim:txtPosition.text];
        NSString *company = [Util trim:txtCompany.text];
        NSString *year = [Util trim:txtYear.selectedItem];
        if (job.length != 0 && company.length != 0 && year != 0){
            [tmpjobArray addObject:job];
            [tmpyearsArray addObject:year];
            [tmpcompanyArray addObject:company];
        }
    }

    return YES;
}

- (void) removeHighlight {
    [Util setBorderView:txtFirstname color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtTitle color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtDescription color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtEmail color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtPassword color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtRepassword color:[UIColor clearColor] width:0.6];
}


- (IBAction)onAddMore:(id)sender {
//    NSInteger count = [tableview numberOfRowsInSection:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
//    [tableview beginUpdates];
//    [tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//    
//    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cellAddFood"];
//    UITextField *txtPosition = (UITextField *)[cell viewWithTag:1];
//    UITextField *txtCompany = (UITextField *)[cell viewWithTag:2];
//    IQDropDownTextField *txtYear = (IQDropDownTextField *)[cell viewWithTag:3];
//    txtPosition.text = @"";
//    txtCompany.text = @"";
//    txtYear.selectedRow = -1;
//    
//    counts++;
//    [tableview endUpdates];
//    [tableview setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    
    [tmpjobArray addObject:@""];
    [tmpcompanyArray addObject:@""];
    [tmpyearsArray addObject:@""];
    [tableview reloadData];
    counts++;
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
    return counts;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellJob"];
    UITextField *txtPosition = (UITextField *)[cell viewWithTag:1];
    UITextField *txtCompany = (UITextField *)[cell viewWithTag:2];
    IQDropDownTextField *txtYear = (IQDropDownTextField *)[cell viewWithTag:3];
    txtYear.itemList = [AppStateManager sharedInstance].JOB_YEAR;
    if (tmpjobArray.count > indexPath.row){
        txtPosition.text = [tmpjobArray objectAtIndex:indexPath.row];
        txtCompany.text = [tmpcompanyArray objectAtIndex:indexPath.row];
        txtYear.selectedItem = [tmpyearsArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void) tapCircleImageView {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"take_photo") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"choose_gallery") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    isGallery = YES;
    isCamera = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    isCamera = YES;
    isGallery = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    isChangedPhoto = YES;
    [imgAvatar setImage:image];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    txtLocation.hidden = YES;
    NSString *placeName = place.name;
    NSMutableArray *componenets = (NSMutableArray *)place.addressComponents;
    for (GMSAddressComponent *item in componenets){
        NSString *type = item.type;
        NSLog(@"%@", type);
        if ([type isEqualToString:@"city"]){
            city = item.name;
            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
        } else if ([type isEqualToString:@"locality"]) {
            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
        } else if ([type isEqualToString:@"postal_code"]){
            zipCode = item.name;
        } else if ([type isEqualToString:@"country"]){
            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
        }
    }
    lblAddress.text = placeName;
    lonLat = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
    isChangedLocation = YES;
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

#pragma mark - UITextField delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [Util setBorderView:textField color:[UIColor clearColor] width:0.6];
}
@end
