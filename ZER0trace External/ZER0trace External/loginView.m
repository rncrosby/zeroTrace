//
//  loginView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 11/13/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "loginView.h"

@interface loginView ()

@end

@implementation loginView

- (void)viewDidLoad {
    [References cornerRadius:card radius:16.0f];
    [References cornerRadius:signIn radius:16.0f];
    [References cardshadow:card];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    if (textField == username) {
        [password becomeFirstResponder];
    } else {
        NSLog(@"Username: %@",username.text);
        NSLog(@"Password: %@",password.text);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"username = '%@'",username.text]];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Accounts" predicate:predicate];
        CKContainer *container = [CKContainer containerWithIdentifier:@"iCloud.com.fullytoasted.ZER0trace-Internal"];
        [container.publicCloudDatabase performQuery:query
                                       inZoneWithID:nil
                                  completionHandler:^(NSArray *results, NSError *error) {
                                      if (!error) {
                                          dispatch_sync(dispatch_get_main_queue(), ^{
                                          CKRecord *record = results[0];
                                          if ([[record valueForKey:@"password"] isEqualToString:password.text]) {
                                              [[NSUserDefaults standardUserDefaults] setObject:[record valueForKey:@"client"] forKey:@"client"];
                                              [[NSUserDefaults standardUserDefaults] synchronize];

                                                  UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                                  clientView *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"clientView"];
                                                  [self presentViewController:controller animated:YES completion:nil];
                                          }
                                              });
                                          
                                      } else {
                                          [References toastMessage:error.localizedDescription andView:self andClose:NO];
                                      }
//
                                  }];
    }
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
