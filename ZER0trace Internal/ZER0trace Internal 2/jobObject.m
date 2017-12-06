//
//  jobObject.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/16/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "jobObject.h"

@implementation jobObject

-(instancetype)initWithType:(NSString*)client andClientCode:(NSString*)clientCode andCode:(NSString*)code andURL:(NSString*)videoURL andDate:(NSDate*)date andSerials:(NSArray*)serials andTimes:(NSArray*)times andSignature:(NSData*)signature{
    self = [super init];
    if(self)
    {
        self.clientCode = clientCode;
        self.client = client;
        self.code = code;
        self.videoURL = videoURL;
        self.dateCompleted = date;
        self.driveSerials = serials;
        self.driveTimes = times;
        self.signature = signature;
        
    }
    return self;
}

@end
