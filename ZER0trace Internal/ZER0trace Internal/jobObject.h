//
//  jobObject.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 10/16/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface jobObject : NSObject
@property (nonatomic, strong) NSString* client;
@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSDate *dateCompleted;
@property (nonatomic, strong) NSString* videoURL;
@property (nonatomic, strong) NSArray* driveSerials;
@property (nonatomic, strong) NSArray* driveTimes;

-(instancetype)initWithType:(NSString*)client andCode:(NSString*)code andURL:(NSString*)videoURL andDate:(NSDate*)date andSerials:(NSArray*)serials andTimes:(NSArray*)times;

@end
