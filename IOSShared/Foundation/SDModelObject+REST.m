//
//  SDModelObject+REST.m
//  walmart
//
//  Created by David Pettigrew on 5/6/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import "SDModelObject+REST.h"

@implementation SDModelObject (REST)

#pragma mark Template method
+ (NSDictionary *)requestIdMap {
    [NSException raise:@"Missing implementation" format:@"Missing implementation"];
    return @{};
}

// A Pangea subclass will override this and it "should" just work using new service requests in the plist file
+ (NSString *)serviceMethodNameForRequestId:(NSString *)requestId {
    if (!requestId) {
        return nil;
    }
    NSString *requestIdMapping = self.requestIdMap[requestId];
    return requestIdMapping;
}

@end
