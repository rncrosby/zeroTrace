//
//  accountObject.h
//  ZER0trace Internal
//
//  Created by Robert Crosby on 11/15/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface accountObject : NSObject

@property (nonatomic, strong) NSString* idName;
@property (nonatomic, strong) NSString* client;
@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* contactName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* phone;

-(instancetype)initWithType:(NSString*)idName andClient:(NSString*)client andCode:(NSString*)code andContactName:(NSString*)contactName andEmail:(NSString*)email andPhone:(NSString*)phone;

@end
