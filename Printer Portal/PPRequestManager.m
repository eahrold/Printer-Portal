//
//  PPRequestManager.m
//  Printer Portal
//
//  Created by Eldon on 6/20/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPRequestManager.h"

@implementation PPRequestManager
+(PPRequestManager *)manager {
    PPRequestManager *manager = [super manager];
    // Set up the legacy serializer.
    AFPropertyListResponseSerializer *legacySerializer = [AFPropertyListResponseSerializer serializer];
    legacySerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/xml", nil];

    AFCompoundResponseSerializer *serializer =
    [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[
                                                                              legacySerializer,
                                                                              [AFJSONResponseSerializer serializer]]];

    manager.responseSerializer = serializer;

    return manager;
}
@end
