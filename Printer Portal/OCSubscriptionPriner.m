//
//  PPSubscriptionPrinter.m
//  Printer Portal
//
//  Created by Eldon on 6/22/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "OCSubscriptionPriner.h"
#import <Objective-CUPS/OCPrinter_Private.h>

@implementation OCSubscriptionPriner
@synthesize ppd = _ppd;
@synthesize ppd_tempfile = _ppd_tempfile;

- (NSString *)ppd {
    _ppd = [self cached_ppd];
    if (access(_ppd.UTF8String, R_OK) != 0) {
        _ppd = [super ppd];
    }
    return _ppd;
}

- (NSString *)ppd_tempfile {
    _ppd_tempfile = [super ppd_tempfile];
    NSString *cache_ppd = [self cached_ppd];
    if (_ppd_tempfile && ![_ppd_tempfile isEqualToString:cache_ppd]) {
        [[NSFileManager defaultManager] copyItemAtPath:_ppd_tempfile toPath:cache_ppd error:nil];
    }
    return _ppd_tempfile;
}

- (NSString *)cached_ppd {
    NSString *tmpDir = NSTemporaryDirectory();
    // Name of the ppd...
    NSString *cachePPD = [[NSString stringWithFormat:@"com.eeaapps.printer-portal.subscription.ppd.%@", self.name ]
                          stringByAppendingPathExtension:[self.model stringByReplacingOccurrencesOfString:@" " withString:@"_"]];

#if DEBUG
    /* It's just easier to look here during development */
    tmpDir = @"/tmp";
#endif
    
    return [tmpDir stringByAppendingPathComponent:cachePPD];
}

@end
