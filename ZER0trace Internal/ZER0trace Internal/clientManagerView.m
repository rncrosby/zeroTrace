//
//  clientManagerView.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 11/15/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "clientManagerView.h"

@interface clientManagerView ()

@end

@implementation clientManagerView

- (void)viewDidLoad {
    [References cornerRadius:closeView radius:7.0f];
    [References cornerRadius:createClient radius:7.0f];
    [References createLine:self.view xPos:0 yPos:clientManagerTitle.frame.origin.y+clientManagerTitle.frame.size.height+8 inFront:YES];
    [References createLine:self.view xPos:0 yPos:closeView.frame.origin.y-9 inFront:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    ref = [[FIRDatabase database] reference];
}
-(void)viewDidAppear:(BOOL)animated {
    [self getPendingAccounts];
}

-(void)getPendingAccounts {
    [pendingAccounts removeAllObjects];
    pendingAccounts = [[NSMutableArray alloc] init];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *accounts = snapshot.value;
        if (![[NSString stringWithFormat:@"%@",accounts] isEqualToString:@"<null>"]) {
            [accounts enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                accountObject *account = [[accountObject alloc] initWithType:key andClient:[obj valueForKey:@"client"] andCode:[obj valueForKey:@"code"] andContactName:[obj valueForKey:@"client"] andEmail:[obj valueForKey:@"email"] andPhone:[obj valueForKey:@"phone"]];
                [pendingAccounts addObject:account];
                // Set stop to YES when you wanted to break the iteration.
            }];
            [clientsTable reloadData];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshJobs" object:nil userInfo:nil];
            }];
        }

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return pendingAccounts.count;    //count number of row from counting array hear cataGorry is An Array
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"clientManagerCell";
    
    clientManagerCell *cell = (clientManagerCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"clientManagerCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    accountObject *account = pendingAccounts[indexPath.row];
    cell.clientName.text = account.client;
    cell.clientCode.text = account.code;
    cell.clientContactName.text = account.contactName;
    cell.clientEmail.text = account.email;
    cell.clientPhone.text = account.phone;
    [References cornerRadius:cell.approveClient radius:7.0f];
    [References cornerRadius:cell.declineClient radius:7.0f];
    cell.approveClient.tag = indexPath.row;
    cell.declineClient.tag = indexPath.row;
    [cell.approveClient addTarget:self
               action:@selector(approveClient:) forControlEvents:UIControlEventTouchUpInside];
    [cell.declineClient addTarget:self
                           action:@selector(declineClient:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)declineClient:(UIButton*)sender {
    accountObject *account = pendingAccounts[sender.tag];
    FIRDatabaseReference *objectRef = [ref child:account.idName];
    [objectRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference *_Nonnull ref){
        [self getPendingAccounts];
    }];
}
    
-(void)approveClient:(UIButton*)sender {
    accountObject *account = pendingAccounts[sender.tag];
    CKRecord *newJobRecord = [[CKRecord alloc] initWithRecordType:@"Clients" recordID:[[CKRecordID alloc] initWithRecordName:account.code]];
    newJobRecord[@"clientName"] = account.client;
    newJobRecord[@"userCode"] = account.code;
    newJobRecord[@"contactName"] = account.contactName;
    newJobRecord[@"phone"] = account.phone;
    newJobRecord[@"email"] = account.email;
    [[CKContainer defaultContainer].publicCloudDatabase saveRecord:newJobRecord completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                FIRDatabaseReference *objectRef = [ref child:account.idName];
                [objectRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference *_Nonnull ref){
                    [self getPendingAccounts];
                }];
            });
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 304;
    
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createClient:(id)sender {
    [References toastMessage:@"Not Active" andView:self andClose:NO];
}
@end
