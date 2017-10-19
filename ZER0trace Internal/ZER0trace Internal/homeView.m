//
//  homeView.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "homeView.h"

@interface homeView ()

@end

@implementation homeView

- (void)viewDidLoad {
    [References blurView:menuBar];
    [References createLine:self.view xPos:0 yPos:menuBar.frame.size.height inFront:YES];
    scrollView.contentSize = CGSizeMake([References screenWidth], recentJobs.frame.origin.y+recentJobs.frame.size.height+16);
    scrollView.frame = CGRectMake(0, 0, [References screenWidth], [References screenHeight]);
    [super viewDidLoad];
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:NO showTorchButton:NO];
    
    // Set the presentation style
    vc.modalPresentationStyle =  UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    vc.delegate = self;
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        [vc dismissViewControllerAnimated:YES completion:^(void) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",resultAsString]];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
            
            [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                                inZoneWithID:nil
                                                           completionHandler:^(NSArray *results, NSError *error) {
                                                               if (results.count > 0) {
                                                                   CKRecord *record = results[0];
                                                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                                                           UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                                           recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
                                                                           controller.jobRecord = record;
                                                                           //menu is only an example
                                                                           [self presentViewController:controller animated:YES completion:nil];
                                                                       // Update the UI on the main thread.
                                                                   });
                                                                   
                                                               } else {
                                                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                                                       [References toastMessage:@"Error" andView:self andClose:NO];
                                                                       // Update the UI on the main thread.
                                                                   });
                                                                   
                                                               }
                                                           }];
        }];
    }];
    [self getUpcoming];
    
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1) {
        // upcoming
        return nextJobs.count;
    } else if (collectionView.tag == 2){
        // past
         return completedJobs.count;
    } else {
        // new
        return 3;
    }
   
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 1) {
        // upcoming
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        jobObject *job = nextJobs[indexPath.row];
        UILabel *client = (UILabel *)[cell viewWithTag:2];
        UILabel *code = (UILabel *)[cell viewWithTag:3];
        client.text = job.client;
        code.text = job.code;
        [References cornerRadius:card radius:24.0f];
        return cell;
    } else if (collectionView.tag == 2){
        // past
        jobObject *job = completedJobs[indexPath.row];
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        UILabel *date = (UILabel *)[cell viewWithTag:2];
        NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMMM d"];
        date.text = [[formatter stringFromDate:job.dateCompleted] uppercaseString];
        UILabel *client = (UILabel *)[cell viewWithTag:3];
        client.text = job.client;
        UILabel *code = (UILabel *)[cell viewWithTag:4];
        code.text = job.code;
        UILabel *drives = (UILabel *)[cell viewWithTag:5];
        drives.text = [NSString stringWithFormat:@"%lu DRIVES",(unsigned long)job.driveTimes.count];
        [References cornerRadius:card radius:24.0f];
        return cell;
    } else {
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        UIImageView *icon = (UIImageView *)[cell viewWithTag:2];
        UILabel *title = (UILabel *)[cell viewWithTag:3];
        if (indexPath.row == 0) {
            [icon setImage:[UIImage imageNamed:@"code.png"]];
            title.text = @"Scan Code";
        }
        if (indexPath.row == 1) {
            [icon setImage:[UIImage imageNamed:@"text.png"]];
            title.text = @"Enter Code";
        }
        if (indexPath.row == 2) {
            [icon setImage:[UIImage imageNamed:@"plus.png"]];
            title.text = @"New Job";
        }
        [References cornerRadius:card radius:24.0f];
        return cell;
    }
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
            controller.jobRecord = nextJobRecords[indexPath.row];
            //menu is only an example
            [self presentViewController:controller animated:YES completion:nil];
    } else if (collectionView.tag == 2) {
        // past
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        pastJobView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"pastJobView"];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.job = completedJobs[indexPath.row];
        //menu is only an example
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (indexPath.row == 0) {
            [self presentViewController:vc animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Code" message:@"Code is 5 characters long" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"00000";
                textField.textAlignment = NSTextAlignmentCenter;
            }];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Next" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self manualCode:[[alertController textFields][0] text]];
            }];
            [alertController addAction:confirmAction];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        if (indexPath.row == 2) {
            [self newJob];
        }
    }
}


