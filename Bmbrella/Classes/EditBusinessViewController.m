//
//  EditBusinessViewController.m
//  Bmbrella
//
//  Created by Vitaly's Team on 10/30/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "EditBusinessViewController.h"
#import "CircleImageView.h"
#import <GooglePlaces/GooglePlaces.h>
#import "CountryListViewController.h"

@interface EditBusinessViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, CountryListViewDelegate>
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIImageView *imgBg;
    IBOutlet UITextField *txtRepassword;
    IBOutlet UITextField *txtCompanyName;
    IBOutlet UITextField *txtLocation;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtEmail;
    IBOutlet UIPlaceHolderTextView *txtDescription;
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UILabel *lblAddress;
    
    PFUser *me;
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    BOOL isChangedLocation;
    IBOutlet UIImageView *imgBackground;
    IBOutlet UIButton *btnPhoneCode;
    NSString *phone_code;
    IBOutlet UITextField *txtPhone;
}
@end

@implementation EditBusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:imgBg];
    me = [PFUser currentUser];
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
    txtDescription.placeholder = LOCALIZATION(@"brief_description");
    [Util setImage:imgAvatar imgFile:(PFFile *)me[PARSE_USER_AVATAR]];
    imgAvatar.delegate = self;
    txtEmail.enabled = NO;
    [Util setBorderView:imgAvatar color:[UIColor whiteColor] width:1.0];
    
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initData {
    lblTitle.text = LOCALIZATION(@"edit_profile");
    txtCompanyName.text = me[PARSE_USER_COMPANY_NAME];
    txtLocation.text = me[PARSE_USER_ADDRESS];
    lblAddress.text = me[PARSE_USER_ADDRESS];
    txtLocation.hidden = YES;
    txtDescription.text = me[PARSE_USER_DESCRIPTION];
    txtEmail.text = me.username;
    txtPassword.text = [Util getLoginUserPassword];
    txtRepassword.text = [Util getLoginUserPassword];
    phone_code = me[PARSE_USER_PHONE_CODE];
    if (phone_code == nil || phone_code.length == 0){
        phone_code = @"+1";
    }
    [btnPhoneCode setTitle:phone_code forState:UIControlStateNormal];
    
    if (me[PARSE_USER_PHONE_NUMBER]){
        NSString *full_number = me[PARSE_USER_PHONE_NUMBER];
        txtPhone.text = [full_number stringByReplacingOccurrencesOfString:phone_code withString:@""];
    }

    
    if ([me.username containsString:@"+"]){
        txtEmail.text = @"";
    }
}

- (IBAction)onPhoneCode:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:nil];
}

- (void) didSelectCountry:(NSDictionary *)country{
    [btnPhoneCode setTitle:[NSString stringWithFormat:@"%@", country[@"dial_code"]] forState:UIControlStateNormal];
    phone_code = [Util clearString:country[@"dial_code"]];
}


- (IBAction)onDone:(id)sender {
    if (![self isValid]){
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    me[PARSE_USER_COMPANY_NAME] = txtCompanyName.text;
    if (txtLocation.text.length > 0){
        me[PARSE_USER_ADDRESS] = txtLocation.text;
    }
    if (txtDescription.text.length>0){
        me[PARSE_USER_DESCRIPTION] = txtDescription.text;
    }
    
    txtPhone.text = [Util trim:txtPhone.text];
    if (txtPhone.text.length>0){
        me[PARSE_USER_PHONE_NUMBER] = [NSString stringWithFormat:@"%@%@", phone_code, txtPhone.text];
        me[PARSE_USER_PHONE_CODE] = phone_code;
    }
    
    if (hasPhoto) {
        UIImage *profileImage = [Util getUploadingImageFromImage:imgAvatar.image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        me[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
    }
    me.username = txtEmail.text;
    me[PARSE_USER_EMAIL] = txtEmail.text;
    me.username = txtEmail.text;
    me[PARSE_USER_PASSWORD] = txtPassword.text;
    me.password = txtPassword.text;
    me[PARSE_USER_PRE_PASSWORD] = txtPassword.text;
    if (isChangedLocation){
        me[PARSE_USER_LOCATION] = lonLat;
        me[PARSE_USER_ADDRESS] = lblAddress.text;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            me = [me fetch];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:[error localizedDescription] finish:^(void){
                [self initData];
            }];
        } else {
            [Util showAlertTitle:self title:@"" message:LOCALIZATION(@"success") finish:^(void){
                [Util setLoginUserName:txtEmail.text password:txtPassword.text];
                [self onback:nil];
            }];
        }
    }];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onlocation:(id)sender {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    txtCompanyName.text = [Util trim:txtCompanyName.text];
    txtDescription.text = [Util trim:txtDescription.text];
    
    NSString *companyName = txtCompanyName.text;
    NSString *description = txtDescription.text;
    NSString *email = txtEmail.text;
    NSString *password = txtPassword.text;
    NSString *rePwd = txtRepassword.text;
    
    [self removeHighlight];
    int errCount = 0;
    if (email.length == 0 || ![email isEmail]){
        [Util setBorderView:txtEmail color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (password.length == 0){
        [Util setBorderView:txtPassword color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (rePwd.length == 0){
        [Util setBorderView:txtRepassword color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (![password isEqualToString:rePwd]){
        [Util setBorderView:txtRepassword color:[UIColor redColor] width:0.6];
        [Util setBorderView:txtPassword color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (companyName.length < 2 || companyName.length > 50){
        [Util setBorderView:txtCompanyName color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (description.length > 1000){
        [Util setBorderView:txtDescription color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
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
    [Util setBorderView:txtEmail color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtPassword color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtRepassword color:[UIColor clearColor] width:0.6];
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

@end
