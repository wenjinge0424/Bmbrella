//
//  SignUpFourViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/27/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SignUpFourViewController.h"
#import "SignUpFiveViewController.h"
#import "CircleImageView.h"
#import <GooglePlaces/GooglePlaces.h>
#import "SignupPhoneVerifyViewController.h"
#import "RootViewController.h"

@interface SignUpFourViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate>
{
    IBOutlet UITextField *txtFirstName;
    IBOutlet UITextField *txtTitle;
//    IBOutlet UITextField *txtPhone;
    IBOutlet UIPlaceHolderTextView *txtDescription;
//    IBOutlet UITextField *txtLocation;
//    IBOutlet UILabel *lblAddress;
    
    IBOutlet UIImageView *bgSemi;
    IBOutlet CircleImageView *imgAvatar;
//    IBOutlet UIImageView *bgPhone;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
//    IBOutlet UIImageView *bgLocation;
    
    NSMutableArray * userFullNames;
}
@end

@implementation SignUpFourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:bgSemi];
    imgAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    imgAvatar.layer.borderWidth = 1.f;
    imgAvatar.delegate = self;
    txtDescription.placeholderColor = [UIColor lightGrayColor];
    txtDescription.placeholder = LOCALIZATION(@"brief_description");
    [Util setCornerView:txtDescription];
    [Util setBorderView:txtDescription color:[UIColor blackColor] width:1.0];
    zipCode = @"";
    city = @"";
    
    txtFirstName.delegate = self;
    txtTitle.delegate = self;
    
//    NSString *phone = self.user[PARSE_USER_PHONE_NUMBER];
//    if (phone.length != 0){
//        txtPhone.text = phone;
//        txtPhone.enabled = NO;
//    }
    
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
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
    
    
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
//        if (error){
//            [SVProgressHUD dismiss];
//            [Util showAlertTitle:self title:@"Error" message:@"Unable to use GPS. Please check your permission in Settings > Privacy > Location Service"];
//        } else {
//            CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
//            CLGeocoder* geocoder = [CLGeocoder new];
//            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
//             {
//                 if (error == nil && [placemarks count] > 0)
//                 {
//                     CLPlacemark *placemark = [placemarks lastObject];
//                     NSString *placeName = [NSString stringWithFormat:@"%@, %@", placemark.name, placemark.country];
//                     self.user[PARSE_USER_LOCATION] = geoPoint;
//                     self.user[PARSE_USER_ADDRESS] = placeName;
//                     txtLocation.hidden = YES;
//                     lblAddress.text = placeName;
//                     lonLat = geoPoint;
//                     [SVProgressHUD dismiss];
//                 }
//             }];
//        }
//    }];
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

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    self.user[PARSE_USER_FIRST_NAME] = txtFirstName.text;
    self.user[PARSE_USER_LAST_NAME] = @"";
    self.user[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@", txtFirstName.text];
    self.user[PARSE_USER_TITLE] = txtTitle.text;
    if (txtDescription.text.length > 0)
        self.user[PARSE_USER_DESCRIPTION] = txtDescription.text;
    else
        self.user[PARSE_USER_DESCRIPTION] = @"";
//    self.user[PARSE_USER_LOCATION] = lonLat;
//    self.user[PARSE_USER_ADDRESS] = @"";
//    self.user[PARSE_USER_CITY] = city;
//    self.user[PARSE_USER_ZIP_CODE] = zipCode;
    NSString *phone = self.user[PARSE_USER_PHONE_NUMBER];
    if (phone.length > 0)
        self.user[PARSE_USER_PHONE_NUMBER] = phone;

    if (!hasPhoto){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:LOCALIZATION(@"yes") actionBlock:^(void) {
            [self gotoNext];
        }];
        [alert addButton:LOCALIZATION(@"upload_photo") actionBlock:^(void) {
            [self tapCircleImageView];
        }];
        [alert showError:LOCALIZATION(@"sign_up") subTitle:LOCALIZATION(@"confirm_avatar") closeButtonTitle:nil duration:0.0f];
    } else {
        UIImage *profileImage = [Util getUploadingImageFromImage:imgAvatar.image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        self.user[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
        [self gotoNext];
    }
}

- (void) gotoNext {
//    SignUpFiveViewController *vc = (SignUpFiveViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFiveViewController"];
//    vc.user = self.user;
//    [self.navigationController pushViewController:vc animated:YES];
    
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
    
//    RootViewController *vc = (RootViewController *)[Util getUIViewControllerFromStoryBoard:@"RootViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
    
//    if (![Util isConnectableInternet]){
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
//        return;
//    }
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//    NSDictionary *data = @{
//                           @"number" : txtPhone.text,
//                           };
//    [PFCloud callFunctionInBackground:@"phoneVerify" withParameters:data block:^(id object, NSError *err) {
//        [SVProgressHUD dismiss];
//        if (err) {
//            [self showErrorMsg:[err localizedDescription]];
//        } else {
//            NSString *code = [NSString stringWithFormat:@"%@", (NSString *)object];
//            SignupPhoneVerifyViewController *vc = (SignupPhoneVerifyViewController *)[Util getUIViewControllerFromStoryBoard:@"SignupPhoneVerifyViewController"];
//            vc.user = self.user;
//            vc.phoneCode = code;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }];
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
- (BOOL) isValid {
    [self removeHighlight];
    txtFirstName.text = [Util trim:txtFirstName.text];
    txtTitle.text = [Util trim:txtTitle.text];
    txtDescription.text = [Util trim:txtDescription.text];
//    txtPhone.text = [Util trim:txtPhone.text];
    
    NSString *firstName = txtFirstName.text;
    NSString *title = txtTitle.text;
    NSString *desc = txtDescription.text;
//    NSString *address = lblAddress.text;
//    NSString *phone = txtPhone.text;
    
    int errCount = 0;
    if (firstName.length < 2 || firstName.length > 50){
        [Util setBorderView:txtFirstName color:[UIColor redColor] width:0.6];
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
//    if (address.length == 0){
//        [Util setBorderView:bgLocation color:[UIColor redColor] width:0.6];
//        errCount++;
//    }
//    if (phone.length == 0 || ![phone isPhone]){
//        [Util setBorderView:txtPhone color:[UIColor redColor] width:0.6];
//        errCount++;
//    }
    
    
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
    return YES;
}

- (void) removeHighlight {
    [Util setBorderView:txtFirstName color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtTitle color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtDescription color:[UIColor lightGrayColor] width:1];
//    [Util setBorderView:bgLocation color:[UIColor clearColor] width:0.6];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
//    txtLocation.hidden = YES;
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
//    lblAddress.text = placeName;
//    lonLat = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
//    [Util setBorderView:bgLocation color:[UIColor clearColor] width:0.6];
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

# pragma mark UITextField delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [Util setBorderView:textField color:[UIColor clearColor] width:0.6];
}
@end
