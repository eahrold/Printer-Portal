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

@property BOOL searching;
@property (strong, atomic) NSMutableArray *services;
@property (strong, atomic) NSMutableArray *printers;

@end

@implementation PPBonjourBrowser {
    NSInteger _expectedServices;
}

- (id)init
{
    self = [super init];
    if (self) {
        _services = [NSMutableArray new];
        _searching = NO;
        _expectedServices = 0;
        self.delegate = self;

        [self searchForServicesOfType:@"_printer._tcp." inDomain:@"local"];
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing
{
    [_services addObject:service];
    [service setDelegate:self];
    [service startMonitoring];
    [service resolveWithTimeout:10];

    _expectedServices++;

    if (!moreComing) {
//        self.bonjourPrinters = [_printers copy];
    }
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    _searching = YES;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    _searching = NO;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
    _searching = NO;
    NSLog(@"[BONJOUR ERROR]: %@" ,
          [NSError errorWithDomain:[[NSProcessInfo processInfo] processName]
                              code:[[errorDict objectForKey:NSNetServicesErrorCode] integerValue]
                          userInfo:errorDict]);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing
{
    [_services removeObject:service];
    if (!moreComing) {
        self.bonjourPrinters = [_printers copy];
    }
}



- (void)netServiceDidResolveAddress:(NSNetService *)netService
{
    OCBonjourPrinter *printer = [[OCBonjourPrinter alloc] initWithNetService:netService];
    if (!_printers) {
        _printers = [[NSMutableArray alloc] init];
    }

    [_printers addObject:printer];
    [netService stop];
    if (_printers.count == _services.count) {
        self.bonjourPrinters = [_printers copy];
    }
}



@end

