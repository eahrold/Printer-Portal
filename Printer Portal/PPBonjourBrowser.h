//
//  PIBonjourBrowser.h
//  Printer-Installer
//
//  Created by Eldon on 1/15/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPBonjourBrowser;

@interface PPBonjourBrowser : NSNetServiceBrowser<NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (copy, nonatomic) NSArray *bonjourPrinters;
@property BOOL isSearching;

- (void)start;

@end
