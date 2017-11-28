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
    indexSelected = -1;
    isSearching = false;
    hideStatusBar = false;
    [self getClientJobs];
    [super viewDidLoad];
//    [searchBar addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view.
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

        return intUpcoming;
    } else {
        return intComplete;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == indexSelected) {
        return [References screenHeight];
    }
    return 332;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 57;
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
        table.frame = CGRectMake(0, table.frame.origin.y, [References screenWidth], table.frame.size.height+332-[References screenHeight]);
        scroll.contentSize = CGSizeMake([References screenWidth],  table.frame.origin.y+tableView.frame.size.height);
    } else {
        table.frame = CGRectMake(0, table.frame.origin.y, [References screenWidth], table.frame.size.height-332+[References screenHeight]);
        scroll.contentSize = CGSizeMake([References screenWidth],  table.frame.origin.y+table.frame.size.height);
    }
    indexSelected = (int)indexPath.row;
    [scroll setContentOffset:CGPointMake(0, (indexPath.row * 324)+(2*45)+table.frame.origin.y+40) animated:YES];
    [UIView animateWithDuration: 0.25 animations: ^{
        clientCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.card.frame = CGRectMake(16,  cell.card.frame.origin.y, cell.card.frame.size.width, [References screenHeight]-40);
        cell.mapView.frame = CGRectMake(16,  cell.mapView.frame.origin.y, cell.mapView.frame.size.width, [References screenHeight]-40);
        cell.bottomBlur.frame = CGRectMake(16, cell.bottomBlur.frame.origin.y, cell.bottomBlur.frame.size.width, cell.bottomBlur.frame.size.height);
    }];
    [tableView beginUpdates];
    [tableView endUpdates];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"clientCell";
    
    clientCell *cell = (clientCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"clientCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [References cornerRadius:cell.playButton radius:cell.playButton.frame.size.width/2];
    [References tintUIButton:cell.playButton color:cell.drives.textColor];
//    cell.playButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [References cornerRadius:cell.mapView radius:12.0f];
    cell.backgroundColor = [UIColor clearColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    jobObject *job = jobs[indexPath.row];
    [References cornerRadius:cell.card radius:  12.0f];
    cell.date.text = job.dateOfDestruction;

        cell.drives.text = [NSString stringWithFormat:@"%lu\nDrives",(unsigned long)job.driveSerials.count];
    [References blurView:cell.playButton];
    [References lightCardShadow:cell.shadow];
    [References blurView:cell.bottomBlur];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bottomBlur.bounds byRoundingCorners:(UIRectCornerTopRight | UIRectCornerTopLeft) cornerRadii:CGSizeMake(12.0, 12.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    cell.bottomBlur.layer.mask = maskLayer;
    [References cardshadow:cell.playButton];
    cell.playButton.tag = indexPath.row;
    [cell.playButton addTarget:self action:@selector(openView:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)openView:(id)sender {

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
                                                           int height = table.frame.origin.y + ((intComplete + intUpcoming) * 324) + (2 * 45)+16;
                                                           scroll.contentSize = CGSizeMake([References screenWidth], height);
                                                           table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, [References screenWidth], ((intComplete + intUpcoming) * 324)+(2*45)+1000);
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}
@end
