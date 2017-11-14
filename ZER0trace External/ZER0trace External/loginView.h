//
//  loginView.h
//  ZER0trace External
//
//  Created by Robert Crosby on 11/13/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AESCrypt.h"
#import "References.h"
#import <CloudKit/CloudKit.h>
#import "clientView.h"

@interface loginView : UIViewController <UITextFieldDelegate> {
    
    __weak IBOutlet UITextField *username;
    __weak IBOutlet UITextField *password;
    __weak IBOutlet UILabel *card;
    __weak IBOutlet UIButton *signIn;
    
    
}

@end
