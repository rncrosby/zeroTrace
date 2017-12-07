//
//  upcomingJobCell.h
//  ZER0trace External
//
//  Created by Robert Crosby on 12/3/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface upcomingJobCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *calanderButton;
@property (weak, nonatomic) IBOutlet UILabel *calendarMonth;
@property (weak, nonatomic) IBOutlet UILabel *calendarDate;
@property (weak, nonatomic) IBOutlet UILabel *shadow;


@end
