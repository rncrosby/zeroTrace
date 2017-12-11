//
//  clientView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "clientView.h"

@interface clientView ()

@end

@implementation clientView

- (void)viewDidLoad {
    menuShowing = false;
    [References tintUIButton:more color:[UIColor blackColor]];
    hasReloaded = false;
    upcomingJobs = [[NSMutableArray alloc] init];
    videoPlaying = false;
    indexSelected = -1;
    isSearching = false;
    hideStatusBar = false;
    self.ref = [[FIRDatabase database] reference];
    [self getUpcomingJobs:false];
    [super viewDidLoad];
    clientName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"client"];
    clientInfo.text = @"Your last job was completed about 4 hours ago";
    searchField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 9, 0);
    [References cornerRadius:searchField radius:8.0f];
    [References cornerRadius:searchButton radius:searchButton.frame.size.width/2];
    [References tintUIButton:searchButton color:clientInfo.textColor];
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(testRefresh:) forControlEvents:UIControlEventValueChanged];
    [scroll addSubview:refreshControl];
    //    [searchBar addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view.
}

- (void)testRefresh:(UIRefreshControl *)refreshControl
{
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    hasReloaded = false;
    [self getUpcomingJobs:true];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSThread sleepForTimeInterval:3];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
            
            refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
            
            [refreshControl endRefreshing];
            
            NSLog(@"refresh end");
        });
    });
}


