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

@interface clientView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *jobs;
    __weak IBOutlet UIImageView *image;
    __weak IBOutlet UITableView *table;
}

@end
