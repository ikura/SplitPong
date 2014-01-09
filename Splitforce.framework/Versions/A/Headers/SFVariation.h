/*!
 @header    SFVariation.h
 @abstract  Splitforce Variation iOS SDK Header
 @version   1.0
 @copyright Copyright 2013 Ikura Group Limited. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 Splitforce iOS Variation class. Provides variation data and interface
 to report on goals caused by this variation.
 */
@interface SFVariation : NSObject


/**---------------------------------------------------------------------------------------
 * @name Getting the Variation Data
 *  ---------------------------------------------------------------------------------------
 */
/*!
 The variationData property contains a dictionary of configuration information
 which are to be used to configure the application.
 */
@property (nonatomic, strong, readonly) NSDictionary *variationData;

/**---------------------------------------------------------------------------------------
 * @name Experiment Name
 *  ---------------------------------------------------------------------------------------
 */
/*!
Get the name of the experiment that created this variation.
 */

@property (nonatomic, strong, readonly) NSString *experimentName;

/**---------------------------------------------------------------------------------------
 * @name Variation Name
 *  ---------------------------------------------------------------------------------------
 */
/*!
 Get the name of the variation that was set on Splitforce.com.
 */

@property (nonatomic, strong, readonly) NSString *name;


/**---------------------------------------------------------------------------------------
 * @name Recording Goals
 *  ---------------------------------------------------------------------------------------
 */
/*!
 When a discrete named goal has been met, call this method on the SFVariation object
 to record that goal in the backend.
 
 @param name The name of the goal to track in the Splitforce results browser.
 */
- (void)goalResultNamed:(NSString *)name;

/*!
 To track the length of time since the variation was applied, use the timedResultNamed:
 method.  This automatically tracks the length of time (in seconds) since the variation
 was applied.

  @param name The name of the goal to track in the Splitforce results browser.
 */
- (void)timedResultNamed:(NSString *)name;

/*!
 To track arbitrary lengths of time, use the timedResultNamed:withTime: method.
 Your code is repsonsible for making sure the time interval is meaningful for tracking.
 
  @param name The name of the goal to track in the Splitforce results browser.
  @param time The time value to set for this goal in the Splitforce results browser.
 */
- (void)timedResultNamed:(NSString *)name withTime:(NSTimeInterval)time;

/*!
 To track a counted goal use the countedResultNamed:count: method.  This is useful
 for counting the number of actions that happen as a result of a particular variation.
 
 @deprecated use method quantifiedResultNamed:quantity instead
 
 @param name The name of the goal to track in the Splitforce results browser.
 @param count The number to set for this goal in the Splitforce results browser.
 */
- (void)countedResultNamed:(NSString *)name count:(NSUInteger)count __attribute__((deprecated("use method quantifiedResultNamed:quantity instead")));


/*!
 To track a quantified goal use the quantifiedResultNamed:quantity: method.  This is useful
 for integer quantities that happen as a result of a particular variation.

 @param name The name of the goal to track in the Splitforce results browser.
 @param quantity The number to set for this goal in the Splitforce results browser.
 */
- (void)quantifiedResultNamed:(NSString *)name quantity:(NSInteger)quantity;


/*!
 When no more variation goals are required, call variationEnded.  This will cause the variation
 to dissociate itself from its bound object and in most cases will cause the Variation to be
 dealloced.  If you retain the variation and continue to send goals, the behaviour is undefined.
 In later releases this will likely lead to an Exception being raised.
 */
- (void)variationEnded;

/**---------------------------------------------------------------------------------------
 * @name Retrieving the SFVariation for goal tracking later in the workflow
 *  ---------------------------------------------------------------------------------------
 */
/*!
 In order to easily retrieve the SFVariation that led to a particular goal, you can bind the object
 to an arbitrary object.  The arbitrary object will retain the SFVariation object and thus the SFVariation
 may be dealloced when the arbitrary object is dealloced.  The arbitrary object's retain count is unaffected
 by this call.
 Typically this would be used to bind the SFVariation to the object which has been varied by the data. 
 So for example, the variation could be bound to a UIButton.  When the UIButton is the pressed by the user
 the button's target can easily submit the goal with:
        [[SFManager.currentManager variationForObject:sender] goalResultNamed:@"buttonPressed"]
 
 You can only bind an SFVariation to a single object.  Multiple calls will replace the previous binding.
 You can only bind a single SFVariation to a particular object.  Muliple calls will replace the previous binding and you may
 lose the ability to track goal completions for that variation if you bind another variation to the same object.  Therefore
 binding to the UIApplicationDelegate is likely to be a bad idea.  Binding to the closest container or controller object that
 received the benefit of the variation is likely to be the best way to go.
 
 @param object The object to bind this variation to.  Typically this should be the object which was configured
 by this Variation, or an object which will be called at the goal completion.

 @deprecated This is no longer necessary, you can retrieve the same Variation object using [SFManager.currentManager variationForExperimentNamed:] and passing in the experiment name instead.

 */
- (void)bindVariationToObject:(id)object __attribute__((deprecated("Don't use this method - when retrieving the Variation at goal tracking time use method variationForExperimentNamed: instead of variationForObject:")));

@end
