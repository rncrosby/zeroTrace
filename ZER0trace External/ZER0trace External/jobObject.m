//
//  jobObject.m
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "jobObject.h"

@implementation jobObject

-(instancetype)initWithType:(NSURL*)videoURL andTimes:(NSArray*)driveTimes andSerials:(NSArray*)driveSerials andDate:(NSString*)date andCode:(NSString*)jobCode andLocation:(CLLocation*)location andDateObject:(NSDate*)dateObject {
    self = [super init];
    if(self)
    {
        self.location = location;
        self.videoURL = videoURL;
        self.driveTimes = driveTimes;
        self.driveSerials = driveSerials;
        self.dateOfDestruction = date;
        self.jobCode = jobCode;
        self.dateObject = dateObject;
    }
    return self;
}

@end
