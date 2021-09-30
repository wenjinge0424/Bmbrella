//
//  InformViewController.m
//  OMG
//
//  Created by Vitaly's Team on 7/23/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "InformViewController.h"

@interface InformViewController ()
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIWebView *webview;
    
    IBOutlet UIImageView *imgBackground;
}
@end

@implementation InformViewController

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
    
    NSString *docName = @"";
    if (self.type == FLAG_TERMS_OF_SERVERICE){
        docName = @"termsofservice";
        lblTitle.text = @"Terms and Conditions";
    } else if (self.type == FLAG_PRIVACY_POLICY){
        docName = @"privacypolicy";
        lblTitle.text = @"Privacy Policy";
    } else if (self.type == FLAG_ABOUT_THE_APP){
        docName = @"aboutapp";
        lblTitle.text = @"About the App";
    }
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:docName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSStringEncodingConversionAllowLossy  error:nil];
    
//    [webview loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];

    [webview loadHTMLString:[NSString stringWithFormat:@"<html><body style=\"background:transparent\" text=\"#000000\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\">%@</body></html>", htmlString] baseURL: nil];

    [webview setBackgroundColor:[UIColor clearColor]];
    [webview setOpaque:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
