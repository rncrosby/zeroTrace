//
//  jobView.h
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import "driveCell.h"
#import "jobObject.h"
#import <CTVideoPlayerView/CTVideoViewCommonHeader.h>

@interface jobView : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate> {
    CTVideoView *videoView;
    __weak IBOutlet UIView *videoPlayer;    
    
    __weak IBOutlet UITextField *search;
    __weak IBOutlet UIButton *playButton;
    
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UIProgressView *progressBar;
}

@property (nonatomic) AVPlayer *avPlayer;
@property (nonatomic, assign) jobObject *job;
- (IBAction)playPause:(id)sender;
- (IBAction)enterFullScreen:(id)sender;

@end
