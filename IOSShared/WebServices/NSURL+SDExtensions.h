//
//  NSURL+SDExtensions
//  SetDirection
//
//  Created by Steven W. Riggins on 1/29/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SDExtensions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;	// Experiment with namespace collisions was short lived

@end
