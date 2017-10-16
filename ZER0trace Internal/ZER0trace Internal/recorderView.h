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
#import <CloudKit/CloudKit.h>

@interface recorderView : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate> {
    CKRecordID *newJobRecord;
    int saveProgress;
    NSMutableArray *scannedDrives;
    int driveCount,recorderTimeInt;
    NSTimer *recorderTime;
    NSURL *outputURL;
    bool isRecording;
    __weak IBOutlet UITextField *barcode;
    LLSimpleCamera *recorder;
    __weak IBOutlet UIButton *recordButton;
    __weak IBOutlet UILabel *drivesScanned;
    __weak IBOutlet UIButton *simulateScan;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UICollectionView *drivesCollectionView;
    __weak IBOutlet UILabel *jobName;
    
    __weak IBOutlet UIScrollView *completeView;
    __weak IBOutlet UILabel *completeTitle;
    __weak IBOutlet UIProgressView *completeProgress;
    __weak IBOutlet UILabel *signatureCard;
    __weak IBOutlet UILabel *clientCode;
    NSString *clientCodeText;
    __weak IBOutlet UIView *signatureView;
    __weak IBOutlet UIButton *confirmDestructionButton;
    __weak IBOutlet UIButton *cancel;
    
}
- (IBAction)toggleRecording:(id)sender;
- (IBAction)simulateScan:(id)sender;
@property (nonatomic, assign) CKRecord *jobRecord;
@property (nonatomic, assign) NSString *recordID;
- (IBAction)confirmDestruction:(id)sender;
- (IBAction)cancel:(id)sender;

@end

