//
//  peripheralCamera.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 12/20/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "peripheralCamera.h"

@interface peripheralCamera ()

@end

@implementation peripheralCamera

-(BOOL) prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}

-(void)connectCamera {
    camRef = [[[FIRDatabase database] reference] child:@"activeJobs"];
    NSMutableArray *array = [fixedInfo objectForKey:@"cameras"];
    array[thisCamera] = @"CONNECTED";
    [fixedInfo setValue:array forKey:@"cameras"];
    [[camRef child:[fixedInfo valueForKey:@"code"]] setValue:fixedInfo withCompletionBlock:^void(NSError * _Nullable __strong error, FIRDatabaseReference * _Nonnull __strong ref){
        cameraNumber.text = [NSString stringWithFormat:@"CAMERA %i",thisCamera + 1];
        cameraStatus.text = @"READY";
        if (cameraReady != true) {
            [self prepareCamera];
        }
    }];
}

-(void)camListen {
    reference = [[FIRDatabase database] reference];
    [[reference child:@"activeJobs"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *postDict = snapshot.value;
        if (![[NSString stringWithFormat:@"%@",postDict] isEqualToString:@"<null>"]) {
            cameraNumber.hidden = NO;
            cameraStatus.hidden = NO;
            connect.hidden = YES;
            connectNote.hidden = YES;
            for (id key in postDict) {
                
                NSDictionary *obj = [postDict objectForKey:key];
                fixedInfo = obj;
                NSMutableArray *array = [fixedInfo objectForKey:@"cameras"];
                if (connected == false) {
                    for (int a = 0; a < array.count; a++) {
                        if (([array[a] isEqualToString:@"NOT CONNECTED"]) && (connected == false)) {
                            jobCode = [fixedInfo valueForKey:@"code"];
                            clientCode = [fixedInfo valueForKey:@"clientCode"];
                            connected = true;
                            thisCamera = a;
                            [self connectCamera];
                        }
                    }
                }
                NSString *command = [fixedInfo valueForKey:@"cameraStatus"];
                if ([command isEqualToString:@"record"]) {
                    if (recording == false) {
                        if (([array[thisCamera] isEqualToString:@"CONNECTED"]) && ([array[thisCamera + 1] isEqualToString:@"NOT CONNECTED"])) {
                            [fixedInfo setValue:@"recording" forKey:@"cameraStatus"];
                            FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"activeJobs"];
                            [[ref child:[fixedInfo valueForKey:@"code"]] setValue:fixedInfo];
                        }
                        [self startRecording];
                    }
                } else if (([command isEqualToString:@"recording"]) && (recording == false)) {
                    [self startRecording];
                }
                if ([command isEqualToString:@"pause"]) {
                    if (recording == true) {
                        [recorder stopRecording:^(LLSimpleCamera *camera, NSURL *outputURLVideo, NSError *error){
                            recording = false;
                            clipCount = clipCount + 1;
                            clipCountLabel.text = [NSString stringWithFormat:@"%i",clipCount];
                            cameraStatus.text = @"PAUSED";
                        }];
                    }
                }
                if ([command isEqualToString:@"upload"]) {
                    if (uploading == false) {
                        uploading = true;
                        cameraNumber.text = @"CAMERA 1";
                        cameraStatus.text = @"UPLOADING";
                        [self mergeAll];
                    }

                }
//                if (thisCamera > 0) {
//                    if ([command isEqualToString:@"record"]) {
//
//                    } else if ([command isEqualToString:@"pause"]) {
//                        [fixedInfo setValue:@"paused" forKey:@"cameraStatus"];
//                        FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"activeJobs"];
//                        [[ref child:[obj valueForKey:@"code"]] setValue:fixedInfo withCompletionBlock:^void(NSError * _Nullable __strong error, FIRDatabaseReference * _Nonnull __strong ref){
//                            if (!error) {
//
//                            }
//                        }];
//                    } else if ([command isEqualToString:@"upload"]) {
                //
//                    }
//                } else {
//
//                }
            }
        }else {
            [reference removeAllObservers];
            cameraNumber.hidden = YES;
            cameraStatus.hidden = YES;
            connect.hidden = NO;
            connectNote.hidden = NO;
            connected = false;
            uploading = false;
            cameraNumber.text = @"- - -";
        }
    }];
}

- (void)viewDidLoad {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    uploading = false;
    connected = false;
    thisCamera = -1;
    cameraReady = false;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    clipCount = 0;
    cameraReady = true;
}
-(void)startRecording {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *documentsURL = [NSURL fileURLWithPath:documentsDirectory];
    NSURL *outputURL = [[documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"asdfg_%i",clipCount]] URLByAppendingPathExtension:@"mov"];
    [recorder startRecordingWithOutputUrl:outputURL];
    cameraStatus.text = @"RECORDING";
    recording = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mergeAll {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Compressing Video"
                                                                   message:@"Please be patient..."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    NSString* myDocumentPath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[References randomStringWithLength:16]]];
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
                [alert dismissViewControllerAnimated:YES completion:^(void){
                    NSString *name = [NSString stringWithFormat:@"%@_camera%i",[References randomStringWithLength:16],thisCamera];
                    [self uploadFile:url withName:name];
                }];
                NSLog(@"complete");
                break;
        }
        
    }];
}

-(void)uploadFile:(NSURL*)url withName:(NSString*)name{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uploading Video"
                                                                   message:@"Please be patient..."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    // Create a reference to the file you want to upload
    FIRStorageReference *riversRef = [storageRef child:[NSString stringWithFormat:@"recordings/%@.mov",name]];
    
    // Upload the file to the path "images/rivers.jpg"
    [riversRef putFile:url metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:clientCode];
            [[[ref child:jobCode] child:[NSString stringWithFormat:@"camera-%i",thisCamera]] setValue:metadata.downloadURL.absoluteString];
            cameraNumber.text = @"- - -";
            cameraStatus.text = @"CLEANING UP";
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
            for (NSString *filename in fileArray)  {
                [fileMgr removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
            cameraStatus.text = @"READY";
            thisCamera = -1;
            [recorder stop];
            [reference removeAllObservers];
            [camRef removeAllObservers];
            [alert dismissViewControllerAnimated:YES completion:^(void){
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
}

- (IBAction)connect:(id)sender {
    [self camListen];
}
@end
