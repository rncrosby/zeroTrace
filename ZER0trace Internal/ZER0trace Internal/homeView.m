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
    performSearch = false;
    [References cornerRadius:clientCount radius:clientCount.frame.size.width/2];
    [createJobs setBackgroundColor:[UIColor clearColor]];
    [recentJobs setBackgroundColor:[UIColor clearColor]];
    [upcomingJobs setBackgroundColor:[UIColor clearColor]];
    [References blurView:menuBar];
    [References createLine:self.view xPos:0 yPos:menuBar.frame.size.height inFront:YES];
    scrollView.contentSize = CGSizeMake([References screenWidth], recentJobs.frame.origin.y+recentJobs.frame.size.height+16);
    scrollView.frame = CGRectMake(0, 0, [References screenWidth], [References screenHeight]);
    [super viewDidLoad];
    // Create the reader object
    [self getUpcomingJobs];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdNewJob) name:@"refreshJobs" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [References createLine:self.view xPos:0 yPos:menuBar.frame.size.height inFront:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        alert = [UIAlertController alertControllerWithTitle:@"Connecting"
                                                    message:@"Looking for Scanner..."
                                             preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [scannerCheck becomeFirstResponder];
        });
    });
    [search addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    [self checkFiles];
    [self getUpcomingJobs];
    // Do any additional setup after loading the view.
}

-(void)createdNewJob {
    refreshingJobs = [UIAlertController alertControllerWithTitle:@"Publishing New Job"
                                                message:@"One Second..."
                                         preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:refreshingJobs animated:YES completion:nil];
    [self setVisibility];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getUpcomingJobs];
    });
}

-(void)checkFiles {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file] error:&error];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if ([References screenWidth] > 1024) {
        [References toastMessage:@"ZER0trace is not optimized for this iPad. Please use a 9.7\" device." andView:self andClose:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    _ref = [[FIRDatabase database] reference];
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboard = [self.view convertRect:keyboardFrame fromView:self.view.window];
    NSLog(@"%f",keyboard.size.height);
    if (keyboard.size.height > 100) {
        [checkScannerButton setTitle:@"No Scanner Found" forState:UIControlStateNormal];
    } else {
         [checkScannerButton setTitle:@"Scanner Connected" forState:UIControlStateNormal];
    }
    
    [scannerCheck resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)textChanged:(UITextField *)textField
{
    if (textField.text.length == 0) {
        nextJobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedNextJobs.count; a++) {
            [nextJobs addObject:savedNextJobs[a]];
        }
        completedJobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedCompletedJobs.count; a++) {
            [completedJobs addObject:savedCompletedJobs[a]];
        }
        [upcomingJobs reloadData];
        [recentJobs reloadData];
        [self setVisibility];
        return;
    }
    nextJobs = [[NSMutableArray alloc] init];
    completedJobs = [[NSMutableArray alloc] init];
    for (int a = 0; a < savedNextJobs.count; a++) {
        jobObject *tJob = savedNextJobs[a];
        if ([tJob.client localizedCaseInsensitiveContainsString:textField.text] || [tJob.code localizedCaseInsensitiveContainsString:textField.text]) {
            [nextJobs addObject:tJob];
        }
    }
    for (int a = 0; a < savedCompletedJobs.count; a++) {
        jobObject *tJob = savedCompletedJobs[a];
        if ([tJob.client localizedCaseInsensitiveContainsString:textField.text] || [tJob.code localizedCaseInsensitiveContainsString:textField.text]) {
            [completedJobs addObject:tJob];
        }
    }
    [upcomingJobs reloadData];
    [recentJobs reloadData];
    [self setVisibility];
}

