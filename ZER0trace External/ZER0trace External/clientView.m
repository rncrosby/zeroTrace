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
    clientName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"client"];
    [self getClientJobs];
    [super viewDidLoad];
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
    return 188;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    jobView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"jobView"];
    controller.job = jobs[indexPath.row];
    //menu is only an example
    [self presentViewController:controller animated:YES completion:nil];
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
    [References cornerRadius:cell.card radius:16.0f];
    jobObject *job = jobs[indexPath.row];
    cell.date.text = job.dateOfDestruction;
    cell.drives.text = [NSString stringWithFormat:@"  %lu Drives  ",(unsigned long)job.driveSerials.count];
    [cell.drives sizeToFit];
    cell.drives.frame = CGRectMake(cell.drives.frame.origin.x, 118, cell.drives.frame.size.width, 50);
    [References cornerRadius:cell.drives radius:16.0f];
    return cell;
}

-(void)getClientJobs {
    table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y+[References screenHeight], [References screenWidth], table.frame.size.height);
    jobs = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"clientCode = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"code"]]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    CKContainer *container = [CKContainer containerWithIdentifier:@"iCloud.com.fullytoasted.ZER0trace-Internal"];
    [container.publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       if (error) {
                                                           NSLog(@"%@",error.localizedDescription);
                                                       }
                                                       for (int a = 0; a < results.count; a++) {
                                                           CKRecord *record = results[0];
                                                           NSString *date = [record valueForKey:@"jobDate"];
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
                                                           jobObject *job = [[jobObject alloc] initWithType:videoURL andTimes:driveTimes andSerials:driveSerials andDate:date];
                                                           [jobs addObject:job];
                                                       }
                                                       dispatch_sync(dispatch_get_main_queue(), ^{
                                                           [table reloadData];
                                                           [UIView animateWithDuration:0.5f animations:^(void){
                                                               table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y-[References screenHeight], [References screenWidth], table.frame.size.height);
                                                           }];
                                                       });
                                                       
                                                   }];
}

@end
