//
//  Config.h
//
//  Created by IOS7 on 12/16/14.
//  Copyright (c) 2014 iOS. All rights reserved.
//

#import "AppStateManager.h"
#import "Localisator.h"

#define UI_TEST                     NO

/* ***************************************************************************/
/* ***************************** Paypal config ********************************/
/* ***************************************************************************/
#define PAYPAL_APP_ID_SANDBOX       @"
#define PAYPAL_APP_ID_LIVE          @"
#define PAYPAL_IS_PRODUCT_MODE      YES
#define PAYPAL_APP_ID               (PAYPAL_IS_PRODUCT_MODE ? PAYPAL_APP_ID_LIVE : PAYPAL_APP_ID_SANDBOX)
#define PAYPAL_ENV                  (PAYPAL_IS_PRODUCT_MODE ? ENV_LIVE : ENV_SANDBOX)


/* ***************************************************************************/
/* ***************************** Stripe config ********************************/
/* ***************************************************************************/

#define STRIPE_KEY                              @""
//#define STRIPE_KEY                              @""
#define STRIPE_URL                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                          @"charges"
#define STRIPE_CUSTOMERS                        @"customers"
#define STRIPE_TOKENS                           @"tokens"
#define STRIPE_ACCOUNTS                         @"accounts"
#define STRIPE_CONNECT_URL                      @"https://dindinspins.brainyapps.tk"


#define APP_NAME                                                @"BmBrella"
#define APP_ID                                                  @"1316881441"
#define PARSE_FETCH_MAX_COUNT                                   10000
#define APP_THEME                                               [AppStateManager sharedInstance].app_theme
//#define APP_THEME                                                @"business"
#define APP_TEHME_CUSTOMER                                      @"customer"
#define APP_THEME_BUSINESS                                      @"business"

#define WEB_END_POINT_ITEM_SEARCH_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemSearch"
#define WEB_END_POINT_ITEM_LOOKUP_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemLookup/%@"

#define AUTH_TOKEN_KEY                                          @"98c9c3d6-6c1e-4b8a-acd3-9177a1176d90"

/* Friend / SO status values */
#define FRIEND_INVITE_SEND                                      @"Invite"
#define FRIEND_INVITE_ACCEPT                                    @"Accept"
#define FRIEND_INVITE_REJECT                                    @"Reject"

#define SO_INVITE_SEND                                          @"SOInviteSend"
#define SO_INVITE_ACCEPT                                        @"SOInviteAccept"
#define SO_INVITE_REJECT                                        @"SOInviteReject"

/* Pending Type values */
#define PENDING_TYPE_FRIEND_INVITE                              @"Pending_Friend_Invite"
#define PENDING_TYPE_SO_SEND                                    @"Pending_SO_Send"
#define PENDING_TYPE_INTANGIBLE_SEND                            @"Pending_Intangible_Send"

// Push Notification
#define PARSE_CLASS_NOTIFICATION_FIELD_TYPE                     @"type"
#define PARSE_CLASS_NOTIFICATION_FIELD_DATAINFO                 @"dataInfo"
#define PARSE_NOTIFICATION_APP_ACTIVE                           @"app_active"

/* Pagination values  */
#define PAGINATION_DEFAULT_COUNT                                10000
#define PAGINATION_START_INDEX                                  1

/* IWant Type values */
#define IWANT_INTANGIBLE_CATEGORY                                @"Intangible"

/* Notification values */
#define NOTIFICATION_SHOW_PENDING_PAGE                          @"ShowPending"
#define NOTIFICATION_HIDE_PENDING_PAGE                          @"HidePending"

#define NOTIFICATION_SHOW_INPUTSO_PAGE                          @"ShowInputSO"
#define NOTIFICATION_HIDE_INPUTSO_PAGE                          @"HideInputSO"

#define NOTIFICATION_SHOW_INTANGIBLE_PAGE                       @"ShowIntangible"
#define NOTIFICATION_HIDE_INTANGIBLE_PAGE                       @"HideIntangible"