- (IBAction)searchButton:(id)sender {
    if (isSearching == true) {
        [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [References tintUIButton:searchButton color:clientInfo.textColor];
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
        [searchField setText:@""];
        [searchField resignFirstResponder];
    } else {
        [table reloadData];
        [searchField becomeFirstResponder];
        isSearching = true;
    }

}

-(void)shiftView:(UIView*)view by:(CGFloat)pixels {
    view.frame = CGRectMake(view.frame.origin.x+pixels, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [searchButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [References tintUIButton:searchButton color:clientInfo.textColor];
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [scroll setContentOffset:CGPointMake(0, searchField.frame.origin.y-16) animated:YES];
    isSearching = true;
    [textField setText:@"6456787543"];
    return true;
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
     [textField resignFirstResponder];
    for (int a = 0; a < hashedSerials.count; a++) {
        if ([(driveObject*)hashedSerials[a] compareHash:textField.text.hash] == TRUE) {
            driveObject *drive = hashedSerials[a];
            int scrollY = table.frame.origin.y + 80 + (drive.job.integerValue * 308);
            if (intUpcoming == 0) {
                scrollY += 92;
            } else {
                scrollY += 121;
            }
            [scroll setContentOffset:CGPointMake(0, scrollY) animated:YES];
            [self openCell:drive.job.integerValue];
            NSLog(@"found match");
            break;
        } else {
            if (a == hashedSerials.count - 1) {
                [References fullScreenToast:[NSString stringWithFormat:@"%@ Not Found",textField.text] inView:self withSuccess:NO andClose:NO];
            }
        }
    }
    return true;
}

-(void)openCell:(NSInteger)row {
    [scrollTimer invalidate];
    [expandedCell.videoPlayer pause];
    clientCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
    expandedCell = cell;
    [expandedCell.playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    clientCell *cellDos = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexSelected inSection:1]];
    
    [UIView animateWithDuration: 0.25 animations: ^{
        for (UIView *subview in cell.driveScroll.subviews)
        {
            subview.alpha = 1;
        }
        cell.playButton.alpha = 1;
        cell.videoView.alpha = 1;
        cell.progressBar.alpha = 1;
        cell.videoControls.alpha = 1;
        cell.driveScroll.alpha = 1;
        cell.playTime.alpha = 1;
        cell.totalTime.alpha = 1;
        cell.drives.alpha = 0;
        cell.code.alpha = 0;
        cell.timeCompleted.text = @"TAP TO RETURN";
        cell.videoView.frame = CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height*2);
        cell.videoPlayer.frame = CGRectMake(-40, -70, cell.videoView.frame.size.width+80, cell.videoView.frame.size.height+140);
        cell.time.frame = CGRectMake(cell.time.frame.origin.x, cell.videoControls.frame.origin.y-cell.time.frame.size.height-8, cell.time.frame.size.width, cell.time.frame.size.height);
        cellDos.drives.alpha = 1;
        cellDos.code.alpha = 1;
        cellDos.videoView.alpha = 0;
        cellDos.playButton.alpha = 0;
        cellDos.progressBar.alpha = 0;
        cellDos.videoControls.alpha = 0;
        cellDos.driveScroll.alpha = 0;
        cellDos.playTime.alpha = 0;
        cellDos.totalTime.alpha = 0;
        cellDos.timeCompleted.text = @"JOB COMPLETED 4 HOURS AGO";
        cellDos.videoView.frame = CGRectMake(cellDos.videoView.frame.origin.x, cellDos.videoView.frame.origin.y, cellDos.videoView.frame.size.width, cellDos.videoView.frame.size.height/2);
        cellDos.videoPlayer.frame = CGRectMake(-20, -20, cellDos.videoView.frame.size.width+40, cellDos.videoView.frame.size.height+40);
        cellDos.time.frame = CGRectMake(cellDos.time.frame.origin.x, cellDos.mapView.frame.origin.y+8+cell.mapView.frame.size.height, cellDos.time.frame.size.width, cellDos.time.frame.size.height);
        for (UIView *subview in cellDos.driveScroll.subviews)
            
        {
            subview.alpha = 0;
        }
    }];
    indexSelected = row;;
    scroll.scrollEnabled = NO;
    scroll.bounces = NO;
    [table beginUpdates];
    [table endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bool)prefersStatusBarHidden{
    if (indexSelected != -1) {
        return YES;
    }
    if (menuShowing == true) {
        return FALSE;
    } else {
        
        return hideStatusBar;
    }
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (intUpcoming == 0) {
            return 1;
        }
        return 1;
    } else {
        return intComplete;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && intUpcoming == 0) {
        return 92;
    } else if (indexPath.section == 0) {
        return 121;
    }
    if (indexPath.row == indexSelected) {
        return [References screenHeight];
    }
    return 308;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        headerView *cell = (headerView *)[tableView dequeueReusableCellWithIdentifier:@"headerView"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"headerView" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.headerTitle.text = @"Upcoming";
        return cell;
    } else  {
        headerView *cell = (headerView *)[tableView dequeueReusableCellWithIdentifier:@"headerView"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"headerView" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.headerTitle.text = @"Past Jobs";
        cell.headerAction.hidden = true;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        nil;
    } else {
        if (indexSelected == indexPath.row) {
            [scrollTimer invalidate];
            clientCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            scroll.contentSize = CGSizeMake([References screenWidth],  ogTableHeight+table.frame.origin.y);
            [scroll setContentOffset:CGPointMake(0, (indexPath.row * 308)+121 +(2*45)+table.frame.origin.y-20) animated:YES];
            [UIView animateWithDuration: 0.25 animations: ^{
                for (UIView *subview in cell.driveScroll.subviews)
                {
                    subview.alpha = 0;
                }
                cell.drives.alpha = 1;
                cell.code.alpha = 1;
                cell.videoView.alpha = 0;
                cell.playButton.alpha = 0;
                cell.progressBar.alpha = 0;
                cell.videoControls.alpha = 0;
                cell.driveScroll.alpha = 0;
                cell.playTime.alpha = 0;
                cell.totalTime.alpha = 0;
                cell.videoView.frame = CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height/2);
                cell.videoPlayer.frame = CGRectMake(-20, -30, cell.videoView.frame.size.width+40, cell.videoView.frame.size.height+40);
                cell.timeCompleted.text = [self timeSinceCompletion:cell.jobDate];
            }];
            [expandedCell.videoPlayer pause];
            indexSelected = -1;
            scroll.scrollEnabled = YES;
            scroll.bounces = YES;
        } else {
            
            [scrollTimer invalidate];
            [expandedCell.videoPlayer pause];
            clientCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            expandedCell = cell;
            [expandedCell.playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
            clientCell *cellDos = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexSelected inSection:1]];
            if (indexSelected == -1) {
                scroll.contentSize = CGSizeMake([References screenWidth],  ogTableHeight+table.frame.origin.y-308+[References screenHeight]);
            }
            if (intUpcoming == 0) {
                [scroll setContentOffset:CGPointMake(0, (indexPath.row * 308)+(2*45)+table.frame.origin.y+92) animated:YES];
            } else {
                [scroll setContentOffset:CGPointMake(0, ((indexPath.row * 308) + 121)+(2*45)+table.frame.origin.y) animated:YES];
            }
            
            [UIView animateWithDuration: 0.25 animations: ^{
                for (UIView *subview in cell.driveScroll.subviews)
                {
                    subview.alpha = 1;
                }
                cell.drives.alpha = 0;
                cell.code.alpha = 0;
                cell.playButton.alpha = 1;
                cell.videoView.alpha = 1;
                cell.progressBar.alpha = 1;
                cell.videoControls.alpha = 1;
                cell.driveScroll.alpha = 1;
                cell.playTime.alpha = 1;
                cell.totalTime.alpha = 1;
                cell.timeCompleted.text = @"TAP TO RETURN";
                cell.videoView.frame = CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height*2);
                cell.videoPlayer.frame = CGRectMake(-40, -70, cell.videoView.frame.size.width+80, cell.videoView.frame.size.height+140);
                cell.drives.alpha = 0;
                cell.code.alpha = 0;
                cellDos.videoView.alpha = 0;
                cellDos.playButton.alpha = 0;
                cellDos.progressBar.alpha = 0;
                cellDos.videoControls.alpha = 0;
                cellDos.driveScroll.alpha = 0;
                cellDos.playTime.alpha = 0;
                cellDos.totalTime.alpha = 0;
                cellDos.drives.alpha = 1;
                cellDos.code.alpha = 1;
                cellDos.timeCompleted.text = [self timeSinceCompletion:cellDos.jobDate];
                cellDos.videoView.frame = CGRectMake(cellDos.videoView.frame.origin.x, cellDos.videoView.frame.origin.y, cellDos.videoView.frame.size.width, cellDos.videoView.frame.size.height/2);
                cellDos.videoPlayer.frame = CGRectMake(-20, -20, cellDos.videoView.frame.size.width+40, cellDos.videoView.frame.size.height+40);
                for (UIView *subview in cellDos.driveScroll.subviews)
                
                {
                    subview.alpha = 0;
                }
            }];
            indexSelected = (int)indexPath.row;
            scroll.scrollEnabled = NO;
            scroll.bounces = NO;
        }
        [tableView beginUpdates];
        [tableView endUpdates];
    
    }
}

