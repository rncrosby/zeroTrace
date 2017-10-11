//
//  homeView.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QRCodeReaderViewController/QRCodeReaderViewController.h>
#import <QRCodeReaderViewController/QRCodeReader.h>
#import <CloudKit/CloudKit.h>
#import "References.h"
#import "recorderView.h"

@interface homeView : UIViewController <QRCodeReaderDelegate,UITextFieldDelegate> {
    QRCodeReaderViewController *vc;
    __weak IBOutlet UITextField *manualCode;
    __weak IBOutlet UILabel *manualCodeInstruction;
    __weak IBOutlet UILabel *scanCodeInstruction;
    __weak IBOutlet UIButton *scanCode;
    
    
    
    
}
- (IBAction)scanCode:(id)sender;

@end