#define NOTIFICATION_SHOW_SOPREVIEW_PAGE                        @"ShowSOPreview"
#define NOTIFICATION_HIDE_SOPREVIEW_PAGE                        @"HideSOPreview"

#define MAIN_COLOR          [UIColor colorWithRed:82/255.f green:123/255.f blue:255/255.f alpha:1.f]
#define MAIN_BORDER_COLOR   [UIColor colorWithRed:186/255.f green:186/255.f blue:186/255.f alpha:1.f]
#define MAIN_BORDER1_COLOR  [UIColor colorWithRed:209/255.f green:209/255.f blue:209/255.f alpha:1.f]
#define MAIN_BORDER2_COLOR  [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:1.f]
#define MAIN_HEADER_COLOR   [UIColor colorWithRed:103/255.f green:103/255.f blue:103/255.f alpha:1.f]
#define MAIN_SWDEL_COLOR    [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
#define MAIN_DESEL_COLOR    [UIColor colorWithRed:206/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_HOLDER_COLOR   [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.f]
#define MAIN_TRANS_COLOR    [UIColor colorWithRed:204/255.f green:227/255.f blue:244/255.f alpha:1.f]

/* Page Notifcation */
#define NOTIFICATION_START_PAGE                                 @"StartMainPage"
#define NOTIFICATION_SIGNIN_PAGE                                @"SignInPage"
#define NOTIFICATION_PASSWDRESET_PAGE                           @"PasswdResetPage"
#define NOTIFICATION_WANTLIST_PAGE                              @"WantListPage"
#define NOTIFICATION_PROFILE_PAGE                               @"ProfilePage"
#define NOTIFICATION_FRIENDS_PAGE                               @"FriendsPage"
#define NOTIFICATION_INVITE_PAGE                                @"InvitePage"
#define NOTIFICATION_INSTRUCTIONS_PAGE                          @"InstructionsPage"
#define NOTIFICATION_NEWITEM_PAGE                               @"NewItemPage"
#define NOTIFICATION_NEWCATEGORY_PAGE                           @"NewCategoryPage"
#define NOTIFICATION_HIDENEW_PAGE                               @"HideNewPage"

/* Refresh Notifcation */
#define NOTIFICATION_CHANGED_PAGE                               @"ChangedPage"
#define NOTIFICATION_START_CHAT                                 @"StartNewChat"

/* Remote Notification Type values */
#define REMOTE_NF_TYPE_NEW_ITEM                                 @"New_Iwant_Item"
#define REMOTE_NF_TYPE_NEW_CATEGORY                             @"New_Category"
#define REMOTE_NF_TYPE_FRIEND_INVITE                            @"Friend_Invite"
#define REMOTE_NF_TYPE_INVITE_ACCEPT                            @"Invite_Result_Accept"
#define REMOTE_NF_TYPE_INVITE_REJECT                            @"Invite_Result_Reject"
#define REMOTE_NF_TYPE_CLICK_EMPTY_CATEGORY                     @"Click_Empty_Category"
#define kChatReceiveNotification                                @"ChatReceiveNotification"
#define kChatReceiveNotificationUsers                           @"ChatReceiveNotificationUsers"
#define kNewAdPosted                                            @"kNewAdPosted"
#define kReceivedFollowRequest                                  @"kReceivedFollowRequest"
#define kHomeTapped                                             @"kHomeTapped"

#define PUSH_NOTIFICATION_TYPE                                  @"type"

/* JCWheelView Notification */
#define NOTIFICATION_SPIN_STOP                                  @"spin_stopped"

/* Spin Notification Data */
#define SPIN_POINT_X                                             @"point_x"
#define SPIN_POINT_Y                                             @"point_y"

#define NOTIFICATION_ACTIVE                                     @"NOTIFICATION_ACTIVE"
#define NOTIFICATION_BACKGROUND                                 @"NOTIFICATION_BACKGROUND"
#define NOTIFICATION_TAP_CATEGORY                               @"NOTIFICATION_CATEGORY"
#define NOTIFICATION_TAP_READMORE                               @"NOTIFICATION_TAP_READMORE"

