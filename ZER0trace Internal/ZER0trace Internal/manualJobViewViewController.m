//
//  manualJobViewViewController.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/23/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "manualJobViewViewController.h"

@interface manualJobViewViewController ()

@end

@implementation manualJobViewViewController

@synthesize delegate;

- (void)viewDidLoad {
    code = @"";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)append:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (code.length < 5) {
        code = [NSString stringWithFormat:@"%@%i",code,(int)button.tag];
    }
    codeView.text = code;
}

- (IBAction)deleteKey:(id)sender {
    if ([code length] > 0) {
        code = [code substringToIndex:[code length] - 1];
        codeView.text = code;
        if (code.length == 0) {
            codeView.text = @"-----";
        }
    } else {
        codeView.text = @"-----";
    }
}

- (IBAction)next:(id)sender {
        NSString *newCode = [References randomIntWithLength:5];
        
        NSString *clientCode = code;
        NSString __block *clientName = @"";
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:clientCode];
        [[CKContainer defaultContainer].publicCloudDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [References toastMessage:@"No Client Found" andView:self andClose:YES];
                });
                return;
            }
            clientName = [record valueForKey:@"clientName"];
            NSMutableArray *allJobCodes = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"allJobCodes"]];
            
            [allJobCodes addObject:newCode];
            NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMMM d"];
            NSMutableArray *allJobDates = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"allJobDates"]];
            [allJobDates addObject:[formatter stringFromDate:[NSDate date]]];
            record[@"allJobCodes"] = allJobCodes;
            record[@"allJobDates"] = allJobDates;
            [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                NSLog(@"%@",error.localizedDescription);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    CKRecord *newJobRecord = [[CKRecord alloc] initWithRecordType:@"Job" recordID:[[CKRecordID alloc] initWithRecordName:newCode]];
                    newJobRecord[@"client"] = clientName;
                    newJobRecord[@"code"] = newCode;
                    [[CKContainer defaultContainer].publicCloudDatabase saveRecord:newJobRecord completionHandler:^(CKRecord *record, NSError *error) {
                        if (!error) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self dismissViewControllerAnimated:YES completion:^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshJobs" object:nil userInfo:nil];
                                }];
                            });
                        } else {
                            NSLog(@"%@",error.localizedDescription);
                        }
                        
                    }];
                });
            }];
        }];
        //compare the current password and do action here
        
}



- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
