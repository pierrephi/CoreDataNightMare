//
//  Event+Create.m
//  CoreDataNightMare
//
//  Created by Pierre-Philippe di Costanzo on 26/11/13.
//  Copyright (c) 2013 Pierre-Philippe di Costanzo. All rights reserved.
//

#import "Event+Create.h"

@implementation Event (Create)

+ (Event *) eventWithName: (NSString*)iName
               inFestival: (Festival*)iFestival
                inContext: (NSManagedObjectContext*) iContext {
    Event *evt = [NSEntityDescription insertNewObjectForEntityForName: @"Event"
                                               inManagedObjectContext: iContext];
    evt.name = iName;
    evt.festival = iFestival;
    evt.timeStamp = [NSDate date];
    return evt;
}
@end
