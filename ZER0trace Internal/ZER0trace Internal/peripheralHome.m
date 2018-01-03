//
//  peripheralHome.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 1/2/18.
//  Copyright © 2018 fully toasted. All rights reserved.
//

#import "peripheralHome.h"

@interface peripheralHome ()

@end

@implementation peripheralHome

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Camera" bundle: nil];
    peripheralCamera *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"peripheralCamera"];
    //menu is only an example
    [self presentViewController:controller animated:YES completion:nil];
}

-(BOOL) prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
