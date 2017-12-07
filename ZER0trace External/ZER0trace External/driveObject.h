//
//  driveObject.h
//  ZER0trace External
//
//  Created by Robert Crosby on 12/5/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface driveObject : NSObject <NSCopying>

@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSNumber *job;
@property (nonatomic, strong) NSString* serial;
@property (nonatomic, strong) driveObject* nextDrive;
@property (nonatomic, strong) driveObject* previousDrive;

-(instancetype)initWithType:(NSString*)serial andIndex:(NSNumber*)indexInJob andJob:(NSNumber*)job;
-(id) copyWithZone: (NSZone *) zone;
- (BOOL)isEqual:(id)other;

@end
