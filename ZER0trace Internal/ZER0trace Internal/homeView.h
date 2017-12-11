//
//  homeView.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pastJobView.h"
#import "clientManagerView.h"
#import <FirebaseDatabase/FIRDatabaseReference.h>
#import <QRCodeReaderViewController/QRCodeReaderViewController.h>
#import <QRCodeReaderViewController/QRCodeReader.h>
#import <CloudKit/CloudKit.h>
#import "unconfirmedJobsView.h"
#import "References.h"
#import "recorderView.h"
#import "jobObject.h"
#import <QuartzCore/QuartzCore.h>
#import "manualJobViewViewController.h"
#import "accountObject.h"
#import <MessageUI/MessageUI.h>
#import "unconfirmedJobObject.h"

@interface homeView : UIViewController <QRCodeReaderDelegate,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,MFMailComposeViewControllerDelegate> {
    UIAlertController *alert,*deletingJob,*refreshingJobs;
    NSMutableArray *pendingAccounts;
    QRCodeReaderViewController *vc;
    bool performSearch;
    __weak IBOutlet UITextField *search;
    int searchLength;
    NSMutableArray *nextJobs,*savedNextJobs,*completedJobs,*savedCompletedJobs,*nextJobRecords,*completedJobsRecord,*locallySaved;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UICollectionView *upcomingJobs;
    __weak IBOutlet UICollectionView *recentJobs;
    __weak IBOutlet UICollectionView *createJobs;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIProgressView *beginningProgress;
    __weak IBOutlet UILabel *noUpcomingJobs;
    __weak IBOutlet UILabel *noPastJobs;
    __weak IBOutlet UITextField *scannerCheck;
    __weak IBOutlet UIButton *checkScannerButton;
    __weak IBOutlet UILabel *clientCount;
    __weak IBOutlet UIButton *clientManagerButton;
    __weak IBOutlet UIButton *searchButton;
    
    // menu bar
    __weak IBOutlet UIImageView *logo;
    __weak IBOutlet UILabel *scannerSub;
    __weak IBOutlet UIButton *refreshButton;
    int unconfirmedJobInt;
}
@property (strong, nonatomic) FIRDatabaseReference *ref;
- (IBAction)createJob:(id)sender;
- (IBAction)checkScanner:(id)sender;
- (IBAction)refreshButton:(id)sender;
- (IBAction)clientManager:(id)sender;
- (IBAction)searchButton:(id)sender;
- (IBAction)jobManager:(id)sender;



@end
