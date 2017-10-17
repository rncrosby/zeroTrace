//
//  ViewController.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "recorderView.h"

@interface recorderView ()

@end

@implementation recorderView


- (void)viewDidLoad {
    completeView.frame = CGRectMake(0, 0, [References screenWidth], [References screenHeight]);
    saveProgress = 0;
    scannedDrives = [[NSMutableArray alloc] init];
    isRecording = false;
    [References cornerRadius:recordButton radius:recordButton.frame.size.width/2];
    [References cornerRadius:signatureCard radius:5.0f];
    [References borderColor:recordButton color:[UIColor whiteColor]];
    [References borderColor:simulateScan color:[UIColor grayColor]];
    [References cornerRadius:simulateScan radius:simulateScan.frame.size.width/2];
    [References lightCardShadow:cancel];
    [self prepareCamera];
    [super viewDidLoad];
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM_dd_yyy"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    jobName.text = [NSString stringWithFormat:@"%@-%@",[_jobRecord valueForKey:@"client"],dateString];
    [self getRecord];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)prepareCamera {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // create camera with standard settings
    recorder = [[LLSimpleCamera alloc] init];
    
    // camera with video recording capability
    recorder =  [[LLSimpleCamera alloc] initWithVideoEnabled:YES];
    
    // camera with precise quality, position and video parameters.
    recorder = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                              position:LLCameraPositionRear
                                          videoEnabled:YES];
    [recorder start];
    // attach to the view
    [recorder attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    [self.view sendSubviewToBack:recorder.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)toggleRecording:(id)sender {
    if (isRecording == FALSE) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *documentsURL = [NSURL fileURLWithPath:documentsDirectory];
        outputURL = [[documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",jobName.text]] URLByAppendingPathExtension:@"mov"];
        [recorder startRecordingWithOutputUrl:outputURL];
        recorderTime = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(incrementTime)
                                                          userInfo:nil
                                                           repeats:YES];
        recorderTimeInt = 0;
        [UIView animateWithDuration:0.3 animations:^(){
            [References cornerRadius:recordButton radius:4.0];
            [References borderColor:recordButton color:[UIColor grayColor]];
        }];
        [barcode becomeFirstResponder];
        isRecording = TRUE;
        [References fadeButtonColor:recordButton color:[UIColor whiteColor]];
    } else {
        [recorder stopRecording:^(LLSimpleCamera *camera, NSURL *outputURLVideo, NSError *error){
            [self uploadFile:outputURLVideo withName:[NSString stringWithFormat:@"%@.mov",jobName.text]];
            clientCodeText = [[References randomStringWithLength:5] uppercaseString];
            clientCode.text = clientCodeText;
            isRecording = FALSE;
            [recorderTime invalidate];
            completeView.alpha = 0;
            completeView.hidden = NO;
            
            [References fadeButtonColor:recordButton color:[References colorFromHexString:@"#EE2B2A"]];
            [UIView animateWithDuration:0.3 animations:^(){
                [References borderColor:recordButton color:[UIColor whiteColor]];
                completeView.alpha = 1;
                [self.view bringSubviewToFront:completeView];
                [References cornerRadius:recordButton radius:recordButton.frame.size.width/2];
            }];
        }];
    }
}

- (IBAction)simulateScan:(id)sender {
    driveObject *drive = [[driveObject alloc] initWithType:[References randomStringWithLength:8] andTime:recorderTimeInt];
    [scannedDrives addObject:drive];
    drivesScanned.text = [NSString stringWithFormat:@"%lu Drives Scanned",(unsigned long)scannedDrives.count];
    [drivesCollectionView reloadData];
     }

-(void)incrementTime {
    if (isRecording == TRUE) {
        recorderTimeInt++;
        timeLabel.text = [self timeFormatted:recorderTimeInt];
    }
}

- (NSString *)timeFormatted:(int)totalSeconds{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes, seconds];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return scannedDrives.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    driveObject *drive = scannedDrives[scannedDrives.count-indexPath.row-1];
    UILabel *serial = (UILabel *)[cell viewWithTag:1];
    UILabel *time = (UILabel *)[cell viewWithTag:2];
    serial.text = drive.serial;
    time.text = [self timeFormatted:drive.time.intValue];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    driveObject *drive = scannedDrives[scannedDrives.count-indexPath.row-1];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:drive.serial message:@"Deleting this serial is irreversible. Are you sure you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Delete Serial" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeSerialAtIndex:(int)indexPath.row];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)removeSerialAtIndex:(int)index {
    [scannedDrives removeObjectAtIndex:scannedDrives.count-index-1];
    drivesScanned.text = [NSString stringWithFormat:@"%lu Drives Scanned",(unsigned long)scannedDrives.count];
    [drivesCollectionView reloadData];
}

