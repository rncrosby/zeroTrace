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
    [References cornerRadius:image radius:image.frame.size.width/2];
    [super viewDidLoad];
    [self getClientJobs];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return jobs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 289;
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
    [References lightCardShadow:cell.shadow];
    [References cornerRadius:cell.card radius:9.0f];
    jobObject *job = jobs[indexPath.row];
    cell.date.text = @"Wednesday,\nOctober 7th";
    cell.drives.text = [NSString stringWithFormat:@"%lu\nDrives",(unsigned long)job.driveSerials.count];
    return cell;
}

-(void)getClientJobs {
    jobs = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"client = 'oracle'"]];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Job" predicate:predicate];
    CKContainer *container = [CKContainer containerWithIdentifier:@"iCloud.com.fullytoasted.ZER0trace-Internal"];
    [container.publicCloudDatabase performQuery:query
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       for (int a = 0; a < results.count; a++) {
                                                           CKRecord *record = results[0];
                                                           NSArray *driveTimes = [record objectForKey:@"driveTimes"];
                                                           NSArray *driveSerials = [record objectForKey:@"driveSerials"];
                                                           NSURL *videoURL = [NSURL URLWithString:[record valueForKey:@"videoURL"]];
                                                           jobObject *job = [[jobObject alloc] initWithType:videoURL andTimes:driveTimes andSerials:driveSerials andDate:[NSDate date]];
                                                           [jobs addObject:job];
                                                       }
                                                       dispatch_sync(dispatch_get_main_queue(), ^{
                                                           [table reloadData];
                                                       });
                                                       
                                                   }];
}

@end
