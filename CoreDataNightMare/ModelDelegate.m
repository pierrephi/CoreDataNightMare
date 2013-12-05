//
//  ModelDelegate.m
//  imiwa
//
//  Created by Pierre-Phi on 25/09/13.
//  Copyright (c) 2013 pierrephi.net. All rights reserved.
//

#import "ModelDelegate.h"
#import "ModelFactory.h"
#import <CoreData/CoreData.h>

//#define DSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#define DSLog(format, ...)

@implementation ModelDelegate

SYNTHESIZE_SINGLETON_FOR_CLASS(ModelDelegate);

- (id)init {
    self = [super init];

    if (self) {

    }

    return self;
}


@end