//
//  clientListCell.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 11/17/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface clientListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UIButton *clientCode;

@end
