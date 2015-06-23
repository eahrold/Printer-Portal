//
//  PPRequestManager.m
//  Printer Portal
//
//  Created by Eldon on 6/20/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPRequestManager.h"
#import "PPErrorHandler.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PPRequestResponse

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _printerList = [aDecoder decodeObjectOfClass:[NSArray class]
                                             forKey:NSStringFromSelector(@selector(printerList))];

        _subnet = [aDecoder decodeObjectOfClass:[NSString class]
                                         forKey:NSStringFromSelector(@selector(subnet))];

        _updateServer = [aDecoder decodeObjectOfClass:[NSString class]
                               forKey:NSStringFromSelector(@selector(updateServer))];

    }
    return self;
}

+ (BOOL)supportsSecureCoding { return YES;}

- (void)encodeWithCoder:(NSCoder *)aEncoder {
    [aEncoder encodeObject:_printerList
                    forKey:NSStringFromSelector(@selector(printerList))];
    [aEncoder encodeObject:_subnet
                    forKey:NSStringFromSelector(@selector(subnet))];
    [aEncoder encodeObject:_updateServer
                    forKey:NSStringFromSelector(@selector(updateServer))];

}

- (instancetype)initWithResponse:(NSDictionary *)response {
    if (self = [super init]) {
        _printerList = response[NSStringFromSelector(@selector(printerList))];
        // _printerList should always be included
        NSParameterAssert(_printerList);

        _subnet = response[NSStringFromSelector(@selector(subnet))];
        _updateServer = response[NSStringFromSelector(@selector(updateServer))];
    }
    return self;
}
@end

@implementation PPRequestManager
+(PPRequestManager *)manager {
    PPRequestManager *manager = [super manager];
    // Set up the legacy serializer.
    AFPropertyListResponseSerializer *legacySerializer = [AFPropertyListResponseSerializer serializer];
    legacySerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",
                                               @"application/xml",
                                               @"application/x-plist",
                                               nil];

    AFCompoundResponseSerializer *serializer =
    [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[
                                                                              legacySerializer,
                                                                              [AFJSONResponseSerializer serializer]]];

    manager.responseSerializer = serializer;

    return manager;
}

- (RACSignal *)GET_rac:(NSString *)URLString parameters:(id)parameters {
    return [RACSignal startLazilyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        [[PPRequestManager manager] GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [subscriber sendNext:[[PPRequestResponse alloc] initWithResponse:responseObject]];
                [subscriber sendError:nil];
            } else {
                [subscriber sendError:PPErrorFromCode(kPPErrorServerURLInvalid)];
            }
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];
    }];
}

@end
