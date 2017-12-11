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
    [_job printObject];
    clipCount = 0;
    statusBar.backgroundColor = [UIColor clearColor];
    [References blurView:statusBar];
    [References cornerRadius:statusBar radius:24.0f];
    [References blurView:statusBarReal];
    [References blurView:drivesCollectionBlur];
    [References cornerRadius:drivesCollectionBlur radius:16.0f];
    clientCode.text = _job.code;
    code = _job.code;
    beforeRecording = true;
    completeView.frame = CGRectMake(0, 0, [References screenWidth], [References screenHeight]);
    [References fadeIn:completeView];
    saveProgress = 0;
    scannedDrives = [[NSMutableArray alloc] init];
    isRecording = false;
    [References cornerRadius:recordButton radius:recordButton.frame.size.width/2];
    //[References cornerRadius:signatureCard radius:5.0f];
    [References borderColor:recordButton color:[UIColor whiteColor]];
    [References borderColor:simulateScan color:[UIColor grayColor]];
    [References cornerRadius:simulateScan radius:simulateScan.frame.size.width/2];
    [References lightCardShadow:cancel];
    [self prepareCamera];
    [super viewDidLoad];
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM_dd_yyy"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    jobName.text = [NSString stringWithFormat:@"%@-%@",_job.client,dateString];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboard = [self.view convertRect:keyboardFrame fromView:self.view.window];
    NSLog(@"%f",keyboard.size.height);
    if (keyboard.size.height > 100) {
        if (useSimulator != true) {
            [barcode resignFirstResponder];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Scanner Connected" message:@"Use the settings app to pair a scanner" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *continueRecording = [UIAlertAction actionWithTitle:@"Proceed Using Simulator" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                useSimulator = true;
                [References fadeIn:simulateScan];
                [self startRecording];
            }];
            UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:root=Bluetooth"]];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel Job" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self cancel:self];
            }];
            [alert addAction:continueRecording];
            [alert addAction:settings];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            useSimulator = true;
            [References fadeIn:simulateScan];
            [self startRecording];
        }
        
    } else {
        // scanner connected
        [References moveUp:simulateScan yChange:keyboard.size.height-8];
        [References moveUp:recordButton yChange:keyboard.size.height-8];
        [References moveUp:drivesCollectionBlur yChange:keyboard.size.height-8];
        [References moveUp:drivesCollectionView yChange:keyboard.size.height-8];
        [barcode becomeFirstResponder];
        [self startRecording];
    }
}

