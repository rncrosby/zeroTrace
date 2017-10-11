//
//  homeView.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "homeView.h"

@interface homeView ()

@end

@implementation homeView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:NO showTorchButton:YES];
    
    // Set the presentation style
    vc.modalPresentationStyle =  UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    vc.delegate = self;
    
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        [vc dismissViewControllerAnimated:YES completion:^(void) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",resultAsString]];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
            
            [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                                inZoneWithID:nil
                                                           completionHandler:^(NSArray *results, NSError *error) {
                                                               if (results.count > 0) {
                                                                   CKRecord *record = results[0];
                                                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                                                       [UIView animateWithDuration:0.3 animations:^(void){
                                                                           manualCodeInstruction.alpha = 0;
                                                                           scanCodeInstruction.text = @"One moment while we prepare the job for";
                                                                           manualCode.alpha = 0;
                                                                           [scanCode setTitle:[record valueForKey:@"client"] forState:UIControlStateNormal];
                                                                       }];
                                                                       double delayInSeconds = 2.0;
                                                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                           UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                                           recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
                                                                           controller.jobRecord = record;
                                                                           //menu is only an example
                                                                           [self presentViewController:controller animated:YES completion:nil];
                                                                       });
                                                                       // Update the UI on the main thread.
                                                                   });
                                                                   
                                                               } else {
                                                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                                                       [References toastMessage:@"Error" andView:self andClose:NO];
                                                                       // Update the UI on the main thread.
                                                                   });
                                                                   
                                                               }
                                                           }];
        }];
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",textField.text]];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
        
        [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                            inZoneWithID:nil
                                                       completionHandler:^(NSArray *results, NSError *error) {
                                                           if (results.count > 0) {
                                                               CKRecord *record = results[0];
                                                               dispatch_sync(dispatch_get_main_queue(), ^{
                                                                   [UIView animateWithDuration:0.3 animations:^(void){
                                                                       manualCodeInstruction.alpha = 0;
                                                                       scanCodeInstruction.text = @"One moment while we prepare the job for";
                                                                       manualCode.alpha = 0;
                                                                       [scanCode setTitle:[record valueForKey:@"client"] forState:UIControlStateNormal];
                                                                   }];
                                                                   double delayInSeconds = 2.0;
                                                                   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                                   dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                       UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                                       recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
                                                                       controller.jobRecord = record;
                                                                       //menu is only an example
                                                                       [self presentViewController:controller animated:YES completion:nil];
                                                                   });
                                                                   // Update the UI on the main thread.
                                                               });
                                                               
                                                           } else {
                                                               dispatch_sync(dispatch_get_main_queue(), ^{
                                                                   [References toastMessage:@"Error" andView:self andClose:NO];
                                                                   // Update the UI on the main thread.
                                                               });
                                                               
                                                           }
                                                       }];
    return YES;
}

- (IBAction)scanCode:(id)sender {
    [self presentViewController:vc animated:YES completion:nil];
}
@end
