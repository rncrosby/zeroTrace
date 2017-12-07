//
//  clientView.h
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "clientCell.h"
#import "References.h"
#import "jobObject.h"
#import <ZXMultiFormatWriter.h>
#import <ZXImage.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/CAAnimation.h>
#import <FirebaseDatabase/FIRDatabaseReference.h>
#import "headerView.h"
#import <CTVideoPlayerView/CTVideoViewCommonHeader.h>
#import "newJobCell.h"
#import "newJobView.h"
#import "upcomingJobObject.h"
#import "upcomingJobCell.h"
#import <MapKit/MapKit.h>
#import "driveObject.h"

@interface clientView : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate> {
    NSMapTable *hashedSerials;
    NSTimer *scrollTimer;
    bool videoPlaying,disableScrolling;
    bool hasReloaded;
    int probableResult;
    clientCell *expandedCell;
    CGRect ogCellShadow,ogCellCard,ogBottomBlur;
    int ogTableHeight;
    int indexSelected;
    int jobCountTotal;
    NSMutableArray *upcomingJobs,*jobs,*savedJobs;
    __weak IBOutlet UILabel *clientName;
    __weak IBOutlet UILabel *clientInfo;
    __weak IBOutlet UILabel *driveCount;
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UILabel *filmRuntime;
    __weak IBOutlet UILabel *destructionCount;
    __weak IBOutlet UIButton *menu;
    int driveTotal, hourFootage, destructions;
    //    __weak IBOutlet UITextField *searchBar;
//    __weak IBOutlet UIButton *searchButton;
    NSString *machineLearningLabel;
    __weak IBOutlet UIScrollView *scroll;
    int oldY,intUpcoming,intComplete;
    bool isSearching,hideStatusBar;
    __weak IBOutlet UITextField *searchField;
    __weak IBOutlet UIButton *searchButton;
    float lastProgress;
    BOOL menuShowing;
    
    // menu views
    
    __weak IBOutlet UIImageView *menuLogo;
}
@property (strong, nonatomic) FIRDatabaseReference *ref;
- (IBAction)searchButton:(id)sender;
- (IBAction)toggleMenu:(id)sender;
-(void)addDrive:(driveObject*)headDrive appendDrive:(driveObject*)appendDrive;
@end
