//
//  FeedCell.m
//  OMG
//
//  Created by Vitaly's Team on 7/22/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell

- (IBAction)onTapOne:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageOne:self];
    }
}

- (IBAction)onTapTwo:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageTwo:self];
    }
}

- (IBAction)onTapThree:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageThree:self];
    }
}

- (IBAction)onTapFour:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageFour:self];
    }
}

- (IBAction)onTapFive:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageFive:self];
    }
}

- (IBAction)onTapSix:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageSix:self];
    }
}

- (IBAction)onTapSeven:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageSeven:self];
    }
}
- (IBAction)onTapEight:(id)sender {
    if (self.delegate){
        [self.delegate onTapImageEight:self];
    }
}

- (IBAction)onShareOne:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageOne:self];
    }
}
- (IBAction)onShareTwo:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageTwo:self];
    }
}
- (IBAction)onShareThree:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageThree:self];
    }
}
- (IBAction)onShareFour:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageFour:self];
    }
}

- (IBAction)onShareFive:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageFive:self];
    }
}

- (IBAction)onShareSix:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageSix:self];
    }
}

- (IBAction)onShareSeven:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageSeven:self];
    }
}
- (IBAction)onShareEight:(id)sender {
    if (self.delegate){
        [self.delegate onShareImageSeven:self];
    }
}

@end
