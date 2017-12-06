//
//  upcomingJobObject.m
//  ZER0trace External
//
//  Created by Robert Crosby on 12/3/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "upcomingJobObject.h"

@implementation upcomingJobObject

-(instancetype)initWithType:(NSString*)code forClient:(NSString*)client withLat:(NSNumber*)lat andLon:(NSNumber*)lon andDrives:(NSNumber*)drives on:(NSNumber*)date withText:(NSString*)dateText{
    self = [super init];
    if(self)
    {
        self.code = code;
        self.client = client;
        self.lat = lat;
        self.lon = lon;
        self.drives = drives;
        self.date = date;
        self.dateText = dateText;
    }
    return self;
}

@end
