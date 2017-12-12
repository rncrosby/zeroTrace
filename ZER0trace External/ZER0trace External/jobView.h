//
//  jobView.h
//  ZER0trace External
//
//  Created by Robert Crosby on 12/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jobObject.h"
#import "References.h"
#import "driveCell.h"
#import <CTVideoPlayerView/CTVideoViewCommonHeader.h>
#import <CoreImage/CoreImage.h>

@interface jobView : UIViewController <UITableViewDataSource,UITableViewDelegate,CTVideoViewOperationDelegate> {
    bool isPlaying;
    int timeSincePlaying;
    __weak IBOutlet UILabel *date;
    __weak IBOutlet UIButton *backButton;
    CTVideoView *videoPlayer;
    UIView *videoView;
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UIButton *drives;
    __weak IBOutlet UILabel *drivesTitle;
    
    __weak IBOutlet UIButton *driveHead;
    __weak IBOutlet UISlider *slider;
    __weak IBOutlet UILabel *totalTime;
    __weak IBOutlet UILabel *currentTime;
    
    
    __weak IBOutlet UILabel *upperLine;
    __weak IBOutlet UILabel *lowerLine;
    __weak IBOutlet UILabel *signatureHeader;
    __weak IBOutlet UIImageView *signatureImage;
    __weak IBOutlet UIButton *playButton;
    __weak IBOutlet UILabel *bottomShadow;
    
    
}

@property (nonatomic, strong) jobObject *job;
- (IBAction)back:(id)sender;
- (IBAction)toggleVisibility:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)sliderChange:(id)sender;

@end