-(void)videoProgressManager {
    if (indexSelected != -1) {
        if (videoPlaying == true) {
            float progress = expandedCell.videoPlayer.currentPlaySecond / expandedCell.videoPlayer.totalDurationSeconds;
            if (expandedCell.playTime.frame.origin.x < expandedCell.progressBar.frame.size.width - expandedCell.playTime.frame.size.width) {
                 [expandedCell.progressBar setProgress:progress animated:YES];
            }
            expandedCell.playTime.text = [NSString stringWithFormat:@"%@",[self timeFormatted:(int)expandedCell.videoPlayer.currentPlaySecond]];
//            if (disableScrolling != true) {
//                jobObject *job = jobs[indexSelected];
//                for (int a = 1; a < job.driveTimes.count; a++) {
//                    if ([job.driveTimes[a] intValue] -1 == (int)expandedCell.videoPlayer.currentPlaySecond) {
//                        [expandedCell.driveScroll setContentOffset:CGPointMake(expandedCell.driveScroll.contentOffset.x+173+8, 0) animated:YES];
//
//                    }
//                }
//            }
            
        }
        }
}

-(void)skimToTime:(id)sender{
    if (videoPlaying == true) {
        UIButton *time = (UIButton*)sender;
        [expandedCell.videoPlayer.player seekToTime:CMTimeMakeWithSeconds(time.tag-1, 1000)];
        float progress = expandedCell.videoPlayer.currentPlaySecond / expandedCell.videoPlayer.totalDurationSeconds;
        [expandedCell.progressBar setProgress:progress animated:YES];
    } else {
        [self playVideo];
        UIButton *time = (UIButton*)sender;
        [expandedCell.videoPlayer.player seekToTime:CMTimeMakeWithSeconds(time.tag-1, 1000)];
        float progress = expandedCell.videoPlayer.currentPlaySecond / expandedCell.videoPlayer.totalDurationSeconds;
        [expandedCell.progressBar setProgress:progress animated:YES];
    }
    
}


