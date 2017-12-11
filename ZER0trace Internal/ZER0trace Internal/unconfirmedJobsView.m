//
//  unconfirmedJobsView.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 12/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "unconfirmedJobsView.h"

@interface unconfirmedJobsView ()

@end

@implementation unconfirmedJobsView

- (void)viewDidLoad {
    [References cornerRadius:close radius:7.0f];
    [References createLine:self.view xPos:0 yPos:table.frame.origin.y inFront:YES];
    [References createLine:self.view xPos:0 yPos:close.frame.origin.y-9 inFront:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return unconfirmedJobs.count;    //count number of row from counting array hear cataGorry is An Array
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"unconfirmedJobsCell";
    
    unconfirmedJobsCell *cell = (unconfirmedJobsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"unconfirmedJobsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell.confirm.layer setBorderColor:cell.confirm.titleLabel.textColor.CGColor];
    [cell.confirm.layer setBorderWidth:1.0f];
    cell.confirm.tag = indexPath.row;
    [References cornerRadius:cell.confirm radius:8.0f];
    [cell.confirm addTarget:self
                        action:@selector(approveClient:) forControlEvents:UIControlEventTouchUpInside];
//    cell.clientName.text = account.client;
//    cell.clientCode.text = account.code;
//    cell.clientContactName.text = account.contactName;
//    cell.clientEmail.text = account.email;
//    cell.clientPhone.text = account.phone;
//    cell.approveClient.tag = indexPath.row;
//    cell.declineClient.tag = indexPath.row;
//    [cell.approveClient addTarget:self
//                           action:@selector(approveClient:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.declineClient addTarget:self
//                           action:@selector(declineClient:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)approveClient:(UIButton*)sender {
//    accountObject *account = pendingAccounts[sender.tag];
//    CKRecord *newJobRecord = [[CKRecord alloc] initWithRecordType:@"Clients" recordID:[[CKRecordID alloc] initWithRecordName:account.code]];
//    newJobRecord[@"clientName"] = account.client;
//    newJobRecord[@"userCode"] = account.code;
//    newJobRecord[@"contactName"] = account.contactName;
//    newJobRecord[@"phone"] = account.phone;
//    newJobRecord[@"email"] = account.email;
//    [[CKContainer defaultContainer].publicCloudDatabase saveRecord:newJobRecord completionHandler:^(CKRecord *record, NSError *error) {
//        if (!error) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                FIRDatabaseReference *objectRef = [ref child:account.idName];
//                [objectRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference *_Nonnull ref){
//                    [self getPendingAccounts];
//                }];
//            });
//        } else {
//            NSLog(@"%@",error.localizedDescription);
//        }
//
//    }];
}

-(void)viewWillAppear:(BOOL)animated {
    ref = [[FIRDatabase database] reference];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
