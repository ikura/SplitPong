/*!
 @header    AriseAB.h
 @abstract  Splitforce iOS SDK AriseIO Compatibility Layer
 @version   1.0
 @copyright Copyright 2013 Ikura Group Limited. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class AriseAB;

/*!
 Splitforce Arise Compatibility Layer.  These methods all replace AriseAB method calls with Splitforce equivalents.
 */
@interface AriseAB : NSObject

/*!
 Calling this method raises an exception.  You should replace this call with the correct [SFManager managerWith...] call,
 making sure to paste the correct AppId and AppKey from the Splitforce backend.
 */
+ (AriseAB *)setupWithKey:(NSString *)appKey rpcURL:(NSString *)rpcURL;

/*!
 AriseAB Data Driven Test.
 */
+ (void)testWithName:(NSString *)name
                data:(void(^)(NSDictionary *testData))dataCallbackBlock;

/*!
 AriseAB Simple Test with two code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB;

/*!
 AriseAB Simple Test with three code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC;

/*!
 AriseAB Simple Test with four code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC
                   D:(void(^)(void))blockD;

/*!
 AriseAB Simple Test with five code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC
                   D:(void(^)(void))blockD
                   E:(void(^)(void))blockE;

/*!
 AriseAB Simple Test with six code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC
                   D:(void(^)(void))blockD
                   E:(void(^)(void))blockE
                   F:(void(^)(void))blockF;

/*!
 AriseAB Simple Test with seven code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC
                   D:(void(^)(void))blockD
                   E:(void(^)(void))blockE
                   F:(void(^)(void))blockF
                   G:(void(^)(void))blockG;

/*!
 AriseAB Simple Test with eight code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC
                   D:(void(^)(void))blockD
                   E:(void(^)(void))blockE
                   F:(void(^)(void))blockF
                   G:(void(^)(void))blockG
                   H:(void(^)(void))blockH;
/*!
 AriseAB Simple Test with nine code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC
                   D:(void(^)(void))blockD
                   E:(void(^)(void))blockE
                   F:(void(^)(void))blockF
                   G:(void(^)(void))blockG
                   H:(void(^)(void))blockH
                   I:(void(^)(void))blockI;
/*!
 AriseAB Simple Test with ten code paths.
 */
+ (void)testWithName:(NSString *)name
                   A:(void(^)(void))blockA
                   B:(void(^)(void))blockB
                   C:(void(^)(void))blockC
                   D:(void(^)(void))blockD
                   E:(void(^)(void))blockE
                   F:(void(^)(void))blockF
                   G:(void(^)(void))blockG
                   H:(void(^)(void))blockH
                   I:(void(^)(void))blockI
                   J:(void(^)(void))blockJ;

/*!
 AriseAB Goal - the goal name MUST match the name of the test.
 */
+ (void)goalReached:(NSString *)name;

/*!
 AriseAB handy utility to convert RGB Hex string into a UIColor object.
 */
+ (UIColor *)colorFromHex:(NSString *)hex;

@end
