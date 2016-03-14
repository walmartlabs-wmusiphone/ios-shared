//
//  SDImageCacheTestExports.h
//  walmart
//
//  Created by Steven Riggins on 3/10/16.
//  Copyright © 2016 Walmart. All rights reserved.
//

#ifndef SDImageCacheTestExports_h
#define SDImageCacheTestExports_h

#import "SDImageCache.h"

@interface SDImageCache(Testting)
- (NSMutableDictionary *)activeConnectionsForTesting;
- (void)cacheConnection:(SDURLConnection *)connection forURL:(NSURL *)url;
- (void)removeConnectionForURLFromCache:(NSURL *)url;
@end

#endif /* SDImageCacheTestExports_h */
