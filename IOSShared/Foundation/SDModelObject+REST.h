//
//  SDModelObject+SDModelObject_REST.h
//  walmart
//
//  Created by David Pettigrew on 5/6/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

#import "SDModelObject.h"
#import "SDWebService.h"

@interface SDModelObject (REST)

+ (NSString *)serviceMethodNameForRequestId:(NSString *)requestId;

// The model classes should implement this
// It provides a dictionary of request names that reference requests in the service plist file
// A Pangea subclass will override this and it "should" just work using new service requests in the plist file
+ (NSDictionary *)requestIdMap;

@end
