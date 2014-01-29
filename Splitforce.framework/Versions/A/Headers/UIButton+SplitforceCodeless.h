/*!
 @header    UIButton+SplitforceCodeless.h
 @abstract  Splitforce iOS Codeless Variation Support
 @version   1.0
 @copyright Copyright 2013 Ikura Group Limited. All rights reserved.
 */

#import <UIKit/UIKit.h>

/*!
 Additional utitilies to work with codeless variation objects
 */
@interface UIButton (SplitforceCodeless)

/*!
 The default behaviour of a Codeless Button is to send a single timed and conversion goal
 upon touchUpInside and then close the variation.  If you want to track multiple events
 on the button, you should call retest on the button after the completion of the experiment.
 
 To ensure correct operation you should dispatch this to the next iteration of the runloop to make
 sure that all target actions are complete before retesting.  
 */
- (void)retest;

@end
