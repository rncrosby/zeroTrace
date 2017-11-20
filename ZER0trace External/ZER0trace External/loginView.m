//
//  loginView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 11/13/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#define animationSpeed 0.5f

#import "loginView.h"

@interface loginView ()

@end

@implementation loginView

- (void)viewDidLoad {
    currentCard = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    signIn.alpha = 0;
    jobCode.alpha = 0;
    signUp.alpha = 0;
    [References cornerRadius:card radius:16.0f];
    [References cardshadow:card];
    cardOrigin = scroll.bounds;
    scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self prepareScene];
}

-(void)prepareScene {
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.0f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            signUp.alpha = 1;
            signIn.alpha = 1;
            jobCode.alpha = 1;
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    if (currentCard == 0) {
        if (textField == username) {
            [password becomeFirstResponder];
        } else {
            NSLog(@"Username: %@",username.text);
            NSLog(@"Password: %@",password.text);
            [textField resignFirstResponder];
        }
    }
    if (currentCard == 1) {
        [textField resignFirstResponder];
    }
    if (currentCard == 2) {
        if (textField == username) {
            [password becomeFirstResponder];
        }
        if (textField == password) {
            [contactName becomeFirstResponder];
            [UIView animateWithDuration:0.5f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-55, scroll.frame.size.width, scroll.frame.size.height);
            }];
        }
        if (textField == contactName) {
            [contactPhone becomeFirstResponder];
            [UIView animateWithDuration:0.5f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-55, scroll.frame.size.width, scroll.frame.size.height);
            }];
        }
        if (textField == contactPhone) {
            [textField resignFirstResponder];
            [UIView animateWithDuration:0.5f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y+110, scroll.frame.size.width, scroll.frame.size.height);
            }];
        }
    }
    
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (IBAction)goToSignIn:(id)sender {
    if (currentCard == 0) {
        [UIView animateWithDuration:0.15f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+50, [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            [UIView animateWithDuration:0.15f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-50, [References screenWidth], [References screenHeight]);
            }];
        }];
    } else {
        currentCard = 0;
        [UIView animateWithDuration:animationSpeed animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            usernameHeader.hidden = NO;
            username.hidden = NO;
            password.hidden = NO;
            passwordHeader.hidden = NO;
            contactName.hidden = YES;
            contactNameHeader.hidden = YES;
            contactPhone.hidden = YES;
            contactPhoneHeader.hidden = YES;
            [UIView animateWithDuration:animationSpeed animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            }];
        }];
    }
}

- (IBAction)goToJobCode:(id)sender {
    if (currentCard == 1) {
        [UIView animateWithDuration:0.15f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+50, [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            [UIView animateWithDuration:0.15f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-50, [References screenWidth], [References screenHeight]);
            }];
        }];
    } else {
        currentCard = 1;
        [UIView animateWithDuration:animationSpeed animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            usernameHeader.text = @"JOB CODE";
            username.placeholder = @"00000";
            usernameHeader.hidden = NO;
            username.hidden = NO;
            password.hidden = YES;
            passwordHeader.hidden = YES;
            contactName.hidden = YES;
            contactNameHeader.hidden = YES;
            contactPhone.hidden = YES;
            contactPhoneHeader.hidden = YES;
            [UIView animateWithDuration:animationSpeed animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            }];
        }];
    }
}

- (IBAction)goToSignUp:(id)sender {
    if (currentCard == 2) {
        [UIView animateWithDuration:0.15f animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+50, [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            [UIView animateWithDuration:0.15f animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-50, [References screenWidth], [References screenHeight]);
            }];
        }];
    } else {
        currentCard = 2;
        [UIView animateWithDuration:animationSpeed animations:^(void){
            scroll.frame = CGRectMake(0, scroll.frame.origin.y+[References screenHeight], [References screenWidth], [References screenHeight]);
        } completion:^(bool complete){
            username.text = @"";
            password.text = @"";
            usernameHeader.text = @"ACCOUNT EMAIL ADDRESS";
            username.placeholder = @"email@company.com";
            usernameHeader.hidden = NO;
            username.hidden = NO;
            password.hidden = NO;
            passwordHeader.hidden = NO;
            contactName.hidden = NO;
            contactNameHeader.hidden = NO;
            contactPhone.hidden = NO;
            contactPhoneHeader.hidden = NO;
            [UIView animateWithDuration:animationSpeed animations:^(void){
                scroll.frame = CGRectMake(0, scroll.frame.origin.y-[References screenHeight], [References screenWidth], [References screenHeight]);
            }];
        }];
    }
}
@end
