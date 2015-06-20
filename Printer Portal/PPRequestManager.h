//
//  PPRequestManager.h
//  Printer Portal
//
//  Created by Eldon on 6/20/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface PPRequestManager : AFHTTPRequestOperationManager
+(PPRequestManager *)manager;
@end