#define kGeoCodingString                                        @"http://maps.google.com/maps/geo?q=%f,%f&output=csv"

enum {
    USER_TYPE_CUSTOMER = 100,
    USER_TYPE_BUSINESS = 200,
    USER_TYPE_ADMIN = 300
};

enum {
    CHAT_TYPE_MESSAGE = 100,
    CHAT_TYPE_IMAGE = 200,
    CHAT_TYPE_VIDEO = 300
};

enum {
    PUSH_TYPE_CHAT = 1,
    PUSH_TYPE_BAN,
    PUSH_TYPE_NEW_POST,
    PUSH_TYPE_DEL_POST,
    PUSH_TYPE_FOLLOW_REQUEST,
    PUSH_TYPE_FOLLOW_ACCEPTED,
    PUSH_TYPE_UNFOLLOW,
    PUSH_TYPE_UNKNOWN
};

enum {
    FLAG_TERMS_OF_SERVERICE,
    FLAG_PRIVACY_POLICY,
    FLAG_ABOUT_THE_APP
};

enum {
    REPORT_TYPE_POST = 100,
    REPORT_TYPE_USER = 200
};

/* Multi Languages */
#define KEY_LANGUAGE                                            @"KEY_LANGUAGE"
#define KEY_LANGUAGE_EN                                         @"English_en"
#define KEY_LANGUAGE_FR                                         @"French_fr"
#define KEY_LANGUAGE_AR                                         @"Arabic_ar"
#define KEY_LANGUAGE_ES                                         @"Spanish_es"


/* Parse Table */
#define PARSE_FIELD_OBJECT_ID                                   @"objectId"
#define PARSE_FIELD_USER                                        @"user"
#define PARSE_FIELD_CHANNELS                                    @"channels"
#define PARSE_FIELD_CREATED_AT                                  @"createdAt"
#define PARSE_FIELD_UPDATED_AT                                  @"updatedAt"

/* User Table */
#define PARSE_TABLE_USER                                        @"User"
#define PARSE_USER_FIRST_NAME                                   @"firstName"
#define PARSE_USER_LAST_NAME                                    @"lastName"
#define PARSE_USER_FULL_NAME                                    @"fullName"
#define PARSE_USER_EMAIL                                        @"email"
#define PARSE_USER_DESCRIPTION                                  @"description"
#define PARSE_USER_PASSWORD                                     @"password"
#define PARSE_USER_USERNAME                                     @"username"
#define PARSE_USER_LOCATION                                     @"lonLat"
#define PARSE_USER_TYPE                                         @"type"
#define PARSE_USER_AVATAR                                       @"avatar"
#define PARSE_USER_ADDRESS                                      @"address"
#define PARSE_USER_TITLE                                        @"title"
#define PARSE_USER_EDUCATION                                    @"education"
#define PARSE_USER_POSITION                                     @"JobPosition"
#define PARSE_USER_JOB_COMPANY                                  @"JobCompany"
#define PARSE_USER_YEARS                                        @"JobYears"
#define PARSE_USER_COMPANY_NAME                                 @"CompanyName"
#define PARSE_USER_PHONE_CODE                                   @"PhoneCode"
#define PARSE_USER_PHONE_NUMBER                                 @"PhoneNumber"
#define PARSE_USER_PRE_PASSWORD                                 @"PrePassword"
#define PARSE_USER_FRIEND_LIST                                  @"friendList"
#define PARSE_USER_IS_BANNED                                    @"isBanned"
#define PARSE_USER_CITY                                         @"city"
#define PARSE_USER_ZIP_CODE                                     @"zipCode"

