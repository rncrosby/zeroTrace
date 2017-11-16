//
//  clientManagerCell.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 11/15/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface clientManagerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UILabel *clientCode;
@property (weak, nonatomic) IBOutlet UILabel *clientContactName;
@property (weak, nonatomic) IBOutlet UILabel *clientPhone;
@property (weak, nonatomic) IBOutlet UILabel *clientEmail;
@property (weak, nonatomic) IBOutlet UIButton *approveClient;
@property (weak, nonatomic) IBOutlet UIButton *declineClient;

@end
