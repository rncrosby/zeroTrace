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
    dateText = [NSString stringWithFormat:@"%@ %@",weekday,month];
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
    NSURL *myWebsite = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.portal-zer0trace.com/Portal/jobM.html?code=%@",_job.code]];
    NSString *textToShare = [NSString stringWithFormat:@"ZER0trace destruction for %@ of %lu drives from %@.\n\n%@",_job.client,(unsigned long)_job.driveSerials.count,dateText,myWebsite.absoluteString];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Share %@'s Job",_job.client] message:[NSString stringWithFormat:@"This will share a public link to view the video from any device as well as open the ZER0trace app on devices with it installed"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *textvideo = [UIAlertAction actionWithTitle:@"Text Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
        composeVC.messageComposeDelegate = self;
        
        // Configure the fields of the interface.
        composeVC.recipients = nil;
        composeVC.body = textToShare;
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }];
    UIAlertAction *emailvideo = [UIAlertAction actionWithTitle:@"Email Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[@"address@example.com"]];
        [composeVC setSubject:[NSString stringWithFormat:@"ZER0trace destruction for %@ of %lu drives from %@",_job.client,(unsigned long)_job.driveSerials.count,dateText]];
        [composeVC setMessageBody:myWebsite.absoluteString isHTML:NO];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
    }];
    [alert addAction:textvideo];
    [alert addAction:emailvideo];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    // Check the result or perform other tasks.    // Dismiss the message compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
