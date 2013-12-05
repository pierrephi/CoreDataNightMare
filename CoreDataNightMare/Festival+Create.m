//
//  Festival+Create.m
//  CoreDataNightMare
//
//  Created by Pierre-Philippe di Costanzo on 26/11/13.
//  Copyright (c) 2013 Pierre-Philippe di Costanzo. All rights reserved.
//

#import "Festival+Create.h"

@implementation Festival (Create)

+ (Festival *) festivalWithName: (NSString*)iName
                      inContext: (NSManagedObjectContext*) iContext {
    
    Festival *festiv = [NSEntityDescription insertNewObjectForEntityForName: @"Festival"
                                                     inManagedObjectContext: iContext];
    festiv.name = iName;
    return festiv;
}

@end
