//
//  Festival.h
//  CoreDataNightMare
//
//  Created by Pierre-Philippe di Costanzo on 03/12/13.
//  Copyright (c) 2013 Pierre-Philippe di Costanzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Festival : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *events;

@end

@interface Festival (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
