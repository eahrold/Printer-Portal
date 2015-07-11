//
//  PPObject.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPErrorHandler.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

// Base object for Printer Portal classes
@interface PPObject : NSObject

/**
 *  Error handler object.
 *
 * @note The shared handler is set for use by default on all subclasses.
 * The shared handler's -errorSignal is subscribed to by the app delegate, and when triggered displays an NSAlert.
 * For different behavior initialize a new errorHandler.
 */
@property (strong) PPErrorHandler *errorHandler;
@end