-(void)prepareCamera {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // create camera with standard settings
    recorder = [[LLSimpleCamera alloc] init];
    
    // camera with video recording capability
    recorder =  [[LLSimpleCamera alloc] initWithVideoEnabled:YES];
    
    // camera with precise quality, position and video parameters.
    recorder = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPreset1280x720
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

-(void)startRecording {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *documentsURL = [NSURL fileURLWithPath:documentsDirectory];
    outputURL = [[documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"asdfg_%i",clipCount]] URLByAppendingPathExtension:@"mov"];
    compressedOutURL = documentsURL;
    [recorder startRecordingWithOutputUrl:outputURL];
    if (clipCount == 0) {
        recorderTimeInt = 0;
        recorderTime = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(incrementTime)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    [UIView animateWithDuration:0.3 animations:^(){
        [References cornerRadius:recordButton radius:16.0];
        [References borderColor:recordButton color:[UIColor whiteColor]];
    }];
    isRecording = TRUE;
    [References fadeButtonColor:recordButton color:[[UIColor whiteColor] colorWithAlphaComponent:0.6f]];
}


- (IBAction)toggleRecording:(id)sender {
    if (isRecording == FALSE) {
        [References fadeOut:comppleteRecordingStep];
        if (useSimulator == true) {
            [References fadeIn:simulateScan];
            [self startRecording];
        } else {
            [barcode becomeFirstResponder];
        }
    } else {
        clipCount = clipCount + 1;
        isRecording = FALSE;
        [References fadeIn:comppleteRecordingStep];
        [recorder stopRecording:^(LLSimpleCamera *camera, NSURL *outputURLVideo, NSError *error){
            [References fadeButtonColor:recordButton color:[[References colorFromHexString:@"#EE2B2A"] colorWithAlphaComponent:0.6f]];
            [UIView animateWithDuration:0.3 animations:^(){
                comppleteRecordingStep.alpha = 1;
                [References borderColor:recordButton color:[UIColor whiteColor]];
                [References cornerRadius:recordButton radius:recordButton.frame.size.width/2];
                
            }];
            [self checkFiles];
        }];
//        [completeProgress setProgress:0];
//        cancel.hidden = YES;
//        destructionButton.hidden = YES;
//        completeTitle.text = @"Saving Destruction";
//        [destructionButton setTitle:@"Complete Destruction" forState:UIControlStateNormal];
//        [completeSubtitle setText:@""];
//        [References moveUp:signatureView yChange:34];
//        [References moveUp:cancel yChange:34];
//        [References moveUp:destructionButton yChange:34];
//        [References moveUp:signatureCard yChange:34];
//        signatureSub.hidden = YES;
//        [signatureView setUserInteractionEnabled:NO];
//        [recorder stopRecording:^(LLSimpleCamera *camera, NSURL *outputURLVideo, NSError *error){
//            [self uploadFile:outputURLVideo withName:[NSString stringWithFormat:@"%@.mov",jobName.text]];
//            clientCode.text = [_jobRecord valueForKey:@"code"];
//            isRecording = FALSE;
//            [recorderTime invalidate];
//            completeView.alpha = 0;
//            completeView.hidden = NO;
//
//            [References fadeButtonColor:recordButton color:[[References colorFromHexString:@"#EE2B2A"] colorWithAlphaComponent:0.6f]];
//            [UIView animateWithDuration:0.3 animations:^(){
//                [References borderColor:recordButton color:[UIColor whiteColor]];
//                completeView.alpha = 1;
//                [self.view bringSubviewToFront:completeView];
//                [References cornerRadius:recordButton radius:recordButton.frame.size.width/2];
//            }];
//        }];
    }
}

-(void)checkFiles {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        NSLog(@"%@",file);
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
    if (scannedDrives.count > 1) {
        if (indexPath.row == 0 || indexPath.row == scannedDrives.count-2) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width-1, 8, 1, cell.frame.size.height-16)];
            [view setBackgroundColor:[UIColor whiteColor]];
            view.alpha = 0.5f;
            [cell addSubview:view];
            [cell bringSubviewToFront:view];
        }
    }
    
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
        FIRStorageReference *riversRef = [storageRef child:[NSString stringWithFormat:@"recordings/%@.mov",name]];
        
        // Upload the file to the path "images/rivers.jpg"
        FIRStorageUploadTask *uploadTask = [riversRef putFile:url metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                [self saveScanData:metadata.downloadURL];
            }
        }];
        [uploadTask observeStatus:FIRStorageTaskStatusProgress
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
//    NSString *randomURL = [References randomStringWithLength:16];
//    compressedOutURL = [compressedOutURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",randomURL]];
//    [self convertVideoToLowQuailtyWithInputURL:url outputURL:compressedOutURL handler:^(AVAssetExportSession *exportSession)
//     {
//         if (exportSession.status == AVAssetExportSessionStatusCompleted)
//
//         else
//         {
//             NSLog(exportSession.error.localizedDescription);
//
//         }
//     }];
    
}

-(void)saveScanData:(NSURL*)downloadURL{
    NSMutableArray *driveSerials = [[NSMutableArray alloc] init];
    NSMutableArray *driveTimes = [[NSMutableArray alloc] init];
    for (int a = 0; a < scannedDrives.count; a++) {
        driveObject *drive = scannedDrives[a];
        [driveSerials addObject:drive.serial];
        [driveTimes addObject:drive.time];
    }
    FIRDatabaseReference *reference = [[[[FIRDatabase database] reference] child:@"upcomingJobs"]  child:[NSString stringWithFormat:@"%@",_job.code]];
    [reference removeValueWithCompletionBlock:^void(NSError * _Nullable __strong error, FIRDatabaseReference * _Nonnull __strong ref){
        if (!error) {
                CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Job" recordID:[[CKRecordID alloc]initWithRecordName:_job.code]];
                record[@"location"] = _job.location;
                record[@"client"] = _job.clientName;
                record[@"clientCode"] = _job.client;
                record[@"code"] = _job.code;
                record[@"email"] = _job.email;
                record[@"jobDate"] = @"Date";
                record[@"signatueURL"] = signatureURL.absoluteString;
                record[@"signatureData"] = signatureData;
                record[@"videoURL"] = downloadURL.absoluteString;
                record[@"driveSerials"] = driveSerials;
                record[@"driveTimes"] = driveTimes;
                record[@"dateCompleted"] = [NSDate date];
                NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"EEEE, MMMM d"];
                record[@"jobDate"] = [formatter stringFromDate:[NSDate date]];
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
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
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

- (IBAction)confirmDestruction:(id)sender {
    if (beforeRecording == true) {
        [References fadeLabelText:completeTitle newText:@"Preparing..."];
        UIGraphicsBeginImageContext(signatureView.bounds.size);
        [[signatureView.layer presentationLayer] renderInContext:UIGraphicsGetCurrentContext()];
        signatureImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        signatureData = UIImageJPEGRepresentation(signatureImage, 1.0);
        FIRStorage *storage = [FIRStorage storage];
        FIRStorageReference *storageRef = [storage reference];
        // Create a reference to the file you want to upload
        FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
        metadata.contentType = @"image/jpeg";
        // Create a reference to the file you want to upload
        FIRStorageReference *riversRef = [storageRef child:[NSString stringWithFormat:@"images/%@.jpg",[References randomStringWithLength:16]]];
        
        // Upload the file to the path "images/rivers.jpg"
        FIRStorageUploadTask *uploadTask = [riversRef putData:signatureData
                                                     metadata:metadata
                                                   completion:^(FIRStorageMetadata *metadata,
                                                                NSError *error) {
                                                       if (error != nil) {
                                                           // Uh-oh, an error occurred!
                                                       } else {
                                                           // Metadata contains file metadata such as size, content-type, and download URL.
                                                           signatureURL = metadata.downloadURL;
                                                       }
                                                   }];
        [uploadTask observeStatus:FIRStorageTaskStatusProgress
                                                      handler:^(FIRStorageTaskSnapshot *snapshot) {
                                                          NSLog(@"%f",snapshot.progress.fractionCompleted);
                                                          [completeProgress setProgress:snapshot.progress.fractionCompleted animated:YES];
                                                          if (snapshot.progress.fractionCompleted > 0.50) {
                                                              [References fadeLabelText:completeTitle newText:@"Ready"];
                                                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                  //Here your non-main thread.
                                                                  [NSThread sleepForTimeInterval:1.0f];
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      //Here you returns to main thread.
                                                                      [References fadeOut:completeView];
                                                                      beforeRecording = false;
                                                                      
                                                                  });
                                                              });
                                                          }
                                                      }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshJobs" object:nil userInfo:nil];
        }];
    }
   

}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset1280x720];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeRecordingStep:(id)sender {
    [self mergeAll];
}

