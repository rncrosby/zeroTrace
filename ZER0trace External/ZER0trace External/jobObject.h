//
//  jobObject.h
//  ZER0trace External
//
//  Created by Robert Crosby on 10/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface jobObject : NSObject

@property (nonatomic, strong) NSURL* videoURL;
@property (nonatomic, strong) NSString *dateOfDestruction;
@property (nonatomic, strong) NSArray* driveTimes;
@property (nonatomic, strong) NSArray* driveSerials;

-(instancetype)initWithType:(NSURL*)videoURL andTimes:(NSArray*)driveTimes andSerials:(NSArray*)driveSerials andDate:(NSString*)date;


@end
