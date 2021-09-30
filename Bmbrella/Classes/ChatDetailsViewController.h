//
//  ChatDetailsViewController.h
//  Bmbrella
//
//  Created by Vitaly's Team on 10/31/17.
//  Copyright © 2017 BrainyApps. All rights reserved.
//

#import "SuperViewController.h"
#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "DemoModelData.h"
#import "AppStateManager.h"

@class ChatViewController;
@protocol ChatViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ChatViewController *)vc;

@end

@interface ChatDetailsViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>
@property (strong, nonatomic) PFUser *toUser;
@property (strong, nonatomic) PFObject *room;
@property (strong, nonatomic) id<ChatViewControllerDelegate> delegateModal;

+ (ChatDetailsViewController *)getInstance;
- (void) setRoom:(PFObject *) room User:(PFUser *) user ;
@end
