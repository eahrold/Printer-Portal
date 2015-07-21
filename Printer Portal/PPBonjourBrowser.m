//
//  PIBonjourBrowser.m
//  Printer-Installer
//
//  Created by Eldon on 1/15/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import "PPBonjourBrowser.h"
#import <Objective-CUPS/OCPrinter.h>

@interface PPBonjourBrowser ()

@property (strong, atomic) NSMutableSet *services;
@property (strong, atomic) NSMutableSet *printers;

@end

@implementation PPBonjourBrowser
- (id)init {
    self = [super init];
    if (self) {
        _services = [NSMutableSet new];
        self.delegate = self;
    }
    return self;
}

- (void)start {
    [self searchForServicesOfType:@"_printer._tcp." inDomain:@"local"];
    //    [self searchForServicesOfType:@"_ipp._tcp." inDomain:@"local"];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    [_services addObject:service];
    [service setDelegate:self];
    [service startMonitoring];
    [service resolveWithTimeout:10];

    if (!moreComing) {
        // Nothing to do here.
    }
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    self.isSearching = YES;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    self.isSearching = NO;
    self.bonjourPrinters = nil;
    _printers = nil;

    [_services enumerateObjectsUsingBlock:^(NSNetService *service, BOOL *stop) {
        [service stop];
    }];

    [_services removeAllObjects];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict {
    self.isSearching = NO;
    NSLog(@"[BONJOUR ERROR]: %@",
          [NSError errorWithDomain:[[NSProcessInfo processInfo] processName]
                              code:[[errorDict objectForKey:NSNetServicesErrorCode] integerValue]
                          userInfo:errorDict]);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    [_services removeObject:service];
    if (!moreComing) {
        self.bonjourPrinters = [_printers copy];
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    OCBonjourPrinter *printer = [[OCBonjourPrinter alloc] initWithNetService:netService];
    if (!_printers) {
        _printers = [[NSMutableSet alloc] init];
    }

    [_printers addObject:printer];
    [netService stop];

    if (_printers.count == _services.count) {
        self.bonjourPrinters = [_printers copy];
    }
}

@end
