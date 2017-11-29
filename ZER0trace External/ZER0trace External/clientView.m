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
    videoPlaying = false;
    indexSelected = -1;
    isSearching = false;
    hideStatusBar = false;
    [self getClientJobs];
    [super viewDidLoad];
    clientName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"client"];
    clientInfo.text = @"Your last job was completed about 4 hours ago";
    searchField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 9, 0);
    [References cornerRadius:searchField radius:8.0f];
    [References cornerRadius:searchButton radius:searchButton.frame.size.width/2];
    [References tintUIButton:searchButton color:clientInfo.textColor];
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
//    [searchBar addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view.
}

- (IBAction)searchButton:(id)sender {
    if (isSearching == true) {
        intUpcoming = 0;
        intComplete = 0;
        [jobs removeAllObjects];
        jobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedJobs.count; a++) {
            jobObject *job = savedJobs[a];
            if (job.driveSerials.count < 1) {
                intUpcoming = intUpcoming + 1;
            } else {
                intComplete = intComplete + 1;
            }
            [jobs addObject:job];
        }
        ogTableHeight = table.frame.origin.y + ((intComplete + intUpcoming) * 308) + (2 * 45)+32;
        if (intUpcoming == 0) {
            ogTableHeight = ogTableHeight + 92;
        }
        isSearching = false;
        [table reloadData];
        scroll.contentSize = CGSizeMake([References screenWidth], ogTableHeight);
        table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, [References screenWidth], ((intComplete + intUpcoming) * 308)+(2*45)+1000);
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

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [searchButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [References tintUIButton:searchButton color:clientInfo.textColor];
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [scroll setContentOffset:CGPointMake(0, searchField.frame.origin.y-8) animated:YES];
    isSearching = true;
    return true;
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    intUpcoming = 0;
    intComplete = 0;
    [jobs removeAllObjects];
    jobs = [[NSMutableArray alloc] init];
    for (int a = 0; a < savedJobs.count; a++) {
        jobObject *job = savedJobs[a];
            for (int b = 0; b < job.driveSerials.count; b++) {
                    if ([job.driveSerials[b] containsString:textField.text]) {
                        if (job.driveSerials.count < 1) {
                            intUpcoming = intUpcoming + 1;
                        } else {
                            intComplete = intComplete + 1;
                        }
                        [jobs addObject:job];
                        
                }
        }
        
    }
    [table reloadData];
    ogTableHeight = table.frame.origin.y + ((intComplete + intUpcoming) * 308) + (2 * 45)+60;
    if (intUpcoming == 0) {
        ogTableHeight = ogTableHeight + 92;
    }
    scroll.contentSize = CGSizeMake([References screenWidth], ogTableHeight);
    table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, [References screenWidth], ((intComplete + intUpcoming) * 308)+(2*45)+1000);
    [textField resignFirstResponder];
    [scroll setContentOffset:CGPointMake(0, -20) animated:YES];
    return true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bool)prefersStatusBarHidden{
    return hideStatusBar;
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (intUpcoming == 0 && isSearching == false) {
            return 1;
        }
        return intUpcoming;
    } else {
        return intComplete;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && intUpcoming == 0) {
        return 92;
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
        if (indexSelected == indexPath.row) {
            clientCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            scroll.contentSize = CGSizeMake([References screenWidth],  ogTableHeight+table.frame.origin.y);
            [scroll setContentOffset:CGPointMake(0, (indexPath.row * 308)+(2*45)+table.frame.origin.y+20) animated:YES];
            [UIView animateWithDuration: 0.25 animations: ^{
                for (UIView *subview in cell.driveScroll.subviews)
                {
                    subview.alpha = 0;
                }
                cell.videoView.alpha = 0;
                cell.playButton.alpha = 0;
                cell.progressBar.alpha = 0;
                cell.videoControls.alpha = 0;
                cell.driveScroll.alpha = 0;
                
                cell.videoView.frame = CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height/2);
                cell.videoPlayer.frame = CGRectMake(-20, -30, cell.videoView.frame.size.width+40, cell.videoView.frame.size.height+40);
                cell.timeCompleted.text = @"JOB COMPLETED 4 HOURS AGO";
                cell.drives.frame = CGRectMake(cell.drives.frame.origin.x, cell.mapView.frame.origin.y+cell.mapView.frame.size.height+8, cell.drives.frame.size.width, cell.drives.frame.size.height);
                cell.code.frame = CGRectMake(cell.code.frame.origin.x, cell.mapView.frame.origin.y+8+cell.mapView.frame.size.height, cell.code.frame.size.width, cell.code.frame.size.height);
                cell.time.frame = CGRectMake(cell.time.frame.origin.x, cell.mapView.frame.origin.y+8+cell.mapView.frame.size.height, cell.time.frame.size.width, cell.time.frame.size.height);
            }];
            [expandedCell.videoPlayer pause];
            indexSelected = -1;
        } else {
            [expandedCell.videoPlayer pause];
            clientCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            expandedCell = cell;
            [expandedCell.playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
            clientCell *cellDos = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexSelected inSection:1]];
            [cell.videoPlayer prepare];
            if (indexSelected == -1) {
                scroll.contentSize = CGSizeMake([References screenWidth],  ogTableHeight+table.frame.origin.y-308+[References screenHeight]);
            }
            if (intUpcoming == 0) {
                [scroll setContentOffset:CGPointMake(0, (indexPath.row * 308)+(2*45)+table.frame.origin.y+92) animated:YES];
            } else {
                [scroll setContentOffset:CGPointMake(0, ((indexPath.row+intUpcoming) * 308)+(2*45)+table.frame.origin.y) animated:YES];
            }
            
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
                cell.timeCompleted.text = @"TAP TO RETURN";
                cell.videoView.frame = CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height*2);
                cell.videoPlayer.frame = CGRectMake(-40, -70, cell.videoView.frame.size.width+80, cell.videoView.frame.size.height+140);
                cell.drives.frame = CGRectMake(cell.drives.frame.origin.x, cell.videoControls.frame.origin.y-cell.drives.frame.size.height-8, cell.drives.frame.size.width, cell.drives.frame.size.height);
                cell.code.frame = CGRectMake(cell.code.frame.origin.x, cell.videoControls.frame.origin.y-cell.code.frame.size.height-8, cell.code.frame.size.width, cell.code.frame.size.height);
                cell.time.frame = CGRectMake(cell.time.frame.origin.x, cell.videoControls.frame.origin.y-cell.time.frame.size.height-8, cell.time.frame.size.width, cell.time.frame.size.height);
                
                cellDos.videoView.alpha = 0;
                cellDos.playButton.alpha = 0;
                cellDos.progressBar.alpha = 0;
                cellDos.videoControls.alpha = 0;
                cellDos.driveScroll.alpha = 0;
                cellDos.timeCompleted.text = @"JOB COMPLETED 4 HOURS AGO";
                cellDos.videoView.frame = CGRectMake(cellDos.videoView.frame.origin.x, cellDos.videoView.frame.origin.y, cellDos.videoView.frame.size.width, cellDos.videoView.frame.size.height/2);
                cellDos.videoPlayer.frame = CGRectMake(-20, -20, cellDos.videoView.frame.size.width+40, cellDos.videoView.frame.size.height+40);
                cellDos.drives.frame = CGRectMake(cellDos.drives.frame.origin.x, cellDos.mapView.frame.origin.y+8+cell.mapView.frame.size.height, cellDos.drives.frame.size.width, cellDos.drives.frame.size.height);
                cellDos.code.frame = CGRectMake(cellDos.code.frame.origin.x, cellDos.mapView.frame.origin.y+8+cell.mapView.frame.size.height, cellDos.code.frame.size.width, cellDos.code.frame.size.height);
                cellDos.time.frame = CGRectMake(cellDos.time.frame.origin.x, cellDos.mapView.frame.origin.y+8+cell.mapView.frame.size.height, cellDos.time.frame.size.width, cellDos.time.frame.size.height);
                for (UIView *subview in cellDos.driveScroll.subviews)
                
                {
                    subview.alpha = 0;
                }
            }];
            indexSelected = (int)indexPath.row;
        }
        [tableView beginUpdates];
        [tableView endUpdates];
    
    
}