-(void)playVideo {
    if (videoPlaying == false) {
        [expandedCell.videoPlayer play];
        if (expandedCell.hasPlayedVideo.boolValue == [NSNumber numberWithBool:NO].boolValue) {
            scrollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self selector:@selector(videoProgressManager) userInfo:nil repeats:YES];
            expandedCell.hasPlayedVideo = [NSNumber numberWithBool:YES];
        }
        [expandedCell.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [References tintUIButton:expandedCell.playButton color:expandedCell.drives.textColor];
        videoPlaying = true;
        expandedCell.totalTime.text = [NSString stringWithFormat:@"%@",[self timeFormatted:(int)expandedCell.videoPlayer.totalDurationSeconds]];
    } else {
        [expandedCell.videoPlayer pause];
        [expandedCell.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [References tintUIButton:expandedCell.playButton color:expandedCell.drives.textColor];
        videoPlaying = false;
    }
    
}

-(void)newJob{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    newJobView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"newJobView"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && intUpcoming == 0) {
        static NSString *simpleTableIdentifier = @"newJobCell";
        
        newJobCell *cell = (newJobCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"newJobCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell.schedulejOB addTarget:self action:@selector(newJob) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else if (indexPath.section == 0 && intUpcoming > 0){
        static NSString *simpleTableIdentifier = @"upcomingJobCell";
        
        upcomingJobCell *cell = (upcomingJobCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"upcomingJobCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }

        NSData *archivedButton = [NSKeyedArchiver archivedDataWithRootObject:cell.calanderButton];
        NSData *archivedShadow = [NSKeyedArchiver archivedDataWithRootObject:cell.shadow];
        NSData *archivedMonth = [NSKeyedArchiver archivedDataWithRootObject:cell.calendarMonth];
        NSData *archivedDate = [NSKeyedArchiver archivedDataWithRootObject:cell.calendarDate];
        int currentX = 16;
        for (int a = 0; a < upcomingJobs.count; a++) {
            upcomingJobObject *job = upcomingJobs[a];
            if (a == 0) {
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:job.date.doubleValue];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM"];
                cell.calendarMonth.text = [[dateFormat stringFromDate:date] uppercaseString];
                cell.calendarMonth.userInteractionEnabled = NO;
                cell.calendarDate.userInteractionEnabled = NO;
                [References cardshadow:cell.shadow];
                [dateFormat setDateFormat:@"d"];
                cell.calendarDate.text = [dateFormat stringFromDate:date];
                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.calendarMonth.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                maskLayer.frame = cell.calendarMonth.bounds;
                maskLayer.path  = maskPath.CGPath;
                cell.calanderButton.tag = a;
                [cell.calanderButton addTarget:self action:@selector(upcomingMore:) forControlEvents:UIControlEventTouchUpInside];
                cell.calendarMonth.layer.mask = maskLayer;
                [References cornerRadius:cell.calanderButton radius:10.0f];
                currentX = currentX + cell.calanderButton.frame.size.width + 8;
            } else {
                UIButton *calanderButton = [NSKeyedUnarchiver unarchiveObjectWithData: archivedButton];
                UILabel *calendarMonth = [NSKeyedUnarchiver unarchiveObjectWithData: archivedMonth];
                UILabel *calendarDate = [NSKeyedUnarchiver unarchiveObjectWithData: archivedDate];
                UILabel *shadow = [NSKeyedUnarchiver unarchiveObjectWithData: archivedShadow];
                [References cardshadow:shadow];
                calendarMonth.userInteractionEnabled = NO;
                calendarDate.userInteractionEnabled = NO;
                shadow.frame = CGRectMake(currentX+7, shadow.frame.origin.y, shadow.frame.size.width, shadow.frame.size.height);
                calendarDate.frame = CGRectMake(currentX, cell.calendarDate.frame.origin.y, cell.calendarDate.frame.size.width, cell.calendarDate.frame.size.height);
                calendarMonth.frame = CGRectMake(currentX, cell.calendarMonth.frame.origin.y, cell.calendarMonth.frame.size.width, cell.calendarMonth.frame.size.height);
                calanderButton.frame = CGRectMake(currentX, cell.calanderButton.frame.origin.y, cell.calanderButton.frame.size.width, cell.calanderButton.frame.size.height);
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:job.date.doubleValue];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM"];
                calendarMonth.text = [[dateFormat stringFromDate:date] uppercaseString];
                [dateFormat setDateFormat:@"d"];
                calendarDate.text = [dateFormat stringFromDate:date];
                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:calendarMonth.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                maskLayer.frame = calendarMonth.bounds;
                maskLayer.path  = maskPath.CGPath;
                calendarMonth.layer.mask = maskLayer;
                [References cornerRadius:calanderButton radius:10.0f];
                [cell.scrollView addSubview:shadow];
                [cell.scrollView addSubview:calanderButton];
                [cell.scrollView addSubview:calendarDate];
                [cell.scrollView addSubview:calendarMonth];
                calanderButton.tag = a;
                [calanderButton addTarget:self action:@selector(upcomingMore:) forControlEvents:UIControlEventTouchUpInside];
                currentX = currentX + calanderButton.frame.size.width + 8;
            }
        }
        UIButton *calanderButton = [NSKeyedUnarchiver unarchiveObjectWithData: archivedButton];
        UILabel *calendarDate = [NSKeyedUnarchiver unarchiveObjectWithData: archivedDate];
        calendarDate.frame = CGRectMake(currentX, cell.calanderButton.frame.origin.y, cell.calanderButton.frame.size.width, cell.calanderButton.frame.size.height);
        [calendarDate setTextColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
        [calendarDate setFont:[UIFont systemFontOfSize:50.0f weight:UIFontWeightLight]];
        [calendarDate setText:@"+"];
        calanderButton.frame = CGRectMake(currentX, cell.calanderButton.frame.origin.y, cell.calanderButton.frame.size.width, cell.calanderButton.frame.size.height);
        [References cornerRadius:calanderButton radius:10.0f];
        [calanderButton addTarget:self action:@selector(newJob) forControlEvents:UIControlEventTouchUpInside];
        UILabel *shadow = [NSKeyedUnarchiver unarchiveObjectWithData: archivedShadow];
        [References cardshadow:shadow];
        shadow.frame = CGRectMake(currentX+7, shadow.frame.origin.y, shadow.frame.size.width, shadow.frame.size.height);
        [cell.scrollView addSubview:shadow];
        [cell.scrollView addSubview:calanderButton];
        [cell.scrollView addSubview:calendarDate];
        cell.scrollView.contentSize = CGSizeMake(calanderButton.frame.origin.x+calanderButton.frame.size.width+16, cell.scrollView.frame.size.height);
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        static NSString *simpleTableIdentifier = @"clientCell";
        
        clientCell *cell = (clientCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"clientCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        [References cornerRadius:cell.playButton radius:cell.playButton.frame.size.width/2];
        cell.playButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [References cornerRadius:cell.mapView radius:12.0f];
        
        cell.backgroundColor = [UIColor clearColor];
        [cell setBackgroundColor:[UIColor clearColor]];
        jobObject *job = jobs[indexPath.row];
        
        cell.date.text = job.dateOfDestruction;
        cell.drives.text = [NSString stringWithFormat:@"%lu\nDrives",(unsigned long)job.driveSerials.count];
        //    [References blurView:cell.playButton];
        [cell.playButton setBackgroundColor:[UIColor lightTextColor]];
        [References blurView:cell.bottomBlur];
        [References cardshadow:cell.playButton];
        cell.playButton.tag = indexPath.row;
        cell.mapView.zoomEnabled = false;
        cell.mapView.scrollEnabled = false;
        cell.mapView.userInteractionEnabled = false;
        cell.videoPlayer = [[CTVideoView alloc] init];
        cell.videoPlayer.frame = CGRectMake(-10,-10,cell.videoView.frame.size.width+20,(cell.videoView.frame.size.height*2)+20);
        [cell.videoView addSubview:cell.videoPlayer];
        [cell.videoPlayer setShouldPlayAfterPrepareFinished:NO];
        [cell.videoPlayer setIsMuted:YES];
        cell.videoPlayer.videoUrl = job.videoURL; // mp4 playable
        [cell.videoPlayer prepare];
        [cell.progressBar setProgress:0];
        [cell.videoPlayer setUserInteractionEnabled:FALSE];
        [References cornerRadius:cell.videoView radius:12.0f];
        [References tintUIButton:cell.playButton color:cell.drives.textColor];
        NSData *archivedButton = [NSKeyedArchiver archivedDataWithRootObject:cell.driveButton];
        NSData *archivedTime = [NSKeyedArchiver archivedDataWithRootObject:cell.driveTime];
        [cell.driveButton setTitle:[job.driveSerials[0] uppercaseString] forState:UIControlStateNormal];
        cell.driveButton.tag = [job.driveTimes[0]intValue];
        [cell.driveButton addTarget:self action:@selector(skimToTime:) forControlEvents:UIControlEventTouchUpInside];
        cell.driveTime.text = [self timeFormatted:[job.driveTimes[0] intValue]];
        for (int a = 1; a < job.driveSerials.count; a++) {
                int shiftDown = 50 * a;
                UIButton *driveButton = [NSKeyedUnarchiver unarchiveObjectWithData: archivedButton];
                driveButton.tag = [job.driveTimes[a] intValue];
                [driveButton addTarget:self action:@selector(skimToTime:) forControlEvents:UIControlEventTouchUpInside];
                UILabel *driveTime = [NSKeyedUnarchiver unarchiveObjectWithData: archivedTime];
                driveTime.text = [self timeFormatted:[job.driveTimes[a] intValue]];
                [driveButton setTitle:[job.driveSerials[a] uppercaseString] forState:UIControlStateNormal];
                [driveButton.titleLabel setFont:cell.driveButton.titleLabel.font];
                driveButton.frame = CGRectMake(driveButton.frame.origin.x, shiftDown+16, driveButton.frame.size.width, driveButton.frame.size.height);
                driveTime.frame = CGRectMake(driveTime.frame.origin.x, shiftDown+4, driveTime.frame.size.width, driveTime.frame.size.height);
                [cell.driveScroll addSubview:driveButton];
                [cell.driveScroll addSubview:driveTime];

        }
        [References blurView:cell.bottomBlur];
        UIBezierPath *bottomMask = [UIBezierPath bezierPathWithRoundedRect:cell.bottomBlur.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(12.0, 12.0)];
        CAShapeLayer *bottomLayer = [[CAShapeLayer alloc] init];
        bottomLayer.frame = cell.bottomBlur.bounds;
        bottomLayer.path  = bottomMask.CGPath;
        cell.bottomBlur.layer.mask = bottomLayer;
        MKCoordinateRegion mapRegion;
        mapRegion.center = job.location.coordinate;
        mapRegion.span.latitudeDelta = 4.0;
        mapRegion.span.longitudeDelta = 4.0;
        [cell.mapView setRegion:mapRegion animated: YES];
        cell.code.text = [NSString stringWithFormat:@"%@\njob code",job.jobCode];
        [References cornerRadius:cell.driveScroll radius:10.0f];
        cell.driveScroll.contentSize = CGSizeMake(cell.driveScroll.frame.size.width, job.driveSerials.count*50);
        cell.jobDate = job.dateObject;
        cell.timeCompleted.text = [self timeSinceCompletion:cell.jobDate];
        return cell;
    }
    
}


-(CIImage*)generateBarcode:(NSString*)dataString{
    
    CIFilter *barCodeFilter = [CIFilter filterWithName:@"CIAztecCodeGenerator"];
    NSData *barCodeData = [dataString dataUsingEncoding:NSASCIIStringEncoding];
    [barCodeFilter setValue:barCodeData forKey:@"inputMessage"];
//    [barCodeFilter setValue:[NSNumber numberWithInt:56] forKey:@"inputMinHeight"];
//    [barCodeFilter setValue:[NSNumber numberWithInt:1] forKey:@"inputDataColumns"];
//    [barCodeFilter setValue:[NSNumber numberWithInt:15] forKey:@"inputRows"];
CIImage *barCodeImage = barCodeFilter.outputImage;
    
    return barCodeImage;
}

-(void)getClientJobs {
//    table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y+[References screenHeight], [References screenWidth], table.frame.size.height);
    jobs = [[NSMutableArray alloc] init];
    savedJobs = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"clientCode = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"code"]]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    query.sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc]initWithKey:@"modificationDate" ascending:false]];
    CKContainer *container = [CKContainer containerWithIdentifier:@"iCloud.com.fullytoasted.ZER0trace-Internal"];
    [container.publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (error) {
                                                           NSLog(@"%@",error.localizedDescription);
                                                       }
                                                       for (int a = 0; a < results.count; a++) {
                                                           CKRecord *record = results[a];
                                                           NSString *date = [record valueForKey:@"jobDate"];
                                                           NSString *code = [record valueForKey:@"code"];
                                                           intComplete = intComplete + 1;
                                                           
                                                           for (int a = 0; a < date.length; a++) {
                                                               if ([date characterAtIndex:a] == ' ') {
                                                                   
                                                                   NSMutableString *mu = [NSMutableString stringWithString:date];
                                                                   [mu deleteCharactersInRange:NSMakeRange(a, 1)];
                                                                   [mu insertString:@"\n" atIndex:a];
                                                                   date = mu;
                                                                   break;
                                                               }
                                                           }
                                                           NSArray *driveTimes = [record objectForKey:@"driveTimes"];
                                                           NSArray *driveSerials = [record objectForKey:@"driveSerials"];
                                                           NSURL *videoURL = [NSURL URLWithString:[record valueForKey:@"videoURL"]];
                                                           CLLocation *location = [record objectForKey:@"location"];
                                                           jobObject *job;
                                                           if (location != NULL) {
                                                               job = [[jobObject alloc] initWithType:videoURL andTimes:driveTimes andSerials:driveSerials andDate:date andCode:code andLocation:[[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] andDateObject:[record valueForKey:@"modificationDate"]];
                                                           } else {
                                                               job = [[jobObject alloc] initWithType:videoURL andTimes:driveTimes andSerials:driveSerials andDate:date andCode:code andLocation:[[CLLocation alloc] initWithLatitude:0.0 longitude:0.0] andDateObject:[record valueForKey:@"modificationDate"]];
                                                           }
                                                           
                                                           [jobs addObject:job];
                                                           [savedJobs addObject:job];
                                                       } dispatch_sync(dispatch_get_main_queue(), ^{
                                                           intUpcoming = upcomingJobs.count;
                                                           [table reloadData];
                                                           ogTableHeight = table.frame.origin.y + ((intComplete * 308)+121) + (2 * 45)+32;
                                                           if (intUpcoming == 0) {
                                                               ogTableHeight = ogTableHeight + 92;
                                                           }
                                                           scroll.contentSize = CGSizeMake([References screenWidth], ogTableHeight);
                                                           table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, [References screenWidth], ((intComplete * 308) + 121)+(2*45)+1000);
                                                           [self machineLearning];
                                                           [self HashTheDrives];
                                                       });
                                                       
                                                   }];
}
//- (IBAction)searchButton:(id)sender {
//    if (isSearching == false) {
//        searchBar.hidden = false;
//        [UIView animateWithDuration:0.25f animations:^(void){
//            line.frame = CGRectMake(0, line.frame.origin.y+searchBar.frame.size.height+20, line.frame.size.width, line.frame.size.height);
//            table.frame = CGRectMake(0, table.frame.origin.y+searchBar.frame.size.height+20, table.frame.size.width, table.frame.size.height-searchBar.frame.size.height-20);
//            [searchButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
//        } completion:^(bool complete){
//            if (complete) {
//                [searchBar becomeFirstResponder];
//                isSearching = true;
//            }
//        }];
//    } else {
//        jobs = [[NSMutableArray alloc] init];
//        for (int a = 0; a < savedJobs.count; a++) {
//            [jobs addObject:savedJobs[a]];
//        }
//        [table reloadData];
//        [searchBar resignFirstResponder];
//        [UIView animateWithDuration:0.25f animations:^(void){
//            line.frame = CGRectMake(0, line.frame.origin.y-searchBar.frame.size.height-20, line.frame.size.width, line.frame.size.height);
//            table.frame = CGRectMake(0, table.frame.origin.y-searchBar.frame.size.height-20, table.frame.size.width, table.frame.size.height+searchBar.frame.size.height+20);
//            [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
//        } completion:^(bool complete){
//            if (complete) {
//                searchBar.hidden = true;
//                isSearching = false;
//            }
//        }];
//    }
//    
//}
//
//-(void)textChanged:(UITextField *)textField {
//    if (textField.text.length == 0) {
//        jobs = [[NSMutableArray alloc] init];
//        for (int a = 0; a < savedJobs.count; a++) {
//            [jobs addObject:savedJobs[a]];
//        }
//        [table reloadData];
//        return ;
//    }
//    [jobs removeAllObjects];
//    jobs = [[NSMutableArray alloc] init];
//    for (int a = 0; a < savedJobs.count; a++) {
//        jobObject *job = savedJobs[a];
//        for (int b = 0; b < job.driveSerials.count; b++) {
//            if ([job.driveSerials[b] localizedCaseInsensitiveContainsString:textField.text]) {
//                [jobs addObject:job];
//                break;
//            }
//        }
//    }
//    [table reloadData];
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        
    } else {
        if (scrollView.contentOffset.y > oldY) {
            // sscrolling down
            if (scrollView.contentOffset.y > (clientName.frame.origin.y-20)) {
                if (hideStatusBar != true) {
                    hideStatusBar = true;
                    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        [self setNeedsStatusBarAppearanceUpdate];
                    } completion:^(bool finished){
                        if (finished) {
                            nil;
                        }
                    }];
                }
                
            }
        } else {
            if (scrollView.contentOffset.y < (clientName.frame.origin.y+20)) {
                if (hideStatusBar != false) {
                    hideStatusBar = false;
                    
                    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        [self setNeedsStatusBarAppearanceUpdate];
                    } completion:^(bool finished){
                        if (finished) {
                            nil;
                        }
                    }];
                }
                
            }
            // scrolling up
        }
        oldY = scrollView.contentOffset.y;
    }
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

