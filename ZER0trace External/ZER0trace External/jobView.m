//
//  jobView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "jobView.h"

@interface jobView ()

@end

@implementation jobView

- (void)viewDidLoad {
    [super viewDidLoad];
    videoView = [[CTVideoView alloc] init];
    videoView.frame = CGRectMake(-10,-10,videoPlayer.frame.size.width+20,videoPlayer.frame.size.height+20);
    [videoPlayer addSubview:videoView];
    [videoView setShouldPlayAfterPrepareFinished:NO];
    [videoView setIsMuted:YES];
    videoView.videoUrl = _job.videoURL; // mp4 playable
    [videoView prepare];
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self selector:@selector(videoProgressManager) userInfo:nil repeats:YES];
    [References cornerRadius:videoPlayer radius:7.0f];
    [References cornerRadius:table radius:7.0f];
    [References lightCardShadow:videoPlayer];
    // Do any additional setup after loading the view.
}



-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)videoProgressManager {
    float progress = videoView.currentPlaySecond / videoView.totalDurationSeconds;
    [progressBar setProgress:progress animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)playPause:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.tag == 1) {
        [videoView play];
        [button setTitle:@"Pause" forState:UIControlStateNormal];
        button.tag = 2;
    } else {
        [videoView pause];
        [button setTitle:@"Play" forState:UIControlStateNormal];
        button.tag = 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _job.driveSerials.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *secs = _job.driveTimes[indexPath.row];
    [videoView.player seekToTime:CMTimeMakeWithSeconds(secs.intValue, 1000)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"driveCell";
    
    driveCell *cell = (driveCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"driveCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.serial.text = [_job.driveSerials[indexPath.row] uppercaseString];
    NSNumber *secs = _job.driveTimes[indexPath.row];
    cell.time.text = [self timeFormatted:secs.intValue];
    return cell;
}

- (NSString *)timeFormatted:(int)totalSeconds{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes, seconds];
}
@end
