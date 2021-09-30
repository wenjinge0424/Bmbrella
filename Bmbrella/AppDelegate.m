//
//  AppDelegate.m
//  PagaYa
//
//  Created by developer on 28/05/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
@import GoogleMaps;
@import GooglePlaces;
#import "ChatUsersViewController.h"
#import "ChatDetailsViewController.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Google configuration
    [GMSServices provideAPIKey:@""];
    [GMSPlacesClient provideAPIKey:@""];
    
    // parse configuration
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"";
        configuration.clientKey = @"";
        configuration.server = @"https://parse.brainyapps.com:20028/parse";
    }]];
    
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // Push Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                          options:options];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_BACKGROUND object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_ACTIVE object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSInteger pushType = [[userInfo objectForKey:PUSH_NOTIFICATION_TYPE] integerValue];
    application.applicationIconBadgeNumber = 0;
    
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    } else { // active status
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
    
    if (pushType == PUSH_TYPE_CHAT){
        if ([ChatDetailsViewController getInstance]){
            NSString *roomId = [userInfo objectForKey:@"data"];
            if ([roomId isEqualToString:[AppStateManager sharedInstance].chatRoomId]){
                [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationUsers object:userInfo];
            } else {
                [PFPush handlePush:userInfo];
                [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationUsers object:userInfo];
            }
        } /*else if ([ChatUsersViewController getInstance]){
            [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationUsers object:nil];
//            [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotification object:nil];
        }*/ else {
//            ChatUsersViewController *vc = (ChatUsersViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatUsersViewController"];
//            [self.rootNavigationViewController pushViewController:vc animated:YES];
//            [PFPush handlePush:userInfo];
            [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationUsers object:userInfo];
        }
    } else if (pushType == PUSH_TYPE_BAN){
        [Util showAlertTitle:self.rootNavigationViewController title:@"Notice" message:@"Admin banned you"];
        [SVProgressHUD showWithStatus:LOCALIZATION(@"loggin_out") maskType:SVProgressHUDMaskTypeGradient];
        [PFUser logOutInBackgroundWithBlock:^(NSError *error){
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            for (UIViewController *vc in [Util appDelegate].rootNavigationViewController.viewControllers){
                if ([vc isKindOfClass:[LoginViewController class]]){
                    [[Util appDelegate].rootNavigationViewController popToViewController:vc animated:YES];
                    break;
                }
            }
        }];
    } else if (pushType == PUSH_TYPE_NEW_POST || pushType == PUSH_TYPE_DEL_POST){
        [NSNotificationCenter.defaultCenter postNotificationName:kNewAdPosted object:nil];
    } else if (pushType == PUSH_TYPE_FOLLOW_REQUEST){
        [AppStateManager sharedInstance].isRequest = YES;
        [PFPush handlePush:userInfo];
        [NSNotificationCenter.defaultCenter postNotificationName:kReceivedFollowRequest object:nil];
    } else if (pushType == PUSH_TYPE_FOLLOW_ACCEPTED){
        [AppStateManager sharedInstance].isRequest = NO;
        [PFPush handlePush:userInfo];
        [NSNotificationCenter.defaultCenter postNotificationName:kReceivedFollowRequest object:nil];
    } else if (pushType == PUSH_TYPE_UNFOLLOW) {
        [PFPush handlePush:userInfo];
        
        NSString *objId = userInfo[@"data"];
        PFUser *me = [PFUser currentUser];
        NSMutableArray *friends = me[PARSE_USER_FRIEND_LIST];
        int index = -1;
        for (int i=0;i<friends.count;i++){
            PFUser *friend = friends[i];
            if ([friend.objectId isEqualToString:objId]){
                index = i;
            }
        }
        if (index != -1){
            [friends removeObjectAtIndex:index];
        }
        me[PARSE_USER_FRIEND_LIST] = friends;
        [me saveInBackground];
    }
}
@end