-(void)getUpcomingJobs:(BOOL)isRelaod{
    [_ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (hasReloaded == false) {
            hasReloaded = true;
            if (![[NSString stringWithFormat:@"%@",snapshot.value]  isEqualToString:@"<null>"]) {
                NSDictionary *Djobs = snapshot.value;
                if ([Djobs objectForKey:@"upcomingJobs"] != nil) {
                    Djobs = [Djobs objectForKey:@"upcomingJobs"];
                    upcomingJobs = [[NSMutableArray alloc] init];
                    [upcomingJobs removeAllObjects];
                    NSArray *matches = [Djobs allValues];
                    for (int a = 0; a < matches.count; a++) {
                        if ([[matches[a] objectForKey:@"client"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"code"]]) {
                            NSLog(@"%@",matches[a]);
                            upcomingJobObject *job = [[upcomingJobObject alloc] initWithType:[matches[a] valueForKey:@"code"] forClient:[matches[a] objectForKey:@"client"] withLat:[matches[a] objectForKey:@"location-lat"] andLon:[matches[a] objectForKey:@"location-lon"] andDrives:[matches[a] objectForKey:@"drives"] on:[matches[a] objectForKey:@"date"] withText:[matches[a] objectForKey:@"dateText"]];
                            [upcomingJobs addObject:job];
                        }
                    }
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateObject" ascending:TRUE];
                    [upcomingJobs sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    if (isRelaod == false) {
                        [self getClientJobs];
                    } else {
                        intUpcoming = upcomingJobs.count;
                        [table reloadData];
                    }
                } else {
                    [table reloadData];
                }
            } else {
                intUpcoming = 0;
                [self getClientJobs];
            }
        } else {
            
        }
            
        
    }];
    
}

