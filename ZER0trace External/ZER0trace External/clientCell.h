//
//  clientCell.h
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "jobObject.h"
#import <CTVideoPlayerView/CTVideoViewCommonHeader.h>

@interface clientCell : UITableViewCell
@property (weak, nonatomic) NSNumber *hasPlayedVideo;
@property (retain, nonatomic) IBOutlet CTVideoView *videoPlayer;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *drives;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *code;
@property (weak, nonatomic) IBOutlet UILabel *timeCompleted;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *bottomBlur;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *videoControls;
@property (weak, nonatomic) IBOutlet UIScrollView *driveScroll;
@property (weak, nonatomic) IBOutlet UILabel *driveTime;
@property (weak, nonatomic) IBOutlet UIButton *driveButton;
@property (weak, nonatomic) IBOutlet UILabel *playTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;


@end
