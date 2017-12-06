//
//  newJobView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 12/3/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "newJobView.h"

@interface newJobView ()

@end

@implementation newJobView

-(BOOL)prefersStatusBarHidden {
    return hideStatusBar;
}

-(void)viewWillAppear:(BOOL)animated {
    ref = [[FIRDatabase database] reference];
}
- (void)viewDidLoad {
    driveCount = 500;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [References cornerRadius:mapView radius:12.0f];
    collectionView.backgroundColor = [UIColor clearColor];
    [super viewDidLoad];
    NSDate *today = [NSDate date];
    dateArray = [[NSMutableArray alloc] init];
    int dateCount = 0;
    int dateIterator = 0;
    while (dateCount < 28) {
        NSDate *nextDate = [today dateByAddingTimeInterval:86400*dateIterator];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEEE"];
        NSString *dateString = [dateFormat stringFromDate:nextDate];
        if (([dateString isEqualToString:@"Sunday"]) || ([dateString isEqualToString:@"Saturday"])) {
            dateIterator++;
        } else {
            [dateArray addObject:nextDate];
            dateCount++;
            dateIterator++;
        }
    }
    [collectionView reloadData];
    // Do any additional setup after loading the view.
}










- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 28;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dateCell" forIndexPath:indexPath];
    UILabel *card = (UILabel*)[cell viewWithTag:1];
    UILabel *month = (UILabel*)[cell viewWithTag:2];
    UILabel *date = (UILabel*)[cell viewWithTag:3];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:month.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = month.bounds;
    maskLayer.path  = maskPath.CGPath;
    month.layer.mask = maskLayer;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d"];
    NSString *dateString = [dateFormat stringFromDate:dateArray[indexPath.row]];
    date.text = dateString;
    [dateFormat setDateFormat:@"MMM"];
    dateString = [dateFormat stringFromDate:dateArray[indexPath.row]];
    month.text = [dateString uppercaseString];
    [References cornerRadius:card radius:10.0f];
    [References lightCardShadow:card];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedDate = dateArray[indexPath.row];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE, MMMM"];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterOrdinalStyle;
    NSString *dateTextTemp = [dateFormat stringFromDate:selectedDate];
    [dateFormat setDateFormat:@"d"];
    NSString *numberFormatted = [numberFormatter stringFromNumber:@([[dateFormat stringFromDate:selectedDate] intValue])];
    dateText.text = [NSString stringWithFormat:@"%@ %@",dateTextTemp,numberFormatted];
    finalDateText = dateText.text;
    if (disclaimr.frame.origin.y <= 526) {
        [UIView animateWithDuration:0.1 animations:^(void){
            disclaimr.frame = CGRectMake(disclaimr.frame.origin.x, disclaimr.frame.origin.y+dateText.frame.size.height, disclaimr.frame.size.width, disclaimr.frame.size.height);
            dateText.alpha = 1;
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (oldLocation != newLocation) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = newLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.2;
        mapRegion.span.longitudeDelta = 0.2;
        [mapView setRegion:mapRegion animated: YES];
        mapView.showsUserLocation = YES;
        [self convertLocation:newLocation orAddress:nil];
        [locationManager stopUpdatingLocation];
    }
}

-(void)convertLocation:(CLLocation*)location orAddress:(NSString*)address {
    if (location != nil) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       if(!error){
                           CLPlacemark *placeMark = placemarks[0];
                           placeMarkSelected = placeMark;
                           NSLog(@"%@",placeMark);
                           [addressField setPlaceholder:[NSString stringWithFormat:@"%@ %@",placeMark.subThoroughfare,placeMark.thoroughfare]];
                           jobLocation = location;
                       }
              else{
                  NSLog(@"There was a reverse geocoding error\n%@", [error localizedDescription]);
                }
          }
         ];
    } else {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray* placemarks, NSError* error){
            CLPlacemark *placemark = placemarks[0];
            placeMarkSelected = placemark;
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:placemark.location.coordinate];
            [annotation setTitle:placemark.thoroughfare]; //You can set the subtitle too
            id userAnnotation=mapView.userLocation;
            //Remove all added annotations
            [mapView removeAnnotations:mapView.annotations];
            // Add the current user location annotation again.
            if(userAnnotation!=nil) {
            [mapView addAnnotation:userAnnotation];
            }
            [mapView addAnnotation:annotation];
            [addressField setText:placemark.thoroughfare];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            MKCoordinateRegion mapRegion;
            mapRegion.center = location.coordinate;
            mapRegion.span.latitudeDelta = 0.2;
            mapRegion.span.longitudeDelta = 0.2;
            [mapView setRegion:mapRegion animated: YES];
            jobLocation = location;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1) {
        if (textField.text.length > 0) {
            [self convertLocation:nil orAddress:textField.text];
        }
    }
    [textField resignFirstResponder];
    return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)driveSliderChange:(id)sender {
    UISlider *slider = (UISlider*)sender;
    driveCount = 2000*slider.value;
    driveCount = 50.0 * floor((driveCount/50.0)+0.5);
    if (driveCount == 2000) {
        [driveCountField setText:[NSString stringWithFormat:@"%i+",driveCount]];
    } else {
        [driveCountField setText:[NSString stringWithFormat:@"%i",driveCount]];
    }
}

- (IBAction)scheduleJob:(id)sender {
    if (selectedDate != nil) {
        if (driveCount > 0) {
            if (jobLocation != nil) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Is This information Correct?" message:[NSString stringWithFormat:@"\n%@ %@\n%@, %@\n\n%@\n\n%i Drives\n",placeMarkSelected.subThoroughfare,placeMarkSelected.thoroughfare,placeMarkSelected.locality,placeMarkSelected.administrativeArea,finalDateText,driveCount] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Confirm Destruction" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    // Ok action example
                    [[[ref child:@"upcomingJobs"] child:[References randomIntWithLength:5]] setValue:@{
                                                                                                       @"client": [[NSUserDefaults standardUserDefaults] objectForKey:@"client"],
                                                                                                       @"date": [NSNumber numberWithDouble:[selectedDate timeIntervalSince1970]],
                                                                                                       @"dateText" : finalDateText,
                                                                                                       @"location-lat": [NSNumber numberWithFloat:jobLocation.coordinate.latitude],
                                                                                                       @"location-lon": [NSNumber numberWithFloat:jobLocation.coordinate.longitude],
                                                                                                       @"drives": [NSNumber numberWithInteger:driveCount],
                                                                                                       }];
                    [References fullScreenToast:@"Success!" inView:self withSuccess:YES andClose:YES];
                }];
                UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                    // Other action
                }];
                [alert addAction:okAction];
                [alert addAction:otherAction];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
               [References toastMessage:@"Please type the location of the pickup" andView:self andClose:NO];
            }
        } else {
            [References toastMessage:@"Please estimate how many drives will be destroyed" andView:self andClose:NO];
        }
    } else {
        [References toastMessage:@"Please choose a date" andView:self andClose:NO];
    }
}
@end
