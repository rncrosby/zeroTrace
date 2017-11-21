//
//  loginView.h
//  ZER0trace External
//
//  Created by Robert Crosby on 11/13/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import <CloudKit/CloudKit.h>
#import "clientView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <FirebaseAuth/FirebaseAuth.h>
@import Firebase;


@interface loginView : UIViewController <UITextFieldDelegate> {
    CGRect cardOrigin;
    int currentCard;
    __weak IBOutlet UILabel *header;
    __weak IBOutlet UILabel *subHeader;
    __weak IBOutlet UILabel *usernameHeader;
    __weak IBOutlet UITextField *username;
    __weak IBOutlet UILabel *passwordHeader;
    __weak IBOutlet UITextField *password;
    __weak IBOutlet UILabel *contactNameHeader;
    __weak IBOutlet UITextField *contactName;
    __weak IBOutlet UILabel *contactPhoneHeader;
    __weak IBOutlet UITextField *contactPhone;
    FIRAuth *auth;
    
    
    
    __weak IBOutlet UILabel *card;
    __weak IBOutlet UIButton *signIn;
    __weak IBOutlet UIScrollView *scroll;
    __weak IBOutlet UIButton *jobCode;
    __weak IBOutlet UIButton *signUp;
    
}
- (IBAction)goToSignIn:(id)sender;
- (IBAction)goToJobCode:(id)sender;
- (IBAction)goToSignUp:(id)sender;
- (IBAction)continueButton:(id)sender;

@end
