//
//  jobObject.m
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "jobObject.h"

@implementation jobObject

-(instancetype)initWithType:(NSURL*)videoURL andTimes:(NSArray*)driveTimes andSerials:(NSArray*)driveSerials andDate:(NSDate*)date{
    self = [super init];
    if(self)
    {
        self.videoURL = videoURL;
        self.driveTimes = driveTimes;
        self.driveSerials = driveSerials;
        self.dateOfDestruction = date;
    }
    return self;
}

@end
