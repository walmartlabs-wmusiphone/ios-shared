//
//  SDSpanParser.h
//
//  Created by Steven W. Riggins on 1/19/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDSpanParser : NSObject

/**
 *  Parse a string for <span class="style"> and </span> tags
 *
 *  @param string The string to parse
 *  @param styles A dictionary which has style names as keys, and text attributes values (see NSAttributedString docs)
 *
 *  @return A styled NSAttributedString
 */
+ (NSAttributedString *)parse:(NSString *)string withStyles:(NSDictionary *)styles;
@end


