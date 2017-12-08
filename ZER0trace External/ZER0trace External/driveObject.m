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
        hashValue = [serial hash];
        self.serial = serial;
        self.index = indexInJob;
        self.job = job;
    }
    return self;
}

-(BOOL)compareHash:(NSInteger)otherHash {
    if (hashValue == otherHash) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(void)printHash {
    NSLog(@"%lu",hashValue);
}

@end