-(void)uploadFile:(NSURL*)url withName:(NSString*)name{
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    // Create a reference to the file you want to upload
    FIRStorageReference *riversRef = [storageRef child:[NSString stringWithFormat:@"recordings/%@",name]];
    
    // Upload the file to the path "images/rivers.jpg"
    FIRStorageUploadTask *uploadTask = [riversRef putFile:url metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            [self saveScanData:metadata.downloadURL];
        }
    }];
    FIRStorageHandle observer = [uploadTask observeStatus:FIRStorageTaskStatusProgress
                                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                                      [completeProgress setProgress:snapshot.progress.fractionCompleted animated:YES];
                                                      if (snapshot.progress.fractionCompleted == 1) {
                                                          saveProgress = saveProgress + 1;
                                                          completeTitle.text = @"Destruction Saved";
                                                          if (saveProgress == 2) {
                                                              [References fadeIn:confirmDestructionButton];
                                                          }
                                                      }
                                                  }];
}

-(void)saveScanData:(NSURL*)downloadURL{
    NSMutableArray *driveSerials = [[NSMutableArray alloc] init];
    NSMutableArray *driveTimes = [[NSMutableArray alloc] init];
    for (int a = 0; a < scannedDrives.count; a++) {
        driveObject *drive = scannedDrives[a];
        [driveSerials addObject:drive.serial];
        [driveTimes addObject:drive.time];
    }
    [[CKContainer defaultContainer].publicCloudDatabase fetchRecordWithID:newJobRecord completionHandler:^(CKRecord *record, NSError *error) {
        
        if (error) {
            return;
        }
        record[@"videoURL"] = downloadURL.absoluteString;
        record[@"driveSerials"] = driveSerials;
        record[@"driveTimes"] = driveTimes;
        record[@"dateCompleted"] = [NSDate date];
        [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            } else {
                saveProgress = saveProgress+1;
                if (saveProgress == 2) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [References fadeIn:confirmDestructionButton];
                    });
                }
            }
        }];
    }];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    driveObject *drive = [[driveObject alloc] initWithType:textField.text andTime:recorderTimeInt];
    [scannedDrives addObject:drive];
    drivesScanned.text = [NSString stringWithFormat:@"%lu Drives Scanned",(unsigned long)scannedDrives.count];
    [drivesCollectionView reloadData];
    [textField setText:@""];
    return YES;
}

-(void)getRecord{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",[_jobRecord valueForKey:@"code"]]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (results.count > 0) {
                                                           CKRecord *rec = results[0];
                                                           newJobRecord = rec.recordID;
                                                       } else {
                                                           NSLog(@"error");
                                                       }
                                                   }];
}
- (IBAction)confirmDestruction:(id)sender {
    [References fadeLabelText:completeTitle newText:@"Finishing Up..."];
    UIGraphicsBeginImageContext(signatureView.bounds.size);
    [[signatureView.layer presentationLayer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *postData = UIImageJPEGRepresentation(viewImage, 1.0);
    [[CKContainer defaultContainer].publicCloudDatabase fetchRecordWithID:newJobRecord completionHandler:^(CKRecord *record, NSError *error) {
        
        if (error) {
            return;
        }
        record[@"signatureData"] = postData;
        [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [References fadeLabelText:completeTitle newText:@"All Done"];
                        double delayInSeconds = 1.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                        // Update the UI on the main thread.
                    });
            }
        }];
    }];

}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
