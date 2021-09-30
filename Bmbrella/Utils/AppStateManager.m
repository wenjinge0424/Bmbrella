//
//  AppStateManager.m
//  Partner
//
//  Created by star on 12/8/15.
//  Copyright (c) 2015 zapporoo. All rights reserved.
//

#import "AppStateManager.h"
#import <AVFoundation/AVFoundation.h>


#define SOUND_VOLUME    1.0
#define INCOMING_SOUND  @"incoming_call_ring.wav"
#define OUTGOING_SOUND  @"outgoing_call_ring.wav"

static AppStateManager *sharedInstance = nil;

@interface AppStateManager() <AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
}
@end

@implementation AppStateManager

+ (AppStateManager *)sharedInstance {
    
    if (!sharedInstance) {
        sharedInstance = [[AppStateManager alloc] init];
        sharedInstance.alertCount = 0;
        sharedInstance.chatRoomId = @"";
        
        sharedInstance.msgCount = 1;
        sharedInstance.isRequest = NO;

        sharedInstance.JOB_YEAR = [[NSMutableArray alloc] init];
        for (int year = 0;year<51;year++){
            NSString *itemYear = @"";
            if (year == 0){
                itemYear = @"";
            } else if (year == 1){
                itemYear = [NSString stringWithFormat:@"%d Year", year];
            } else {
                itemYear = [NSString stringWithFormat:@"%d Years", year];
            }
            for (int month = 0;month<13;month++){
                NSString *item = itemYear;
                if (month == 0){
                    
                } else if (month == 1){
                    item = [NSString stringWithFormat:@"%@ %d Month", itemYear, month];
                } else {
                    item = [NSString stringWithFormat:@"%@ %d Months", itemYear, month];
                }
                if (item.length>0)
                    [sharedInstance.JOB_YEAR addObject:item];
            }
        }
    }
    
    return sharedInstance;
}

- (void)playIncomingSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    NSURL *urlPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], INCOMING_SOUND]];
    NSError *err = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPath error:&err];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.delegate = self;
    [audioPlayer setVolume:SOUND_VOLUME];
    [audioPlayer play];
}

- (void)playOutgoingSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    NSURL *urlPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], OUTGOING_SOUND]];
    NSError *err = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPath error:&err];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.delegate = self;
    [audioPlayer setVolume:SOUND_VOLUME];
    [audioPlayer play];
}

- (void)stopSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

- (void)resetAlertCount {
    self.alertCount = 0;
}

@end