-(void)manualCode :(NSString*)code{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",code]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (results.count > 0) {
                                                           CKRecord *record = results[0];
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               [UIView animateWithDuration:0.3 animations:^(void){
                                                                   //
                                                               }];
                                                               double delayInSeconds = 2.0;
                                                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                   UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                                   recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
                                                                   controller.jobRecord = record;
                                                                   //menu is only an example
                                                                   [self presentViewController:controller animated:YES completion:nil];
                                                               });
                                                               // Update the UI on the main thread.
                                                           });
                                                           
                                                       } else {
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               [References toastMessage:@"Error" andView:self andClose:NO];
                                                               // Update the UI on the main thread.
                                                           });
                                                           
                                                       }
                                                   }];
}

-(void)newJob {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Client Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Job Name";
        textField.secureTextEntry = NO;
    }];
    UIAlertAction *create = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *code = [References randomIntWithLength:5];
        NSString *jobTitle = [[alertController textFields][0] text];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Job" recordID:[[CKRecordID alloc] initWithRecordName:code]];
        
        record[@"client"] = jobTitle;
        record[@"code"] = code;
        [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [nextJobs addObject:[[jobObject alloc] initWithType:[record valueForKey:@"client"] andCode:[record valueForKey:@"code"] andURL:nil andDate:nil andSerials:nil andTimes:nil andSignature:nil]];
                    [nextJobRecords addObject:record];
                    [upcomingJobs reloadData];
                    [self setVisibility];
                });
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
            
        }];
        //compare the current password and do action here
        
    }];
    [alertController addAction:create];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@", result);
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)getUpcoming {
    [nextJobs removeAllObjects];
    [completedJobs removeAllObjects];
    [nextJobRecords removeAllObjects];
    [completedJobs removeAllObjects];
    upcomingJobs.hidden = YES;
    recentJobs.hidden = YES;
    locallySaved = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *documentsURL = [NSURL fileURLWithPath:documentsDirectory];
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        [locallySaved addObject:file];
    }
    nextJobs = [[NSMutableArray alloc] init];
    completedJobs = [[NSMutableArray alloc] init];
    nextJobRecords = [[NSMutableArray alloc] init];
    completedJobsRecord = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"TRUEPREDICATE"]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (results.count > 0) {
                                                           NSLog(@"%i",results.count);
                                                           for (int a = 0; a < results.count; a++) {
                                                               CKRecord *record = results[a];
                                                               if ([record valueForKey:@"videoURL"]) {
                                                                   NSArray *driveTimes = [record objectForKey:@"driveTimes"];
                                                                   NSArray *driveSerials = [record objectForKey:@"driveSerials"];
                                                                   NSData *signature = [record objectForKey:@"signatureData"];
                                                                   [completedJobs addObject:[[jobObject alloc] initWithType:[record valueForKey:@"client"] andCode:[record valueForKey:@"code"] andURL:[record valueForKey:@"videoURL"] andDate:[record objectForKey:@"dateCompleted"] andSerials:driveSerials andTimes:driveTimes andSignature:signature]];
                                                                   [completedJobsRecord addObject:record];
                                                               } else {
                                                                   [nextJobs addObject:[[jobObject alloc] initWithType:[record valueForKey:@"client"] andCode:[record valueForKey:@"code"] andURL:nil andDate:nil andSerials:nil andTimes:nil andSignature:nil]];
                                                                   [nextJobRecords addObject:record];
                                                               }
                                                           }
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               [upcomingJobs reloadData];
                                                               [recentJobs reloadData];
                                                               [self setVisibility];
                                                               // Update the UI on the main thread.
                                                           });
                                                           
                                                       } else {
                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                               
                                                               [self setVisibility];
                                                               // Update the UI on the main thread.
                                                           });
                                                       }
                                                   }];
}

-(void)setVisibility {
    if (nextJobs.count < 1) {
        [References fadeLabelText:noUpcomingJobs newText:@"No Upcoming Jobs"];
    } else {
        [References fadeOut:noUpcomingJobs];
        [References fadeIn:upcomingJobs];
    }
    if (completedJobs.count < 1) {
        [References fadeLabelText:noPastJobs newText:@"No Recent Jobs"];
    } else {
        [References fadeOut:noPastJobs];
        [References fadeIn:recentJobs];
    }
}
@end
