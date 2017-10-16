//
//  pastJobView.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/16/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "pastJobView.h"

@interface pastJobView ()

@end

@implementation pastJobView

- (void)viewDidLoad {
    videoView = [[CTVideoView alloc] init];
    videoView.frame = CGRectMake(-10,-10,videoPlayer.frame.size.width+20,videoPlayer.frame.size.height+20);
    [videoPlayer addSubview:videoView];
    [videoView setShouldPlayAfterPrepareFinished:NO];
    [videoView setIsMuted:YES];
    videoView.videoUrl = [NSURL URLWithString:_job.videoURL]; // mp4 playable
    [videoView prepare];
//    [NSTimer scheduledTimerWithTimeInterval:1.0f
//                                     target:self selector:@selector(videoProgressManager) userInfo:nil repeats:YES];
    [References cornerRadius:videoPlayer radius:7.0f];
    //[References cornerRadius:table radius:7.0f];
    //[References lightCardShadow:videoPlayer];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
