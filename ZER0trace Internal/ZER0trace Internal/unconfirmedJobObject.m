//
//  unconfirmedJobObject.m
//  ZER0trace Internal
//
//  Created by Robert Crosby on 12/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "unconfirmedJobObject.h"

@implementation unconfirmedJobObject

-(instancetype)initWithType:(NSString*)client andCode:(NSString*)code andDate:(NSNumber*)date andLocation:(CLLocation*)location andDrives:(NSNumber*)drives andDateText:(NSString*)dateText andConfirmation:(NSNumber *)isConfirmed andEmail:(NSString*)email andClientName:(NSString*)clientName{
    self = [super init];
    if(self)
    {
        self.client = client;
        self.code = code;
        self.date = date;
        self.location = location;
        self.drives = drives;
        self.dateText = dateText;
        self.isConfirmed = isConfirmed;
        self.email = email;
        self.clientName = clientName;
    }
    return self;
}

-(void)printObject {
    NSLog(@"Confirmed: %@\nClient-%@: %@\nCode: %@\nLocation: %@\nDate: %@",self.isConfirmed,self.client,self.clientName, self.code,self.location,self.date);
}

@end
