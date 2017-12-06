//
//  newJobView.h
//  ZER0trace External
//
//  Created by Robert Crosby on 12/3/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FirebaseDatabase/FIRDatabaseReference.h>
#import "References.h"

@interface newJobView : UIViewController <UITextFieldDelegate,CLLocationManagerDelegate,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {
    FIRDatabaseReference *ref;
    CLPlacemark *placeMarkSelected;
    CLLocation *jobLocation;
    bool hideStatusBar;
    NSDate *selectedDate;
    NSMutableArray *dateArray;
    CLLocationManager *locationManager;
    __weak IBOutlet MKMapView *mapView;
    __weak IBOutlet UITextField *addressField;
    __weak IBOutlet UITextField *driveCountField;
    __weak IBOutlet UISlider *driveCountSlider;
    int driveCount;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UILabel *disclaimr;
    NSString *finalDateText;
    __weak IBOutlet UILabel *dateText;
}
- (IBAction)driveSliderChange:(id)sender;
- (IBAction)scheduleJob:(id)sender;

@end
