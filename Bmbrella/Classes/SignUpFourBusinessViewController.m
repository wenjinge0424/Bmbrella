//
//  SignUpFourBusinessViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SignUpFourBusinessViewController.h"
#import "MainViewController.h"
#import "RootViewController.h"
#import "CircleImageView.h"
#import <GooglePlaces/GooglePlaces.h>
#import "SignupPhoneVerifyViewController.h"
#import "CountryListViewController.h"

@interface SignUpFourBusinessViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, CountryListViewDelegate>
{
    IBOutlet UIPlaceHolderTextView *txtDescription;
    
    IBOutlet UITextField *txtCompanyName;
    IBOutlet UITextField *txtPhoneNumber;
    IBOutlet UITextField *txtLocation;
    IBOutlet UITextField *txtTitle;
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UIImageView *imgback;
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    IBOutlet UILabel *lblAddress;
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    IBOutlet UIImageView *bg_loc;
    IBOutlet UIImageView *imgBackground;
    
    
    IBOutlet UIButton *btnCode;
    NSString *phone_code;
}
@end

@implementation SignUpFourBusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    imgAvatar.delegate = self;
    [Util setCornerView:imgback];
    txtDescription.placeholder = LOCALIZATION(@"brief_description");
    txtDescription.placeholderColor = [UIColor lightGrayColor];
    [Util setCornerView:txtDescription];
    [Util setBorderView:txtDescription color:[UIColor blackColor] width:1.0];
    
    txtCompanyName.delegate = self;
    txtLocation.delegate = self;
    
    txtPhoneNumber.delegate = self;
    
    phone_code = @"+1";
    
    NSString *phone = self.user[PARSE_USER_PHONE_NUMBER];
    if (phone.length != 0){
        phone_code = self.user[PARSE_USER_PHONE_CODE];
        phone = [phone stringByReplacingOccurrencesOfString:phone_code withString:@""];
        txtPhoneNumber.text = phone;
        txtPhoneNumber.enabled = NO;
        [btnCode setTitle:phone_code forState:UIControlStateNormal];
    }
   
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
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
                     self.user[PARSE_USER_LOCATION] = geoPoint;
                     self.user[PARSE_USER_ADDRESS] = placeName;
                     lblAddress.text = placeName;
                     txtLocation.hidden = YES;
                     lonLat = geoPoint;
                     [SVProgressHUD dismiss];
                 }
             }];
        }
    }];
}

- (IBAction)onPhoneCode:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:nil];
}

