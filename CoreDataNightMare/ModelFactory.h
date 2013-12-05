//
//  ModelFactory.h
//  imiwa
//
//  Created by Pierre-Phi on 25/09/13.
//  Copyright (c) 2013 pierrephi.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynthesizeSingleton.h"

typedef void(^PerformBlock)(void);


@interface ModelFactory : NSObject

+ (ModelFactory *) sharedModelFactory;

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *writeManagedObjectContext;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;


- (NSManagedObjectContext *)newPrivateManagedObjectContext;

- (void)saveWriteContext;
- (void)saveMainContext;
- (void)saveContext:(NSManagedObjectContext *)context;
- (void)writeToDisk;
- (void)performBlock:(PerformBlock)block target:(id)target async:(BOOL)async;
@end
