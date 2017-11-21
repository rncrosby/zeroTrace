//
//  clientView.h
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "clientCell.h"
#import "References.h"
#import "jobObject.h"
#import "jobView.h"
#import <AVFoundation/AVFoundation.h>

@interface clientView : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    NSMutableArray *jobs,*savedJobs;
    UIView *line;
    __weak IBOutlet UILabel *clientName;
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UITextField *searchBar;
    __weak IBOutlet UIButton *searchButton;
    bool isSearching;
}
- (IBAction)searchButton:(id)sender;

@end
