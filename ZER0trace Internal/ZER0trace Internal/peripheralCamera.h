//
//  peripheralCamera.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 12/20/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseDatabase/FIRDatabaseReference.h>
#import <LLSimpleCamera/LLSimpleCamera.h>
#import "References.h"

@interface peripheralCamera : UIViewController {
    FIRDatabaseReference *reference,*camRef;
    NSString *clientCode,*jobCode;
    UIView *cameraView;
    bool cameraReady,connected,recording,uploading;
    NSString *thisCameraStatus;
    NSURL *uploadURL;
    int thisCamera;
    NSDictionary *fixedInfo;
    int clipCount;
    LLSimpleCamera *recorder;
    __weak IBOutlet UILabel *cameraNumber;
    __weak IBOutlet UILabel *cameraStatus;
    __weak IBOutlet UILabel *clipCountLabel;
    __weak IBOutlet UIButton *connect;
    __weak IBOutlet UILabel *connectNote;
}
- (IBAction)connect:(id)sender;

@end
