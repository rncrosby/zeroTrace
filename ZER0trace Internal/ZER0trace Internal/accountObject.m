//
//  accountObject.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 11/15/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "accountObject.h"

@implementation accountObject

-(instancetype)initWithType:(NSString*)idName andClient:(NSString*)client andCode:(NSString*)code andContactName:(NSString*)contactName andEmail:(NSString*)email andPhone:(NSString*)phone {
    self = [super init];
    if(self)
    {
        self.client = client;
        self.idName = idName;
        self.code = code;
        self.contactName = contactName;
        self.email = email;
        self.phone = phone;
        
    }
    return self;
}

@end