-(void)videoProgressManager {
    float progress = expandedCell.videoPlayer.currentPlaySecond /  expandedCell.videoPlayer.totalDurationSeconds;
    [expandedCell.progressBar setProgress:progress animated:YES];
}


-(void)playVideo {
    if (videoPlaying == false) {
        [expandedCell.videoPlayer play];
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self selector:@selector(videoProgressManager) userInfo:nil repeats:YES];
        [expandedCell.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [References tintUIButton:expandedCell.playButton color:expandedCell.drives.textColor];
        videoPlaying = true;
    } else {
        [expandedCell.videoPlayer pause];
        [expandedCell.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [References tintUIButton:expandedCell.playButton color:expandedCell.drives.textColor];
        videoPlaying = false;
    }
    
}

-(void)newJob{
    [References toastMessage:@"Coming Soon" andView:self andClose:NO];
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
        return cell;
    }
    if (indexPath.section == 1) {
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
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.videoControls.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = cell.videoControls.bounds;
        maskLayer.path  = maskPath.CGPath;
        cell.videoControls.layer.mask = maskLayer;
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
        cell.driveScroll.contentSize = CGSizeMake((cell.driveButton.frame.origin.x + cell.driveButton.frame.size.width+16)*job.driveTimes.count, cell.driveScroll.contentSize.height);
        [References cornerRadius:cell.driveButton radius:8.0f];
        if (job.driveSerials.count > 0) {
            [cell.driveButton setTitle:job.driveSerials[0] forState:UIControlStateNormal];
            cell.driveTime.text = [self timeFormatted:(int)job.driveTimes[0]];
            NSData *archivedButton = [NSKeyedArchiver archivedDataWithRootObject: cell.driveButton];
            NSData *archivedTime = [NSKeyedArchiver archivedDataWithRootObject:cell.driveTime];
            for (int a = 1; a < job.driveTimes.count; a++) {
                UIButton *driveButton = [NSKeyedUnarchiver unarchiveObjectWithData: archivedButton];
                [driveButton setFont:[UIFont boldSystemFontOfSize:20.0f]];
                UILabel *driveTime = [NSKeyedUnarchiver unarchiveObjectWithData: archivedTime];
                [References cornerRadius:driveButton radius:8.0f];
                driveButton.alpha = 0;
                driveTime.alpha = 0;
                driveTime.text = [self timeFormatted:(int)job.driveTimes[a]];
                [driveButton setTitle:job.driveSerials[a] forState:UIControlStateNormal];
                driveButton.frame = CGRectMake(driveButton.frame.origin.x+driveButton.frame.size.width+8, driveButton.frame.origin.y, driveButton.frame.size.width, 48);
                driveTime.frame = CGRectMake(driveTime.frame.origin.x+driveTime.frame.size.width+8, driveTime.frame.origin.y, driveTime.frame.size.width, driveTime.frame.size.height);
                [cell.driveScroll addSubview:driveButton];
                [cell.driveScroll addSubview:driveTime];
                archivedButton = [NSKeyedArchiver archivedDataWithRootObject:driveButton];
                archivedTime = [NSKeyedArchiver archivedDataWithRootObject:driveTime];
            }
        }
        if (isSearching == true) {
            cell.timeCompleted.text = [NSString stringWithFormat:@"FOUND %@",searchField.text.uppercaseString];
        }
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
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.videoControls.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = cell.videoControls.bounds;
        maskLayer.path  = maskPath.CGPath;
        cell.videoControls.layer.mask = maskLayer;
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
        cell.driveScroll.contentSize = CGSizeMake((cell.driveButton.frame.origin.x + cell.driveButton.frame.size.width+16)*job.driveTimes.count, cell.driveScroll.contentSize.height);
        [References cornerRadius:cell.driveButton radius:8.0f];
        if (job.driveSerials.count > 0) {
            [cell.driveButton setTitle:job.driveSerials[0] forState:UIControlStateNormal];
            cell.driveTime.text = [self timeFormatted:(int)job.driveTimes[0]];
            NSData *archivedButton = [NSKeyedArchiver archivedDataWithRootObject: cell.driveButton];
            NSData *archivedTime = [NSKeyedArchiver archivedDataWithRootObject:cell.driveTime];
            for (int a = 1; a < job.driveTimes.count; a++) {
                UIButton *driveButton = [NSKeyedUnarchiver unarchiveObjectWithData: archivedButton];
                [driveButton setFont:[UIFont boldSystemFontOfSize:20.0f]];
                UILabel *driveTime = [NSKeyedUnarchiver unarchiveObjectWithData: archivedTime];
                [References cornerRadius:driveButton radius:8.0f];
                driveButton.alpha = 0;
                driveTime.alpha = 0;
                driveTime.text = [self timeFormatted:(int)job.driveTimes[a]];
                [driveButton setTitle:job.driveSerials[a] forState:UIControlStateNormal];
                driveButton.frame = CGRectMake(driveButton.frame.origin.x+driveButton.frame.size.width+8, driveButton.frame.origin.y, driveButton.frame.size.width, 48);
                driveTime.frame = CGRectMake(driveTime.frame.origin.x+driveTime.frame.size.width+8, driveTime.frame.origin.y, driveTime.frame.size.width, driveTime.frame.size.height);
                [cell.driveScroll addSubview:driveButton];
                [cell.driveScroll addSubview:driveTime];
                archivedButton = [NSKeyedArchiver archivedDataWithRootObject:driveButton];
                archivedTime = [NSKeyedArchiver archivedDataWithRootObject:driveTime];
            }
        }
        
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
                                                           if (date.length < 1) {
                                                               NSDate *dateM =[record objectForKey:@"modifiedAt"];
                                                               NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
                                                               [formatter setDateFormat:@"EEEE MMM d"];
                                                               NSString *dateString = [formatter stringFromDate:dateM];
                                                               date = dateString;
                                                               intUpcoming = intUpcoming + 1;
                                                               if (a == 0) {
                                                                   NSTimeInterval secondsBetween = [dateM timeIntervalSinceDate:[NSDate date]];
                                                                   int secondDifference = (int)secondsBetween;
                                                                   int dateDifference = secondDifference / 86400;
                                                                   if (dateDifference > 6) {
                                                                       int weekDifference = dateDifference / 7;
                                                                       if (weekDifference < 2) {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your next job is scheduled for about %i week from now.",weekDifference];
                                                                       } else {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your next job is scheduled for about %i weeks from now.",weekDifference];
                                                                       }
                                                                   } else if (dateDifference >= 1){
                                                                       if (dateDifference < 2) {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your next job is scheduled for about %i day from now.",dateDifference];
                                                                       } else {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your next job is scheduled for about %i days from now.",dateDifference];
                                                                       }
                                                                   } else {
                                                                       int hourDifference = secondDifference / 60;
                                                                       if (hourDifference < 2) {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your next job is scheduled for %i hour from now.",hourDifference];
                                                                       } else {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your next job is scheduled for %i hours from now.",hourDifference];
                                                                       }
                                                                       
                                                                   }
                                                               }
                                                           } else {
                                                               intComplete = intComplete + 1;
                                                               if (a == 0) {
                                                                   NSDate *dateM =[record objectForKey:@"modifiedAt"];
                                                                   NSTimeInterval secondsBetween = [dateM timeIntervalSinceDate:[NSDate date]];
                                                                   int secondDifference = (int)secondsBetween;
                                                                   int dateDifference = secondDifference / 86400;
                                                                   if (dateDifference > 6) {
                                                                       int weekDifference = dateDifference / 7;
                                                                       if (weekDifference < 2) {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your last job was completed about %i week ago.",weekDifference];
                                                                       } else {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your last job was completed about %i weeks ago..",weekDifference];
                                                                       }
                                                                   } else if (dateDifference >= 1){
                                                                       if (dateDifference < 2) {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your last job was completed about %i day ago.",dateDifference];
                                                                       } else {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your last job was completed about %i days ago.",dateDifference];
                                                                       }
                                                                   } else {
                                                                       int hourDifference = secondDifference / 60;
                                                                       if (hourDifference < 2) {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your last job was completed about %i hour ago.",hourDifference];
                                                                       } else {
                                                                           machineLearningLabel = [NSString stringWithFormat:@"Your last job was completed about %i hours ago",hourDifference];
                                                                       }
                                                                       
                                                                   }
                                                               }
                                                              
                                                           }
                                                           
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
                                                           jobObject *job = [[jobObject alloc] initWithType:videoURL andTimes:driveTimes andSerials:driveSerials andDate:date andCode:code];
                                                           [jobs addObject:job];
                                                           [savedJobs addObject:job];
                                                       } dispatch_sync(dispatch_get_main_queue(), ^{
                                                           clientInfo.text = machineLearningLabel;
                                                           [table reloadData];
                                                           ogTableHeight = table.frame.origin.y + ((intComplete + intUpcoming) * 308) + (2 * 45)+32;
                                                           if (intUpcoming == 0) {
                                                               ogTableHeight = ogTableHeight + 92;
                                                           }
                                                           scroll.contentSize = CGSizeMake([References screenWidth], ogTableHeight);
                                                           table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, [References screenWidth], ((intComplete + intUpcoming) * 308)+(2*45)+1000);
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
    if (scrollView.contentOffset.y > oldY) {
        // sscrolling down
        if (scrollView.contentOffset.y > clientName.frame.origin.y) {
            hideStatusBar = true;
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(bool finished){
                if (finished) {
                    nil;
                }
            }];
        }
    } else {
        if (scrollView.contentOffset.y < clientName.frame.origin.y) {
            hideStatusBar = false;
            
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(bool finished){
                if (finished) {
                    nil;
                }
            }];
        }
        // scrolling up
    }
    oldY = scrollView.contentOffset.y;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
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
@end