-(bool)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 2) {
        [UIView animateWithDuration:0.25 animations:^(void){
            searchButton.alpha = 1;
            search.alpha = 1;
            [searchButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        }];
    }
    return true;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        nextJobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedNextJobs.count; a++) {
            [nextJobs addObject:savedNextJobs[a]];
        }
        completedJobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedCompletedJobs.count; a++) {
            [completedJobs addObject:savedCompletedJobs[a]];
        }
        [upcomingJobs reloadData];
        [recentJobs reloadData];
        [self setVisibility];
        
        [UIView animateWithDuration:0.25 animations:^(void){
            [search setText:@"Search by Client or Code"];
            searchButton.alpha = 1;
            [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        }];
    }
    [textField resignFirstResponder];
    return true;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1) {
        // upcoming
        return nextJobs.count;
    } else if (collectionView.tag == 2){
        // past
         return completedJobs.count;
    } else {
        // new
        return 3;
    }
   
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 1) {
        // upcoming
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        unconfirmedJobObject *job = nextJobs[indexPath.row];
        UILabel *client = (UILabel *)[cell viewWithTag:2];
        UILabel *code = (UILabel *)[cell viewWithTag:3];
        UIButton *deleteJob = (UIButton*)[cell viewWithTag:11];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:deleteJob.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(24.0, 24.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.view.bounds;
        maskLayer.path  = maskPath.CGPath;
        deleteJob.layer.mask = maskLayer;
        client.text = job.clientName;
        code.text = job.code;
        
        [References cornerRadius:card radius:24.0f];
        deleteJob.tag = (int)indexPath.row;
        if (job.isConfirmed.intValue == 1) {
            [deleteJob setTitle:@"Cancel Job" forState:UIControlStateNormal];
            [deleteJob addTarget:self action:@selector(handleDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [deleteJob setTitle:@"Confirm Job" forState:UIControlStateNormal];
            [deleteJob addTarget:self action:@selector(handleJobConfirm:) forControlEvents:UIControlEventTouchUpInside];
        }

        return cell;
    } else if (collectionView.tag == 2){
        // past
        jobObject *job = completedJobs[indexPath.row];
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        UILabel *date = (UILabel *)[cell viewWithTag:2];
        NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMMM d"];
        date.text = [[formatter stringFromDate:job.dateCompleted] uppercaseString];
        UILabel *client = (UILabel *)[cell viewWithTag:3];
        client.text = job.client;
        UILabel *code = (UILabel *)[cell viewWithTag:4];
        code.text = job.code;
        UILabel *drives = (UILabel *)[cell viewWithTag:5];
        drives.text = [NSString stringWithFormat:@"%lu DRIVES",(unsigned long)job.driveTimes.count];
        [References cornerRadius:card radius:24.0f];
        return cell;
    } else {
        static NSString *identifier = @"Cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        UILabel *card = (UILabel *)[cell viewWithTag:1];
        UIImageView *icon = (UIImageView *)[cell viewWithTag:2];
        UILabel *title = (UILabel *)[cell viewWithTag:3];
        if (indexPath.row == 0) {
            [icon setImage:[UIImage imageNamed:@"code.png"]];
            title.text = @"Scan Code";
        }
        if (indexPath.row == 1) {
            [icon setImage:[UIImage imageNamed:@"text.png"]];
            title.text = @"Enter Code";
        }
        if (indexPath.row == 2) {
            [icon setImage:[UIImage imageNamed:@"plus.png"]];
            title.text = @"New Job";
        }
        [References cornerRadius:card radius:24.0f];
        return cell;
    }
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
            controller.job = nextJobs[indexPath.row];
        
            //menu is only an example
            [self presentViewController:controller animated:YES completion:nil];
    } else if (collectionView.tag == 2) {
        // past
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        pastJobView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"pastJobView"];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.job = completedJobs[indexPath.row];
        //menu is only an example
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (indexPath.row == 0) {
            [self presentViewController:vc animated:YES completion:nil];
        }
        if (indexPath.row == 2) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            manualJobViewViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"manualJobViewViewController"];
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            //menu is only an example
            [self presentViewController:controller animated:YES completion:nil];
                // Update the UI on the main thread.
            
        }
    }
}

