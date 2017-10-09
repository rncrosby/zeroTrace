//
//  ViewController.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "References.h"
#import <UIKit/UIKit.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <LLSimpleCamera/LLSimpleCamera.h>
#import "driveObject.h"

@interface ViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate> {
    NSMutableArray *scannedDrives;
    int driveCount,recorderTimeInt;
    NSTimer *recorderTime;
    NSURL *outputURL;
    bool isRecording;
    LLSimpleCamera *recorder;
    __weak IBOutlet UIButton *recordButton;
    __weak IBOutlet UILabel *drivesScanned;
    __weak IBOutlet UIButton *simulateScan;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UICollectionView *drivesCollectionView;
    __weak IBOutlet UITextField *jobName;
    __weak IBOutlet UIScrollView *completeView;
    __weak IBOutlet UILabel *completeTitle;
    __weak IBOutlet UIProgressView *completeProgress;
    __weak IBOutlet UILabel *signatureCard;
    __weak IBOutlet UILabel *clientCode;
    NSString *clientCodeText;
}
- (IBAction)toggleRecording:(id)sender;
- (IBAction)simulateScan:(id)sender;


@end

