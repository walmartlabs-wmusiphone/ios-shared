//
//  SDPaintCodeButton.h
//
//  Created by ricky cancro on 12/20/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 A UIButton subclass that can take paint code's code to set the button's background images.
 This code is based upon the sample code from PaintCode.
 */
@interface SDPaintCodeButton : UIButton

/**
 Creates an UIImage that is used as the button's highlighted state.  The UIImage is not returned, but is 
 set in the button's background using UIView+PaintCode's imageFromSelector.  You can paste code directly
 from paint code into this method.  For example:
 
 - (void)drawButtonHighlighted
 {
     //// Color Declarations
     UIColor* white = [UIColor whiteColor];
     UIColor* pressesGray = [UIColor highlightedButtonColor];
     
     //// TrolleyPaddle-CircDec2 Drawing
     UIBezierPath* trolleyPaddleCircDec2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 30, 30)];
     [pressesGray setFill];
     [trolleyPaddleCircDec2Path fill];
     [white setStroke];
     trolleyPaddleCircDec2Path.lineWidth = 1;
     [trolleyPaddleCircDec2Path stroke];
 }
 */
- (void)drawButtonHighlighted;

/**
 Creates a UIImage that is used as the button's disabled state.  See the comments for drawButtonHighlighted 
 for more information.
 */
- (void)drawButtonDisabled;

/**
 Creates a UIImage that is used as the button's normal state.  See the comments for drawButtonHighlighted
 for more information.
 */
- (void)drawButtonNormal;

/**
 This method must be called to render the images for the normal, disabled and highlighted states of the button.
 It is not called automatically in case your button subclass has user-definable parameters such as line color
 or fill color.  You could, however, create setter methods for these paramters that in turn call createButtonStates.
 */
- (void)createButtonStates;
@end
