//
//  unconfirmedJobObject.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 12/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface unconfirmedJobObject : NSObject

@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* client;
@property (nonatomic, strong) NSString* clientName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSNumber* date;
@property (nonatomic, strong) NSDate* dateObject;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSNumber *drives;
@property (nonatomic, strong) NSString *dateText;
@property (nonatomic, strong) NSNumber *isConfirmed;

-(instancetype)initWithType:(NSString*)client andCode:(NSString*)code andDate:(NSNumber*)date andLocation:(CLLocation*)location andDrives:(NSNumber*)drives andDateText:(NSString*)dateText andConfirmation:(NSNumber*)isConfirmed andEmail:(NSString*)email andClientName:(NSString*)clientName;
-(void)printObject;

@end
