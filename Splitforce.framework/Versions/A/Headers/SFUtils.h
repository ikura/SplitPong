/*!
 @header    SFUtils.h
 @abstract  Splitforce iOS SDK Utilities Header
 @version   1.0
 @copyright Copyright 2013 Ikura Group Limited. All rights reserved.
 */

#import <UIKit/UIKit.h>

/*!
 Splitforce Utilities class. Provides convenient utilities for working with splitforce data.
 Typically these are implemented as Class methods.
 */
@interface SFUtils : NSObject

/*!
 Convert an RGB Hex String into a UIColor object
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
