//
//  driveObject.m
//  ZER0trace External
//
//  Created by Robert Crosby on 12/5/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "driveObject.h"
#import <objc/runtime.h>

@implementation driveObject

-(instancetype)initWithType:(NSString*)serial andIndex:(NSNumber*)indexInJob andJob:(NSNumber*)job{
    self = [super init];
    if(self)
    {
        self.serial = serial;
        self.index = indexInJob;
        self.job = job;
    }
    return self;
}

-(id) copyWithZone: (NSZone *) zone {
    driveObject *driveCopy = [[driveObject allocWithZone: zone] init];
    driveCopy.serial = _serial;
    driveCopy.index = _index;
    driveCopy.job = _job;
    return driveCopy;
}

- (BOOL)isEqual:(id)other {
    NSString *drive = (NSString*)other;
    if ([self.serial isEqualToString:drive]) {
        return YES;
    } else {
        return NO;
    }
}

@end
