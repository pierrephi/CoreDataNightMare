//
//  Event+Create.h
//  CoreDataNightMare
//
//  Created by Pierre-Philippe di Costanzo on 26/11/13.
//  Copyright (c) 2013 Pierre-Philippe di Costanzo. All rights reserved.
//

#import "Event.h"

@interface Event (Create)
+ (Event *) eventWithName: (NSString*)iName
               inFestival: (Festival*)iFestival
                inContext: (NSManagedObjectContext*) iContext ;
@end