/* Post Table */
#define PARSE_TABLE_POST                                        @"Posts"
#define PARSE_POST_OWNER                                        @"owner"
#define PARSE_POST_IMAGE                                        @"image"
#define PARSE_POST_CATEGORY                                     @"category"
#define PARSE_POST_TITLE                                        @"title"
#define PARSE_POST_TITLE_COLOR                                  @"titleColor"
#define PARSE_POST_LIKES                                        @"liked"
#define PARSE_POST_IS_VIDEO                                     @"isVideo"
#define PARSE_POST_VIDEO                                        @"video"
#define PARSE_POST_DESCRIPTION                                  @"description"
#define PARSE_POST_COMMENT_COUNT                                @"commentCount"
#define PARSE_POST_IS_PRIVATE                                   @"isPrivate"

/* Chat Room */
#define PARSE_TABLE_CHAT_ROOM                                   @"ChatRoom"
#define PARSE_ROOM_SENDER                                       @"sender"
#define PARSE_ROOM_RECEIVER                                     @"receiver"
#define PARSE_ROOM_LAST_MESSAGE                                 @"lastMsg"
#define PARSE_ROOM_ENABLED                                      @"isAvailable"
#define PARSE_ROOM_IS_READ                                      @"isRead"
#define PARSE_ROOM_LAST_SENDER                                  @"message_sender"

/* Chat History */
#define PARSE_TABLE_CHAT_HISTORY                                @"ChatHistory"
#define PARSE_HISTORY_ROOM                                      @"room"
#define PARSE_HISTORY_SENDER                                    @"sender"
#define PARSE_HISTORY_RECEIVER                                  @"receiver"
#define PARSE_HISTORY_TYPE                                      @"type"
#define PARSE_HISTORY_MESSAGE                                   @"message"
#define PARSE_HISTORY_IMAGE                                     @"image"
#define PARSE_HISTORY_VIDEO                                     @"video"

/* Report Table */
#define PARSE_TABLE_REPORT                                      @"Report"
#define PARSE_REPORT_POST                                       @"post"
#define PARSE_REPORT_OWNER                                      @"owner"
#define PARSE_REPORT_REPORTER                                   @"reporter"
#define PARSE_REPORT_TYPE                                       @"type"
#define PARSE_REPORT_DESCRIPTION                                @"description"

/* Comment Table */
#define PARSE_TABLE_COMMENT                                     @"Comment"
#define PARSE_COMMENT_USER                                      @"user"
#define PARSE_COMMENT_POST                                      @"post"
#define PARSE_COMMENT_TEXT                                      @"comment"

/* Follow Table */
#define PARSE_TABLE_FOLLOW                                      @"Follow"
#define PARSE_FOLLOW_FROM                                       @"fromUser"
#define PARSE_FOLLOW_TO                                         @"toUser"
#define PARSE_FOLLOW_ACTIVE                                     @"isActive"

/* Notification Table */
#define PARSE_TABLE_NOTIFICATION                                @"Notification"
#define PARSE_NOTIFICATION_FROM                                 @"fromUser"
#define PARSE_NOTIFICATION_TO                                   @"toUser"
#define PARSE_NOTIFICATION_ISREAD                               @"isRead"
#define PARSE_NOTIFICATION_TYPE                                 @"type"
#define PARSE_NOTIFICATION_LINK                                 @"linkes"

#define SYSTEM_NOTIFICATION_TYPE_LIKE                           0
#define SYSTEM_NOTIFICATION_TYPE_COMMENT                        1



#define EDUCATION_ATTAINMENT               [[NSArray alloc] initWithObjects:@"Some High School", @"High School Diploma", @"Some College", @"Associate's Degree", @"Bachelor's Degree", @"Master's Degree", @"Doctorate Degree", nil]

