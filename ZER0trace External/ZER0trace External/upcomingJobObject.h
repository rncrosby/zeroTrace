//
//  upcomingJobObject.h
//  ZER0trace External
//
//  Created by Robert Crosby on 12/3/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface upcomingJobObject : NSObject

@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber* lon;
@property (nonatomic, strong) NSNumber* drives;
@property (nonatomic, strong) NSNumber* date;
@property (nonatomic, strong) NSString* dateText;
@property (nonatomic, strong) NSString *client;

-(instancetype)initWithType:(NSString*)code forClient:(NSString*)client withLat:(NSNumber*)lat andLon:(NSNumber*)lon andDrives:(NSNumber*)drives on:(NSNumber*)date withText:(NSString*)dateText;

@end
