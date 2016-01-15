//
//  NSMutableAttributedString+SDExtensions.h
//  SetDirection
//
//  Created by Steven W. Riggins on 8/13/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (SDExtensions)

/**
 *	Sets the foreground color of the attributed string
 *
 *	@param	color	The color of the text
 */
- (void)setForegroundColor:(UIColor *)color;

/**
 *	Sets the foreground color of the characters in the given range of the attributed string
 *
 *	@param	color	The color of the text
 *	@param	range	The range to apply the color to
 */
- (void)setForegroundColor:(UIColor *)color range:(NSRange)range;

/**
 *	Sets the font of the attributed string
 *
 *	@param	font	The font of the text
 */
- (void)setFont:(UIFont *)font;

/**
 *	Sets the font of of the characters in the given range of the attributed string
 *
 *	@param	font	The font of the text
 *	@param	range	The range to apply the font to
 */
- (void)setFont:(UIFont *)font range:(NSRange)range;
@end