#define CATEGORY_ARRAY                     [[NSArray alloc] initWithObjects:LOCALIZATION(@"cat_daycare"), LOCALIZATION(@"cat_health"), LOCALIZATION(@"cat_restaurant"), LOCALIZATION(@"cat_homemade"), LOCALIZATION(@"cat_hotels"), /*LOCALIZATION(@"cat_apartment"),*/ LOCALIZATION(@"cat_events"), LOCALIZATION(@"cat_news"), LOCALIZATION(@"cat_pet"), LOCALIZATION(@"cat_education"), LOCALIZATION(@"cat_vol"), /*LOCALIZATION(@"cat_coaching"),*/ LOCALIZATION(@"cat_fashion"), LOCALIZATION(@"cat_tech"), LOCALIZATION(@"cat_general"), LOCALIZATION(@"cat_travel"), LOCALIZATION(@"cat_beauty"), LOCALIZATION(@"cat_home_service"), LOCALIZATION(@"cat_arts"), LOCALIZATION(@"cat_cars"), LOCALIZATION(@"cat_entertainment"), LOCALIZATION(@"cat_homestay"), LOCALIZATION(@"cat_real"), LOCALIZATION(@"cat_sports"), LOCALIZATION(@"cat_others"), nil]


#define COLOR_ARRAY                        [[NSArray alloc] initWithObjects:@"#333333", @"#cf2a28", @"#ff9900", @"#ffff00", @"#069e10", @"#0cffff", @"#2978e4",@"#9804ff",@"#fe03ff",nil]

#define CATEGORY_BAR_ARRAY                     [[NSArray alloc] initWithObjects:LOCALIZATION(@"view_all_ads"), LOCALIZATION(@"view_all_cats"), LOCALIZATION(@"cat_daycare"), LOCALIZATION(@"cat_health"), LOCALIZATION(@"cat_restaurant"), LOCALIZATION(@"cat_homemade"), LOCALIZATION(@"cat_hotels"), /*LOCALIZATION(@"cat_apartment"),*/ LOCALIZATION(@"cat_events"), LOCALIZATION(@"cat_news"), LOCALIZATION(@"cat_pet"), LOCALIZATION(@"cat_education"), LOCALIZATION(@"cat_vol"), /*LOCALIZATION(@"cat_coaching"),*/ LOCALIZATION(@"cat_fashion"), LOCALIZATION(@"cat_tech"), LOCALIZATION(@"cat_general"), LOCALIZATION(@"cat_travel"), LOCALIZATION(@"cat_beauty"), LOCALIZATION(@"cat_home_service"), LOCALIZATION(@"cat_arts"), LOCALIZATION(@"cat_cars"), LOCALIZATION(@"cat_entertainment"), LOCALIZATION(@"cat_homestay"), LOCALIZATION(@"cat_real"), LOCALIZATION(@"cat_sports"), LOCALIZATION(@"cat_others"),  nil]


#define CATEGORY_IC_ARRAY                 [[NSArray alloc] initWithObjects:@"ic_cat_all_ads", @"ic_cat_view_all", @"ic_cat_daycard", @"ic_cat_health", @"ic_cat_rest", @"ic_cat_homemade", @"ic_cat_hotel", /*@"ic_cat_private",*/ @"ic_cat_event", @"ic_cat_news", @"ic_cat_pet", @"ic_cat_educ", @"ic_cat_vol", /*@"ic_cat_coach",*/ @"ic_cat_fashion", @"ic_cat_tech", @"ic_cat_general", @"ic_cat_travel", @"ic_cat_beauty", @"ic_cat_home", @"ic_cat_art", @"ic_cat_car", @"ic_cat_entertainment", @"ic_cat_private", @"ic_cat_real_est", @"ic_cat_sport", @"ic_cat_other",  nil]

#define CATEGORY_ICON_ARRAY                 [[NSArray alloc] initWithObjects: @"ic_cat_daycard", @"ic_cat_health", @"ic_cat_rest", @"ic_cat_homemade", @"ic_cat_hotel", /*@"ic_cat_private",*/ @"ic_cat_event", @"ic_cat_news", @"ic_cat_pet", @"ic_cat_educ", @"ic_cat_vol", /*@"ic_cat_coach",*/ @"ic_cat_fashion", @"ic_cat_tech", @"ic_cat_general", @"ic_cat_travel", @"ic_cat_beauty", @"ic_cat_home", @"ic_cat_art", @"ic_cat_car", @"ic_cat_entertainment", @"ic_cat_private", @"ic_cat_real_est", @"ic_cat_sport", @"ic_cat_other", nil]




