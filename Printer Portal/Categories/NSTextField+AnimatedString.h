//
//  NSTextField+AnimatedString.h
//  Printer Portal
//
//  Created by Eldon on 6/21/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (fadeOut)

// BOOL indicating the text field should begin a fade out animation.
@property (nonatomic, assign) BOOL fadeOut_string;

/**
 * Fade out the text field with a given string
 *
 *  @param aString string value for the text field.
 *  @note By default the string will wait 2 seconds, then fade from alpha 1.0 -> 0.0 over 1 second.
 */
- (void)fadeOut_withString:(NSString *)aString;

/**
 *  Fade out a text field while setting the behavior parameters
 *
 *  @param duration Interval (as double) the transition from alpha 1.0 -> 0.0 should last.
 *  @param delay Number of seconds (as double) to wait before beginning a fade out.
 */
- (void)fadeOut_withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
@end