-(void)handleJobConfirm:(id)sender {
    UIButton *button = (UIButton*)sender;
    unconfirmedJobObject *job = nextJobs[button.tag];
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    
    // Configure the fields of the interface.
    [composeVC setToRecipients:@[job.email]];
    [composeVC setSubject:[NSString stringWithFormat:@"Confirmation: ZER0trace destruction of %@ drives on %@",job.drives,job.dateText]];
    composeVC.view.tag = button.tag;
    // Present the view controller modally.
    [self presentViewController:composeVC animated:YES completion:nil];
    FIRDatabaseReference *reference = [[[[FIRDatabase database] reference] child:@"upcomingJobs"] child:job.code];
    [reference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dictionary = snapshot.value;
        [dictionary setValue:@1 forKey:@"confirmed"];
        [reference updateChildValues:dictionary];
    }];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultCancelled) {
        unconfirmedJobObject *job = nextJobs[controller.view.tag];
        FIRDatabaseReference *reference = [[[[FIRDatabase database] reference] child:@"upcomingJobs"] child:job.code];
        [reference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *dictionary = snapshot.value;
            [dictionary setValue:@0 forKey:@"confirmed"];
            [reference updateChildValues:dictionary];
        }];
        [References toastMessage:@"You must email the client to confirm the job." andView:self andClose:NO];
    } else {
        NSLog(@"email sent");
        [self getUpcomingJobs];
    }
    
}


//-(void)manualCode :(NSString*)code{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",code]];
//    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
//
//    [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
//                                                        inZoneWithID:nil
//                                                   completionHandler:^(NSArray *results, NSError *error) {
//                                                       if (results.count > 0) {
//                                                           CKRecord *record = results[0];
//                                                           dispatch_sync(dispatch_get_main_queue(), ^{
//                                                               [UIView animateWithDuration:0.3 animations:^(void){
//                                                                   //
//                                                               }];
//                                                               double delayInSeconds = 2.0;
//                                                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                                                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                                                                   UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//                                                                   recorderView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"recorderView"];
//                                                                   controller.job = record;
//                                                                   //menu is only an example
//                                                                   [self presentViewController:controller animated:YES completion:nil];
//                                                               });
//                                                               // Update the UI on the main thread.
//                                                           });
//
//                                                       } else {
//                                                           dispatch_sync(dispatch_get_main_queue(), ^{
//                                                               [References toastMessage:@"Job Not Found" andView:self andClose:NO];
//                                                               // Update the UI on the main thread.
//                                                           });
//
//                                                       }
//                                                   }];
//}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@", result);
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)setVisibility {
    if (nextJobs.count < 1) {
        [References fadeIn:noUpcomingJobs];
        [References fadeLabelText:noUpcomingJobs newText:@"No Upcoming Jobs"];
    } else {
        [References fadeOut:noUpcomingJobs];
        [References fadeIn:upcomingJobs];
    }
    if (completedJobs.count < 1) {
        [References fadeIn:noPastJobs];
        [References fadeLabelText:noPastJobs newText:@"No Recent Jobs"];
    } else {
        [References fadeOut:noPastJobs];
        [References fadeIn:recentJobs];
    }
}
- (IBAction)createJob:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    manualJobViewViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"manualJobViewViewController"];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    //menu is only an example
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)checkScanner:(id)sender {
    alert = [UIAlertController alertControllerWithTitle:@"Connecting"
                                                message:@"Looking for Scanner..."
                                         preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [scannerCheck becomeFirstResponder];
    });
}

- (IBAction)refreshButton:(id)sender {
    [self getUpcomingJobs];
    [UIView animateWithDuration:0.25 animations:^(void){
        [search setText:@"Search by Client or Code"];
        [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    }];
}

- (IBAction)clientManager:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    clientManagerView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"clientManagerView"];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    //menu is only an example
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)searchButton:(id)sender {
    if (search.hidden == YES) {
        search.hidden = false;
        [UIView animateWithDuration:0.25 animations:^(void){
            logo.alpha = 0;
            scannerSub.alpha = 0;
            scannerCheck.alpha = 0;
            checkScannerButton.alpha = 0;
            search.alpha = 1;
            [searchButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        } completion:^(bool complete){
            if (complete) {
                [search becomeFirstResponder];
            }
        }];
        
    } else {
        [search resignFirstResponder];
        [UIView animateWithDuration:0.25 animations:^(void){
            logo.alpha = 1;
            scannerSub.alpha = 1;
            scannerCheck.alpha =1;
            checkScannerButton.alpha = 1;
            search.alpha = 0;
            [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        } completion:^(bool complete){
            if (complete) {
                search.hidden = true;
                [search setText:@"Search by Client or Code"];
            }
        }];
        nextJobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedNextJobs.count; a++) {
            [nextJobs addObject:savedNextJobs[a]];
        }
        completedJobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedCompletedJobs.count; a++) {
            [completedJobs addObject:savedCompletedJobs[a]];
        }
        [upcomingJobs reloadData];
        [recentJobs reloadData];
        [self setVisibility];
    }
}

