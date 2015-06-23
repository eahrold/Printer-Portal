//
//  NSTextField+AnimatedString.h
//  Printer Portal
//
//  Created by Eldon on 6/21/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (fadeOut)
@property (nonatomic, assign) BOOL fadeOut;

-(void)fadeOutWithString:(NSString *)aString;
-(void)fadeOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
@end
