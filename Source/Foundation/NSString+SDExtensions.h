//
//  NSString+SDExtensions.h
//  SetDirection
//
//  Created by Ben Galbraith on 2/25/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(SDExtensions)

/**
 A convenience method to create a UUID of type NSString using CFUUID* functions.
 */
+ (NSString *)stringWithNewUUID;

/**
 A convenience method to create a JSON string from a given object.
 */
+ (NSString *)stringWithJSONObject:(id)obj;

/**
 A method to replace HTML in multi-line strings with an adequate plain-text alternative, using Unicode characters where appropriate to replace.
 @param keepBullets If `YES` then convert HTML list items tags into `•`, rather than discarding them.
 */
- (NSString *)replaceHTMLWithUnformattedText:(BOOL)keepBullets;

/**
 A method to replace HTML in multi-line strings with an adequate plain-text alternative, using Unicode characters where appropriate to replace.
 */
- (NSString *)replaceHTMLWithUnformattedText;

/**
 A method to replace HTML in single-line strings designed for compact representation (e.g., items in a list)
 This is similar in behavior to replaceHTMLWithUnformattedText except it makes no attempt to format text for attractive multi-line display.
 */
- (NSString *)stripHTMLFromListItems;

/**
 Replace the characters in the set `￼=,!$&'()*+;@?\n\"<>#\t :/` with percent escapes for the string in the receiver.
 */
- (NSString *)escapedString;

/**
 Replaces all ocurrences of multiple white space characters in the receiver with a single space character.
 */
- (NSString *)removeExcessWhitespace;

/**
 Replaces all leading white space characters in the receiver with a single space character.
 */
- (NSString *)removeLeadingWhitespace;

/**
 Removes all leading zeroes in the receiver.
 */
- (NSString *)removeLeadingZeroes;

/**
 Replaces all trailing white space characters in the receiver with a single space character.
 */
- (NSString *)removeTrailingWhitespace;

/**
 Returns a dictionary created from all key-value pairs in the receiver assuming it is formatted as URL query parameters.
 */
- (NSDictionary *)parseURLQueryParams;

/**
 Returns true if the receiver matches an email address as defined by the regex at http://www.cocoawithlove.com/2009/06/verifying-that-string-is-email-address.html
 */
- (BOOL)isValidateEmailFormat;

/**
 Returns the string formatted with the given number format.
 
 ie: ##/##/#### would return 08/25/1977 for example.
 */
- (NSString *)stringWithNumberFormat:(NSString *)format;

/**
 *
 * Returns a UIColor objects for the string's hex representation:
 *
 * For example: [@"#fff" uicolor] returns a UIColor of white.
 *              [@"#118653" uicolor] returns something green.
 *
 */
- (UIColor *)uicolor;
@end
