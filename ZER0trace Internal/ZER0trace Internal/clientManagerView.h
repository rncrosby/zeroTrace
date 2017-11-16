//
//  clientManagerView.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 11/15/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "accountObject.h"
#import "References.h"
#import "clientManagerCell.h"
#import <FirebaseDatabase/FIRDatabaseReference.h>

@interface clientManagerView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    FIRDatabaseReference *ref;
    NSMutableArray *pendingAccounts;
    __weak IBOutlet UIButton *closeView;
    __weak IBOutlet UIButton *createClient;
    __weak IBOutlet UILabel *clientManagerTitle;
    __weak IBOutlet UITableView *clientsTable;
}
- (IBAction)closeView:(id)sender;
- (IBAction)createClient:(id)sender;

@end
