//
//  Festival+Create.h
//  CoreDataNightMare
//
//  Created by Pierre-Philippe di Costanzo on 26/11/13.
//  Copyright (c) 2013 Pierre-Philippe di Costanzo. All rights reserved.
//

#import "Festival.h"

@interface Festival (Create)

+ (Festival *) festivalWithName: (NSString*)iName
                      inContext: (NSManagedObjectContext*) iContext ;
@end
