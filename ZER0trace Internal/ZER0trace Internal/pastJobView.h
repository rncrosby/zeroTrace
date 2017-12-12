//
//  pastJobView.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/16/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "jobObject.h"
#import "References.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CTVideoPlayerView/CTVideoViewCommonHeader.h>

@interface pastJobView : UIViewController <UIPopoverControllerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate> {
    UIPopoverController *popover;
    NSString *dateText;
    CTVideoView *videoView;
    __weak IBOutlet UIView *videoPlayer;
    __weak IBOutlet UILabel *date;
    __weak IBOutlet UILabel *driveCount;
    __weak IBOutlet UIImageView *signatureImage;
    __weak IBOutlet UIButton *shareButton;
    __weak IBOutlet UIButton *closeButton;
}
@property (nonatomic) AVPlayer *avPlayer;
@property (nonatomic, strong) jobObject *job;
- (IBAction)close:(id)sender;
- (IBAction)share:(id)sender;

@end