-(void)mergeAll {
    NSLog(@"starting merge");
    //Create the AVMutable composition to add tracks
    AVMutableComposition* composition = [[AVMutableComposition alloc]init];
    //Create the mutable composition track with video media type. You can also create the tracks depending on your need if you want to merge audio files and other stuffs.
    AVMutableCompositionTrack* composedTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *documentsURL = [NSURL fileURLWithPath:documentsDirectory];
    for (int a = clipCount-1; a >=0 ; a--) {
        NSLog(@"on clip: %i",a);
        NSURL *videoURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"asdfg_%i.mov",a]];
        AVURLAsset* video = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
        
        [composedTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video.duration)
                               ofTrack:[[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                atTime:kCMTimeZero error:nil];
        AVAssetTrack *assetVideoTrack = [video tracksWithMediaType:AVMediaTypeVideo].lastObject;
        [composedTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    }
    NSString* myDocumentPath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",jobName.text]];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath: myDocumentPath];
    
    //Check if the file exists then delete the old file to save the merged video file.
    if([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
    }
    
    // Create the export session to merge and save the video
    AVAssetExportSession*exporter = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=url;
    exporter.outputFileType=@"com.apple.quicktime-movie";
    exporter.shouldOptimizeForNetworkUse=YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch([exporter status])
        {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed to export video");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"export cancelled");
                break;
            case AVAssetExportSessionStatusCompleted:
                //Here you go you have got the merged video :)
                
                [self completeRecordingUpload:url];
                break;
            default:
                NSLog(@"somethings not right");
                break;
        }
        
    }];
}

-(void)completeRecordingUpload:(NSURL*)fileURL{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [completeProgress setProgress:0];
        cancel.hidden = YES;
        destructionButton.hidden = YES;
        completeTitle.text = @"Saving Destruction";
        [destructionButton setTitle:@"Complete Destruction" forState:UIControlStateNormal];
        [completeSubtitle setText:@""];
        [References moveUp:signatureView yChange:34];
        [References moveUp:cancel yChange:34];
        [References moveUp:destructionButton yChange:34];
        [References moveUp:signatureCard yChange:34];
        signatureSub.hidden = YES;
        [signatureView setUserInteractionEnabled:NO];
        [self uploadFile:fileURL withName:[NSString stringWithFormat:@"%@.mp4",jobName.text]];
        clientCode.text = _job.code;
        isRecording = FALSE;
        [recorderTime invalidate];
        completeView.alpha = 0;
        completeView.hidden = NO;
        [References fadeButtonColor:recordButton color:[[References colorFromHexString:@"#EE2B2A"] colorWithAlphaComponent:0.6f]];
        [UIView animateWithDuration:0.3 animations:^(){
            [References borderColor:recordButton color:[UIColor whiteColor]];
            completeView.alpha = 1;
            [self.view bringSubviewToFront:completeView];
            [References cornerRadius:recordButton radius:recordButton.frame.size.width/2];
        }];
    });
}
@end