- (void) didSelectCountry:(NSDictionary *)country{
    //    [btnCode setTitle:[NSString stringWithFormat:@"%@ %@", country[@"code"], country[@"dial_code"]] forState:UIControlStateNormal];
    [btnCode setTitle:[NSString stringWithFormat:@"%@", country[@"dial_code"]] forState:UIControlStateNormal];
    phone_code = [Util clearString:country[@"dial_code"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSignUp:(id)sender {
    if (![self isValid]){
        return;
    }
    
    
    self.user[PARSE_USER_COMPANY_NAME] = txtCompanyName.text;
    if (txtPhoneNumber.text.length > 0){
        self.user[PARSE_USER_PHONE_NUMBER] = [NSString stringWithFormat:@"%@%@", phone_code, txtPhoneNumber.text];
        self.user[PARSE_USER_PHONE_CODE] = phone_code;
    }
    else{
        self.user[PARSE_USER_PHONE_NUMBER] = @"";
    }
    self.user[PARSE_USER_FRIEND_LIST] = [NSMutableArray new];
//    if (zipCode.length > 0)
//        self.user[PARSE_USER_ZIP_CODE] = zipCode;
//    else
        self.user[PARSE_USER_ZIP_CODE] = @"";
    if (city != nil && city.length > 0)
        self.user[PARSE_USER_CITY] = city;
    self.user[PARSE_USER_ADDRESS] = lblAddress.text;
    self.user[PARSE_USER_LOCATION] = lonLat;
    self.user[PARSE_USER_IS_BANNED] = @NO;
    if (txtDescription.text.length>0){
        self.user[PARSE_USER_DESCRIPTION] = txtDescription.text;
    } else {
        self.user[PARSE_USER_DESCRIPTION] = @"";
    }
    
    if (!hasPhoto){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
            [self signUp];
        }];
        [alert addButton:LOCALIZATION(@"upload_photo") actionBlock:^(void) {
            [self tapCircleImageView];
        }];
        [alert showError:LOCALIZATION(@"sign_up") subTitle:LOCALIZATION(@"confirm_avatar") closeButtonTitle:nil duration:0.0f];
    } else {
        UIImage *profileImage = [Util getUploadingImageFromImage:imgAvatar.image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        self.user[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
        [self signUp];
    }
}

- (void) signUp{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util setLoginUserName:self.user[PARSE_USER_EMAIL] password:self.user[PARSE_USER_PASSWORD]];
            NSString *message = LOCALIZATION(@"success_sign_up");
            [Util showAlertTitle:self title:LOCALIZATION(@"success") message:message finish:^(void){
                RootViewController *vc = (RootViewController *)[Util getUIViewControllerFromStoryBoard:@"RootViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            NSString *errMsg = [error localizedDescription];
            if ([errMsg containsString:@"already exist"]){
                [self showErrorMsg:@"Account already exists for this email."];
            } else {
                [self showErrorMsg:errMsg];
            }
        }
    }];
}

- (BOOL) isValid {
    [self removeHighlight];
    txtCompanyName.text = [Util trim:txtCompanyName.text];
    txtDescription.text = [Util trim:txtDescription.text];
    txtPhoneNumber.text = [Util trim:txtPhoneNumber.text];
    txtTitle.text = [Util trim:txtTitle.text];
    
    NSString *companyName = txtCompanyName.text;
    NSString *description = txtDescription.text;
    NSString *address = lblAddress.text;
    NSString *title = txtTitle.text;
    NSString *phone = txtPhoneNumber.text;
    
    int errCount = 0;
    if (companyName.length < 2 || companyName.length > 50){
        [Util setBorderView:txtCompanyName color:[UIColor redColor] width:0.6];
        errCount++;
    }
    //    if (title.length < 2 || title.length > 50){
    //        [Util setBorderView:txtTitle color:[UIColor redColor] width:0.6];
    //        errCount++;
    //    }
    if (description.length > 1000){
        [Util setBorderView:txtDescription color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (address.length == 0){
        [Util setBorderView:bg_loc color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
//    if (phone.length == 0 || ![[NSString stringWithFormat:@"%@%@", phone_code, phone] isPhone]){
//        [Util setBorderView:txtPhoneNumber color:[UIColor redColor] width:0.6];
//        errCount++;
//    }
    
    
    if (errCount == 1){
        [self showErrorMsg:LOCALIZATION(@"err_single")];
        return NO;
    } else if (errCount > 1){
        [self showErrorMsg:LOCALIZATION(@"err_multi")];
        return NO;
    }
    return YES;
}

- (void) removeHighlight {
    [Util setBorderView:txtCompanyName color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtDescription color:[UIColor clearColor] width:0.6];
    [Util setBorderView:bg_loc color:[UIColor clearColor] width:0.6];
}


- (IBAction)onLocation:(id)sender {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:@"Unable to use GPS. Please check your permission in Settings > Privacy > Location Service"];
        } else {
            GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
            acController.delegate = self;
            double distance = 0.001;
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
            CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + distance, center.longitude + distance);
            CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - distance, center.latitude - distance);
            acController.autocompleteBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southWest];
            
            [self presentViewController:acController animated:YES completion:nil];
        }
    }];
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
    hasPhoto = YES;
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
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
        } else if ([type isEqualToString:@"locality"] || [type isEqualToString:@"administrative_area_level_1"]) {
            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
        } else if ([type isEqualToString:@"postal_code"]){
            zipCode = item.name;
        } else if ([type isEqualToString:@"country"]){
            placeName = [NSString stringWithFormat:@"%@, %@", placeName, item.name];
        }
    }
    lblAddress.text = placeName;
    lonLat = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
    [Util setBorderView:bg_loc color:[UIColor clearColor] width:0.6];
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

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [Util setBorderView:textField color:[UIColor clearColor] width:0.6];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //    if (textField == txtPhoneNumber){
    //        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
    //        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
    //                                                                               options:NSRegularExpressionCaseInsensitive
    //                                                                                 error:nil];
    //        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
    //                                                            options:0
    //                                                              range:NSMakeRange(0, [newString length])];
    //        if (numberOfMatches == 0)
    //            return NO;
    //    }
    return YES;
}

@end