-(void)upcomingMore:(id)sender {
    UIButton *button = (UIButton*)sender;
    upcomingJobObject *job = upcomingJobs[button.tag];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:job.dateText message:@"This job has not been confirmed yet." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel Job" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
        intUpcoming--;
        FIRDatabaseReference *objectRef = [[_ref child:@"upcomingJobs"] child:[NSString stringWithFormat:@"%@",job.code]];
        [objectRef removeValue];
        [upcomingJobs removeObjectAtIndex:button.tag];
        [table reloadData];
        [self machineLearning];
    }];
    UIAlertAction *shareJob = [UIAlertAction actionWithTitle:@"Share Job Details" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"Call ZER0trace" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
        // Other action
    }];
    [alert addAction:cancelAction];
    [alert addAction:shareJob];
    [alert addAction:callAction];
    [alert addAction:doneAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSString*)timeSinceCompletion:(NSDate*)jobDate{
    NSLog(@"date: %@",jobDate);
    NSString *jobCompleted = @"JOB COMPLETED ";
    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:jobDate];
    int numberOfDays = secondsBetween / 86400;
    if (numberOfDays < 1) {
        jobCompleted = [jobCompleted stringByAppendingString:@"JUST NOW"];
    } else {
        if (numberOfDays >= 7) {
            int weeks = numberOfDays/7;
            if (weeks > 1){
                jobCompleted = [jobCompleted stringByAppendingString:[NSString stringWithFormat:@"%i WEEKS AGO",weeks]];
            } else {
                jobCompleted = [jobCompleted stringByAppendingString:[NSString stringWithFormat:@"%i WEEK AGO",weeks]];
            }
        } else {
            if (numberOfDays > 1){
                jobCompleted = [jobCompleted stringByAppendingString:[NSString stringWithFormat:@"%i DAYS AGO",numberOfDays]];
            } else {
                jobCompleted = [jobCompleted stringByAppendingString:[NSString stringWithFormat:@"%i DAY AGO",numberOfDays]];
            }
        }
    }
    return jobCompleted;
}

