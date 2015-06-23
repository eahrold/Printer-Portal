//
//  NSTextField+AnimatedString.m
//  Printer Portal
//
//  Created by Eldon on 6/21/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "NSTextField+AnimatedString.h"
#import <Quartz/Quartz.h>

@implementation NSTextField (fadeOut)

- (BOOL)fadeOut {
    return NO;
}

- (void)setFadeOut:(BOOL)fadeOut {
    if (fadeOut) {
        [self fadeOutWithDuration:1.0 delay:3.0];
    }
}

- (void)fadeOutWithString:(NSString *)aString {
    self.stringValue = aString;
    [self fadeOutWithDuration:1.0 delay:3.0];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    self.animator.alphaValue = 1.0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = delay;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
        completionHandler:^{
                            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                                context.duration = duration;
                                context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                                self.animator.alphaValue = 0.0;
                            } completionHandler: ^{
                                /* Set the string value to @"" so we can reset the alpha to 1.0.
                                 * If you don't do this if the string is set by another method
                                 * it's won't be visible */
                                self.stringValue = @"";
                                self.animator.alphaValue = 1.0;
                            }];
        }];
}
@end