- (IBAction)jobManager:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    unconfirmedJobsView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"unconfirmedJobsView"];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    //menu is only an example
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)handleDeleteButton:(id)sender {
    UIButton *button = (UIButton*)sender;
    [self deleteJobAtIndex:(int)button.tag];
}

-(void)deleteJobAtIndex:(int)indexInArray{
    jobObject *job = nextJobs[indexInArray];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm Cancellation of Job" message:@"This action is irreversible" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Cancel Job" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"would cancel");
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)getUpcomingJobs {
    FIRDatabaseReference *reference = [[[FIRDatabase database] reference] child:@"upcomingJobs"];
    [reference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [savedNextJobs removeAllObjects];
        savedNextJobs = [[NSMutableArray alloc] init];
        [nextJobs removeAllObjects];
        nextJobs = [[NSMutableArray alloc] init];
        NSDictionary *dictionary = snapshot.value;
        if (![[NSString stringWithFormat:@"%@",dictionary] isEqualToString:@"<null>"]) {
            for(id key in dictionary) {
                id value = [dictionary objectForKey:key];
                unconfirmedJobObject *job = [[unconfirmedJobObject alloc] initWithType:[value objectForKey:@"client"] andCode:[value objectForKey:@"code"] andDate:[value valueForKey:@"date"] andLocation:[[CLLocation alloc] initWithLatitude:[[value valueForKey:@"location-lat"] doubleValue] longitude:[[value valueForKey:@"location-lon"] doubleValue]] andDrives:[value objectForKey:@"drives"] andDateText:[value valueForKey:@"dateText"] andConfirmation:[value valueForKey:@"confirmed"] andEmail:[value objectForKey:@"email"] andClientName:[value valueForKey:@"clientName"]];
                [nextJobs addObject:job];
                [savedNextJobs addObject:job];
                [upcomingJobs reloadData];
                [self setVisibility];
            }
        }
        [self getPastJobs];
        [reference removeAllObservers];
    }];
}

-(void)getPastJobs{
    upcomingJobs.hidden = YES;
    recentJobs.hidden = YES;
    locallySaved = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *documentsURL = [NSURL fileURLWithPath:documentsDirectory];
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        [locallySaved addObject:file];
    }
    completedJobs = [[NSMutableArray alloc] init];
    FIRDatabaseReference *reference = [[FIRDatabase database] reference];
    [reference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dictionary = snapshot.value;
            [completedJobs removeAllObjects];
        if (![[NSString stringWithFormat:@"%@",dictionary] isEqualToString:@"<null>"]) {
            for(id key in dictionary) {
                NSDictionary *client = [dictionary objectForKey:key];
                if (![client objectForKey:@"client"] && ![(NSString*)key isEqualToString:@"upcomingJobs"]) {
                    for(id subKey in client) {
                        NSDictionary *jobD = [client objectForKey:subKey];
                        NSArray *driveSerials = [jobD objectForKey:@"driveSerials"];
                        NSArray *driveTimes = [jobD objectForKey:@"driveTimes"];
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[jobD objectForKey:@"date"] doubleValue]];
                        jobObject *job = [[jobObject alloc] initWithType:[jobD valueForKey:@"clientName"] andClientCode:[jobD valueForKey:@"clientCode"] andCode:[jobD valueForKey:@"code"] andURL:[jobD valueForKey:@"videoURL"] andDate:date andSerials:driveSerials andTimes:driveTimes andSignature:[jobD valueForKey:@"signatureURL"]];
                        [completedJobs addObject:job];
                    }
                    
                }
            }
            [recentJobs reloadData];
            [self setVisibility];
        }
        [reference removeAllObservers];
        [refreshingJobs dismissViewControllerAnimated:YES completion:nil];
    }];
    
}
@end
