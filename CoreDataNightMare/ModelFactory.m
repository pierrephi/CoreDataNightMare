//
//  ModelFactory.m
//  imiwa
//
//  Created by Pierre-Phi on 25/09/13.
//  Copyright (c) 2013 pierrephi.net. All rights reserved.
//

#import "ModelFactory.h"
#import "ModelDelegate.h"

@interface ModelFactory ()

@property (nonatomic, retain) ModelDelegate *modelDelegate;

@end

@implementation ModelFactory
@synthesize managedObjectModel = _managedObjectModel;
@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize writeManagedObjectContext = _writeManagedObjectContext;


SYNTHESIZE_SINGLETON_FOR_CLASS(ModelFactory);


- (id)init {
    self = [super init];
    if (self) {
        self.modelDelegate = [ModelDelegate sharedModelDelegate];
    }

    return self;
}



#pragma mark -
#pragma mark - Core Data Methods

- (void)writeToDisk {

    NSManagedObjectContext *writeManagedObjectContext = self.writeManagedObjectContext;
    NSManagedObjectContext *mainManagedObjectContext = self.mainManagedObjectContext;

    [mainManagedObjectContext performBlock:^{
        NSError *error = nil;
        if ([mainManagedObjectContext hasChanges] && ![mainManagedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }

        [writeManagedObjectContext performBlock:^{
            NSError *error = nil;
            if ([writeManagedObjectContext hasChanges] && ![writeManagedObjectContext save:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }];

    }];

}

- (void)performBlock: (PerformBlock) block
              target: (id) target
               async: (BOOL) async {

    if (async) {
        [target performBlock: block];
    } else {
        [target performBlockAndWait:block];
    }

}


- (void)saveWriteContext
{
    NSManagedObjectContext *managedObjectContext = self.writeManagedObjectContext;
    [self saveContext: managedObjectContext];
}


- (void)saveMainContext
{
    NSManagedObjectContext *managedObjectContext = self.mainManagedObjectContext;
    [self saveContext: managedObjectContext];
}

- (void)saveContext:(NSManagedObjectContext *)context
{

    [context performBlockAndWait:^{
        NSError *error = nil;
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

    }];
}

#pragma mark - Core Data stack
- (NSManagedObjectContext *)newPrivateManagedObjectContext {


    NSManagedObjectContext *privateManagedObjectContext;


    privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [privateManagedObjectContext setParentContext: self.mainManagedObjectContext];
    [privateManagedObjectContext setUndoManager: nil];
    return privateManagedObjectContext;

}

- (NSManagedObjectContext *)writeManagedObjectContext {

    @synchronized(self) {

        if (_writeManagedObjectContext != nil)
        {
            return _writeManagedObjectContext;
        }

        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

        if (coordinator != nil)
        {
            if ([[NSFileManager defaultManager] respondsToSelector:@selector(URLForUbiquityContainerIdentifier:)]) {
                // Initialise managed object context for  iOS 5 and up
                _writeManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

                [_writeManagedObjectContext performBlockAndWait:^{
                    [_writeManagedObjectContext setPersistentStoreCoordinator: self.persistentStoreCoordinator];
                }];
                [_writeManagedObjectContext setUndoManager: nil];

            } else {
                // Or simply initialise context
                _writeManagedObjectContext = [[NSManagedObjectContext alloc]  initWithConcurrencyType: NSPrivateQueueConcurrencyType];
                [_writeManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
                [_writeManagedObjectContext setUndoManager: nil];
            }
        }
        return _writeManagedObjectContext;
    } //  Synchronised
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)mainManagedObjectContext
{
    @synchronized(self) {
        if (_mainManagedObjectContext != nil)
        {
            return _mainManagedObjectContext;
        }

        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainManagedObjectContext setParentContext: self.writeManagedObjectContext];

        return _mainManagedObjectContext;
    }
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */

- (NSManagedObjectModel *) managedObjectModel {

    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized(self) {

        if (_persistentStoreCoordinator != nil)
        {
            return _persistentStoreCoordinator ;
        }

        // Persistant store coordinator
        _persistentStoreCoordinator  = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *storeURL = [NSURL fileURLWithPath: [path stringByAppendingPathComponent:@"festivals.db"]];
        NSLog(@"%@",[path stringByAppendingPathComponent:@"festivals.db"]);

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            // Migrate datamodel
            NSDictionary *options = nil;

                // iCloud is not available
                options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES),
                            NSInferMappingModelAutomaticallyOption: @(YES)};

            NSError __autoreleasing *error = nil;
            [self.persistentStoreCoordinator  lock];
            if (![self.persistentStoreCoordinator  addPersistentStoreWithType:NSSQLiteStoreType
                                                                configuration:nil
                                                                          URL:storeURL
                                                                      options:options
                                                                        error:&error
                  ]
                )
            {
                NSLog(@"Unable to add persistant store coordinator %@, %@", error, [error userInfo]);
            }
            [self.persistentStoreCoordinator  unlock];            
        });
        return self.persistentStoreCoordinator ;
    }
}

@end