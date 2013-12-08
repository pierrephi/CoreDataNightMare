//
//  CDNAppDelegate.m
//  CoreDataNightMare
//
//  Created by Pierre-Philippe di Costanzo on 26/11/13.
//  Copyright (c) 2013 Pierre-Philippe di Costanzo. All rights reserved.
//

#import "CDNAppDelegate.h"

#import "CDNMasterViewController.h"
#import "CDNDetailViewController.h"
#import "ModelFactory.h"
#import "Festival.h"
#import "Festival+Create.h"
#import "Event.h"
#import "Event+Create.h"

@implementation CDNAppDelegate


- (void) fetchEventsForFestival: (Festival*)iFestival
                      inContext: (NSManagedObjectContext *)iContext{
    
    NSFetchRequest *fetchFestivalEvents = [[NSFetchRequest alloc]init];
    [fetchFestivalEvents setEntity: [NSEntityDescription entityForName: @"Event"
                                                 inManagedObjectContext: iContext
                                      ]
     ];

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"festival == %@", iFestival]; // using iFestival.objectID circumvents the error
    [fetchFestivalEvents setPredicate:predicate];
    
    NSError __autoreleasing *error = nil;
    NSArray *results = [iContext executeFetchRequest:fetchFestivalEvents error:&error];
    for (Event *evt in results) {
        NSLog(@"%@",evt.name);
    }
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@",[error description]];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /// MANDATORY JUNK
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    CDNMasterViewController *masterViewController = [[CDNMasterViewController alloc] initWithNibName:@"CDNMasterViewController_iPhone" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
    masterViewController.managedObjectContext = self.managedObjectContext;
    
    [self.window makeKeyAndVisible];
    /// END MANDATORY JUNK

    
    
    // Initialise db with woodstock festival
    // Setup woodstock and a few performers
    
    Festival * woodstock = [Festival festivalWithName: @"Woodstock"
                                            inContext: ModelFactory.sharedModelFactory.mainManagedObjectContext];
    [Event eventWithName: @"Joan Baez"
              inFestival: woodstock
               inContext: ModelFactory.sharedModelFactory.mainManagedObjectContext];

    [Event eventWithName: @"Santana"
              inFestival: woodstock
               inContext: ModelFactory.sharedModelFactory.mainManagedObjectContext];

    [Event eventWithName: @"Greateful dead"
              inFestival: woodstock
               inContext: ModelFactory.sharedModelFactory.mainManagedObjectContext];
    
    [Event eventWithName: @"Janis Joplin"
              inFestival: woodstock
               inContext: ModelFactory.sharedModelFactory.mainManagedObjectContext];
    
    // Persit the data
    [ModelFactory.sharedModelFactory writeToDisk];


    // Get the woodstock object id; this is safe to use in a different managed object context
    NSManagedObjectID *obid = woodstock.objectID;


    // Do stuff in the backgroung
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @autoreleasepool {

            // Allocate a new MOC, with private concurrency
            NSManagedObjectContext *pvMoc = ModelFactory.sharedModelFactory.newPrivateManagedObjectContext;

            // Add an even to woodstock festival
            [pvMoc performBlockAndWait:^{
                @autoreleasepool {
                    [Event eventWithName: @"To the faithful departed"
                              inFestival: (Festival *)[pvMoc objectWithID:obid]
                               inContext: pvMoc];
                    
                    // Following raises GDCoreDataDegugging errors ???
                    // eventhough we are in the confort of a performBlockAndWait on pvMoc ??
                    [ModelFactory.sharedModelFactory saveContext: pvMoc];
                    [ModelFactory.sharedModelFactory writeToDisk];
                }
            }];

            // Allocate a new MOC, with private concurrency
            NSManagedObjectContext *pvMoc2 = ModelFactory.sharedModelFactory.newPrivateManagedObjectContext;
            [pvMoc2 performBlockAndWait:^{
                @autoreleasepool {

                    Festival *wdstk = (Festival *)[pvMoc2 objectWithID:obid];

                    // The executeFetchRequest inside the following method raises GDCoreDataDegugging errors
                    [self fetchEventsForFestival: wdstk
                                       inContext: pvMoc2];
                }
            }];
        }

        [ModelFactory.sharedModelFactory.mainManagedObjectContext performBlockAndWait:^{

            [ModelFactory.sharedModelFactory.mainManagedObjectContext deleteObject:[ModelFactory.sharedModelFactory.mainManagedObjectContext objectWithID:obid]];
            [ModelFactory.sharedModelFactory writeToDisk];
        }];
    });

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


@end