-(void)machineLearning {
    if (intUpcoming > 0) {
        NSString *timeInterval;
        upcomingJobObject *job = upcomingJobs[0];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:job.date.doubleValue];
        NSTimeInterval secondsBetween = [date timeIntervalSinceDate:[NSDate date]];
        int numberOfDays = secondsBetween / 86400;
        if (numberOfDays < 1) {
            timeInterval = @"Today";
        } else {
            if (numberOfDays >= 7) {
                int weeks = numberOfDays/7;
                if (weeks > 1){
                    timeInterval = [NSString stringWithFormat:@"%i weeks from now",weeks];
                } else {
                    
                    timeInterval = [NSString stringWithFormat:@"%i week from now",weeks];
                }
            } else {
                if (numberOfDays == 1) {
                    timeInterval = [NSString stringWithFormat:@"%i day from now",numberOfDays];
                } else {
                timeInterval = [NSString stringWithFormat:@"%i days from now",numberOfDays];
                }
            }
        }
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:job.lat.doubleValue longitude:job.lon.doubleValue]
                       completionHandler:^(NSArray *placemarks, NSError *error){
                           if(!error){
                               CLPlacemark *placeMark = placemarks[0];
                               clientInfo.text =[NSString stringWithFormat:@"Your next job is scheduled for %@ at %@",timeInterval,[NSString stringWithFormat:@"%@ %@",placeMark.subThoroughfare,placeMark.thoroughfare]];
                           }
                           else{
                               NSLog(@"There was a reverse geocoding error\n%@", [error localizedDescription]);
                           }
                       }
         ];
        
    } else {
        clientInfo.text =[NSString stringWithFormat:@"You have no upcoming jobs, schedule your next job below."];
    }
}

