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
#import <CTVideoPlayerView/CTVideoViewCommonHeader.h>

@interface pastJobView : UIViewController {
    CTVideoView *videoView;
    __weak IBOutlet UIView *videoPlayer;
}
@property (nonatomic) AVPlayer *avPlayer;
@property (nonatomic, assign) jobObject *job;

@end
