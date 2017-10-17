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
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    NSString *weekday = [formatter stringFromDate:_job.dateCompleted];
    [formatter setDateFormat:@"MMMM, d"];
    NSString *month = [formatter stringFromDate:_job.dateCompleted];
    date.text = [NSString stringWithFormat:@"%@\n%@",weekday,month];
    driveCount.text = [NSString stringWithFormat:@"%lu Drives",(unsigned long)_job.driveTimes.count];
    [References cornerRadius:videoPlayer radius:7.0f];
    [References cornerRadius:signatureImage radius:7.0f];
    [References cornerRadius:shareButton radius:7.0f];
    [References cornerRadius:closeButton radius:7.0f];
    [signatureImage setImage:[UIImage imageWithData:_job.signature]];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)share:(id)sender {
    [References fullScreenToast:@"Coming Soon" inView:self withSuccess:NO andClose:NO];
}
@end
