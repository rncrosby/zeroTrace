//
//  clientView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "clientView.h"

@interface clientView ()

@end

@implementation clientView

- (void)viewDidLoad {
    isSearching = false;
    clientName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"client"];
   line = [[UIView alloc] initWithFrame:CGRectMake(0, clientName.frame.origin.y+clientName.frame.size.height+8, 1000, 1)];
    [line setBackgroundColor:[UIColor whiteColor]];
    line.alpha = 0.2f;
    [self.view addSubview:line];
    [self.view bringSubviewToFront:line];
    [self getClientJobs];
    [super viewDidLoad];
    [searchBar addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return jobs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    jobView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"jobView"];
//    controller.job = jobs[indexPath.row];
//    //menu is only an example
//    [self presentViewController:controller animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"clientCell";
    
    clientCell *cell = (clientCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"clientCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    jobObject *job = jobs[indexPath.row];
    [References cornerRadius:cell.card radius:16.0f];
    cell.card.layer.cornerRadius = cell.card.layer.cornerRadius;
    cell.date.text = job.dateOfDestruction;
    if (isSearching == true) {
            jobObject *job = jobs[indexPath.row];
            for (int b = 0; b < job.driveSerials.count; b++) {
                if ([job.driveSerials[b] localizedCaseInsensitiveContainsString:searchBar.text]) {
                    cell.drives.text = [NSString stringWithFormat:@"Found %@",job.driveSerials[b]];
                    break;
                }
            }
    } else {
        cell.drives.text = [NSString stringWithFormat:@"%lu Drives",(unsigned long)job.driveSerials.count];
    }
    [cell.barCode setImage:[UIImage imageWithCIImage:[self generateBarcode:job.jobCode]]];
    [References cardshadow:cell.shadow];
    cell.layer.zPosition = indexPath.row;
    return cell;
}

-(CIImage*)generateBarcode:(NSString*)dataString{
    
    CIFilter *barCodeFilter = [CIFilter filterWithName:@"CIAztecCodeGenerator"];
    NSData *barCodeData = [dataString dataUsingEncoding:NSASCIIStringEncoding];
    [barCodeFilter setValue:barCodeData forKey:@"inputMessage"];
//    [barCodeFilter setValue:[NSNumber numberWithInt:56] forKey:@"inputMinHeight"];
//    [barCodeFilter setValue:[NSNumber numberWithInt:1] forKey:@"inputDataColumns"];
//    [barCodeFilter setValue:[NSNumber numberWithInt:15] forKey:@"inputRows"];
CIImage *barCodeImage = barCodeFilter.outputImage;
    
    return barCodeImage;
}

-(void)getClientJobs {
    table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y+[References screenHeight], [References screenWidth], table.frame.size.height);
    jobs = [[NSMutableArray alloc] init];
    savedJobs = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"clientCode = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"code"]]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    query.sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc]initWithKey:@"modificationDate" ascending:false]];
    CKContainer *container = [CKContainer containerWithIdentifier:@"iCloud.com.fullytoasted.ZER0trace-Internal"];
    [container.publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (error) {
                                                           NSLog(@"%@",error.localizedDescription);
                                                       }
                                                       for (int a = 0; a < results.count; a++) {
                                                           CKRecord *record = results[a];
                                                           NSString *date = [record valueForKey:@"jobDate"];
                                                           NSString *code = [record valueForKey:@"code"];

                                                           for (int a = 0; a < date.length; a++) {
                                                               if ([date characterAtIndex:a] == ' ') {
                                                                   
                                                                   NSMutableString *mu = [NSMutableString stringWithString:date];
                                                                   [mu deleteCharactersInRange:NSMakeRange(a, 1)];
                                                                   [mu insertString:@"\n" atIndex:a];
                                                                   date = mu;
                                                                   break;
                                                               }
                                                           }
                                                           NSArray *driveTimes = [record objectForKey:@"driveTimes"];
                                                           NSArray *driveSerials = [record objectForKey:@"driveSerials"];
                                                           NSURL *videoURL = [NSURL URLWithString:[record valueForKey:@"videoURL"]];
                                                           jobObject *job = [[jobObject alloc] initWithType:videoURL andTimes:driveTimes andSerials:driveSerials andDate:date andCode:code];
                                                           [jobs addObject:job];
                                                           [savedJobs addObject:job];
                                                       } dispatch_sync(dispatch_get_main_queue(), ^{
                                                           [table reloadData];
                                                           [UIView animateWithDuration:0.5f animations:^(void){
                                                               table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y-[References screenHeight], [References screenWidth], table.frame.size.height);
                                                           }];
                                                       });
                                                       
                                                   }];
}

- (IBAction)searchButton:(id)sender {
    if (isSearching == false) {
        searchBar.hidden = false;
        [UIView animateWithDuration:0.25f animations:^(void){
            line.frame = CGRectMake(0, line.frame.origin.y+searchBar.frame.size.height+20, line.frame.size.width, line.frame.size.height);
            table.frame = CGRectMake(0, table.frame.origin.y+searchBar.frame.size.height+20, table.frame.size.width, table.frame.size.height-searchBar.frame.size.height-20);
            [searchButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        } completion:^(bool complete){
            if (complete) {
                [searchBar becomeFirstResponder];
                isSearching = true;
            }
        }];
    } else {
        jobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedJobs.count; a++) {
            [jobs addObject:savedJobs[a]];
        }
        [table reloadData];
        [searchBar resignFirstResponder];
        [UIView animateWithDuration:0.25f animations:^(void){
            line.frame = CGRectMake(0, line.frame.origin.y-searchBar.frame.size.height-20, line.frame.size.width, line.frame.size.height);
            table.frame = CGRectMake(0, table.frame.origin.y-searchBar.frame.size.height-20, table.frame.size.width, table.frame.size.height+searchBar.frame.size.height+20);
            [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        } completion:^(bool complete){
            if (complete) {
                searchBar.hidden = true;
                isSearching = false;
            }
        }];
    }
    
}

-(void)textChanged:(UITextField *)textField {
    if (textField.text.length == 0) {
        jobs = [[NSMutableArray alloc] init];
        for (int a = 0; a < savedJobs.count; a++) {
            [jobs addObject:savedJobs[a]];
        }
        [table reloadData];
        return ;
    }
    [jobs removeAllObjects];
    jobs = [[NSMutableArray alloc] init];
    for (int a = 0; a < savedJobs.count; a++) {
        jobObject *job = savedJobs[a];
        for (int b = 0; b < job.driveSerials.count; b++) {
            if ([job.driveSerials[b] localizedCaseInsensitiveContainsString:textField.text]) {
                [jobs addObject:job];
                break;
            }
        }
    }
    [table reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}
@end
