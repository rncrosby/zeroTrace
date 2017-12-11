//
//  unconfirmedJobsView.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 12/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import "unconfirmedJobsCell.h"
#import <FirebaseDatabase/FIRDatabaseReference.h>
#import "unconfirmedJobObject.h"

@interface unconfirmedJobsView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *unconfirmedJobs;
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UIButton *close;
    FIRDatabaseReference *ref;
}
- (IBAction)closeButton:(id)sender;

@end
