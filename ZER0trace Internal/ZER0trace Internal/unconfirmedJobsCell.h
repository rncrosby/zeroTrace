//
//  unconfirmedJobsCell.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 12/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface unconfirmedJobsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@property (weak, nonatomic) IBOutlet UILabel *client;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
