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
    [References tintUIButton:backspace color:[UIColor darkTextColor]];
    [References createLine:self.view xPos:0 yPos:table.frame.origin.y inFront:YES];
    [References cornerRadius:clientList radius:7.0];
    code = @"";
    [super viewDidLoad];
    [self getClients];
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
    if (code.length == 5) {
        bool foundMatch = false;
        for (int a = 0; a < clients.count; a++) {
            accountObject *client = clients[a];
            if ([client.code isEqualToString:code]) {
                foundMatch = true;
                clientName.text = client.client;
                break;
            }
        }
        if (foundMatch == false) {
            clientName.text = @"Client Not Found";
        }
    }
}

- (IBAction)deleteKey:(id)sender {
    if ([code length] > 0) {
        code = [code substringToIndex:[code length] - 1];
        codeView.text = code;
    }
    clientName.text = @"";
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
                    newJobRecord[@"clientCode"] = code;
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

-(void)getClients {
    [clients removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Clients" predicate:predicate];
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                           clients = [[NSMutableArray alloc] init];
                            for (int a = 0; a < results.count; a++) {
                                CKRecord *record = results[a];
                                accountObject *account = [[accountObject alloc] initWithType:[record valueForKey:@"clientName"] andClient:[record valueForKey:@"clientName"] andCode:[record valueForKey:@"userCode"] andContactName:[record valueForKey:@"contactName"] andEmail:[record valueForKey:@"email"] andPhone:[record valueForKey:@"phone"]];
                                [clients addObject:account];
                            
                            }
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            NSSortDescriptor *sortDescriptor;
                            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"client" ascending:YES];
                            NSArray *sortedArray = [clients sortedArrayUsingDescriptors:@[sortDescriptor]];
                            clients = [[NSMutableArray alloc] initWithArray:sortedArray];
                            [table reloadData];
            });
    }];
}

- (IBAction)clientList:(id)sender {
    if (table.alpha == 0) {
        [clientList setTitle:@"Back to Code Entry" forState:UIControlStateNormal];
        [References fadeIn:table];
    } else {
        [clientList setTitle:@"See List of Client Codes" forState:UIControlStateNormal];
        [References fadeOut:table];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return clients.count;    //count number of row from counting array hear cataGorry is An Array
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"clientListCell";
    
    clientListCell *cell = (clientListCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"clientListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    accountObject *account = clients[indexPath.row];
    cell.clientName.text = account.client;
    [cell.clientCode setTitle:account.code forState:UIControlStateNormal];
    [cell.clientCode.layer setBorderColor:cell.clientCode.titleLabel.textColor.CGColor];
    [cell.clientCode.layer setBorderWidth:1.0f];
    cell.clientCode.tag = indexPath.row;
    [References cornerRadius:cell.clientCode radius:8.0f];
    [cell.clientCode addTarget:self
                           action:@selector(useClient:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)useClient:(UIButton*)button {
    accountObject *account = clients[button.tag];
    [codeView setText:account.code];
    code = account.code;
    clientName.text = account.client;
    [References fadeOut:table];
}
@end