-(void)HashTheDrives{
    hashedSerials = [[NSMutableArray alloc] init];
    driveTotal = 0;
    for (int a = 0; a < jobs.count; a++) {
        jobObject *tJob = jobs[a];
        for (int b = 0; b < tJob.driveSerials.count; b++) {
            [hashedSerials addObject:[[driveObject alloc] initWithType:tJob.driveSerials[b] andIndex:[NSNumber numberWithInt:b] andJob:[NSNumber numberWithInt:a]]];
            driveTotal++;
        }
    }
}

-(void)addDrive:(driveObject*)headDrive appendDrive:(driveObject*)appendDrive{
    driveObject *drive = headDrive;
    while (drive.nextDrive != NULL) {
        drive = drive.nextDrive;
    }
    drive.nextDrive = appendDrive;
    appendDrive.previousDrive = drive;
}


- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (totalSeconds < 3600) {
            return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    } else {
            return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }

}
- (IBAction)more:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ZER0trace" message:@"Version 1.0" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *shareJob = [UIAlertAction actionWithTitle:@"Contact Support" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [References toastMessage:@"soon" andView:self andClose:NO];
    }];
    UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:@"Sign Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
        // Ok action example
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"client"];
         [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
         [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"code"];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        loginView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"loginView"];
        [self presentViewController:controller animated:YES completion:nil];
    }];
    UIAlertAction *infoAction = [UIAlertAction actionWithTitle:@"More Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
        // Other action
    }];
    [alert addAction:infoAction];
    [alert addAction:shareJob];
    [alert addAction:signOutAction];
    [alert addAction:doneAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
