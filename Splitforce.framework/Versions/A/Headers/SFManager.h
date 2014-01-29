/*!
 @header    SFManager.h
 @abstract  Splitforce Manager iOS SDK Header
 @version   1.0
 @copyright Copyright 2013 Ikura Group Limited. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Splitforce/SFVariation.h>

/*!
 An Objective-C Block taking an SFVariation object as a singular parameter to apply a variation.
 */
typedef void(^SFExperimentVariationBlock)(SFVariation *variation);

/*!
 An Objective-C Block taking a BOOL as a singular parameter to indicate success or failure
 */
typedef void(^SFBooleanBlock)(BOOL success);

/*!
 An Objective-C Block with no parameters
 */
typedef void(^SFVoidBlock)(void);


/*!
 An Objective-C Block taking an NSError object as a singular parameter which may provide further details on why an error has occured.
 */
typedef void(^SFErrorBlock)(NSError *error);

/*!
 An Objective-C Block taking an NSDictionary object representing the Cohort Identifier, with experiment names as keys and variation names as values.
 */
typedef void(^SFCohortIdentifierBlock)(NSDictionary *cohortIdentifier);

/*!
 An Objective-C Block taking an NSDictionary object representing the Cohort Identifier, with experiment names as keys and variation names as values.
 The block should return nil, or a modified cohortIdentifier block which allows you to control the cohort programatically.  This should not be done
 on live experiments, but is useful when testing your code paths as you can control which paths will be executed using this method.
 */
typedef NSDictionary *(^SFWillUseCohortIdentifierBlock)(NSDictionary *cohortIdentifier);


/*!
 Splitforce iOS top-level class. Provides synchronisation with Splitforce backend
 and configuration of settings.
 */
@interface SFManager : NSObject

/**---------------------------------------------------------------------------------------
 * @name Settings and Configuration
 *  ---------------------------------------------------------------------------------------
 */


/*!
 The frequency of sending data to the Splitforce backend.
 */
@property (nonatomic) NSTimeInterval updateFrequency;

/**---------------------------------------------------------------------------------------
 * @name Access to the SFManager object
 *  ---------------------------------------------------------------------------------------
 */

/*!
 For convenience, this class exposes a current manager instance.
 This will be set to the first manager that is instantiated in managerWithApplicationId:applicationKey:
 or managerWithApplicationId:applicationKey:completionBlock
 It is a programming error to retrieve this manager before the first manager has been instantiated.
 Doing so will raise an Exception.
 
 @return The current SFManager
 */
+ (SFManager *)currentManager;

/*!
 Connect to the Splitforce backend.
 This method will start a connection to the Splitforce backend.  The method returns immediately
 while the connection happens in the background.  To get a callback when the manager is completely
 ready, use the managerWithApplicationId:applicationKey:completionBlock method instead.
 
 There are a number of different issues to be aware of when setting up the Splitfore connection.
 Firstly, if you apply an experiment before the connection is established, then the experimentNamed:applyVariationBlock:errorBlock
 method will block until the manager is ready (or has failed) - to prevent blocking the main thread, initialize the manager with the
 managedWithApplicationId:applicationKey:completionBlock method instead.
 
 Secondly, if an experiment is applied when the manager has failed to connect, this user will join the "default" cohort and see the
 error block variation.  See the property persistFailedExperiments for details on the behaviour in this case.
 
 Finally, if there is cached data, then that is used even if the connection fails to get new data.
 
In general - as long as the user has a functioning internet connection the first time they run the application, then
 there will be no issues.  You may decide that running your application without an active splitforce connection is
 undesirable - in which case the managerWithApplicationId:applicationKey:completionBlock method should be used to ensure
 that the initial connection has been made before proceeding further into your aplication.
 
 @param applicationId The Application Id provided by the Splitforce Web server.
 @param applicationKey The Application Key provided by the Splitforce Web server.
 @return An SFManager object connected to the specified applicationId.
 */
+ (SFManager *)managerWithApplicationId:(NSString *)applicationId applicationKey:(NSString *)applicationKey;

/*!
 Asynchronously connect to the Splitforce backend.
 This method will call the completionBlock when either the locally cached variation data
 is ready, or an updated version has been retrieved from the backend.  In case of error (e.g. first time
 usage with no network coverage it will call the completionBlock with NO.  Otherwise the completionBlock
 will be called with YES.
 
 There are a number of different issues to be aware of when setting up the Splitfore connection.
 Firstly, if you apply an experiment before the connection is established, then the experimentNamed:applyVariationBlock:errorBlock
 method will queue variation blocks until the manager is ready (or has failed) - this can lead to the user interface being updated
 in front of the user if the data completes loading after the experiment has been applied.  Waiting for the completionBlock to be called
 before applying experiments will resolve this issue.
 
 Secondly, if an experiment is applied when the manager has failed to connect, this user will join the "default" cohort and see the
 error block variation.  See the property persistFailedExperiments for details on the behaviour in this case.
 
 Finally, if there is cached data, then that is used even if the connection fails to get new data.
 
 In general - as long as the user has a functioning internet connection the first time they run the application, then
 there will be no issues.  You may decide that running your application without an active splitforce connection is
 undesirable - in which case the managerWithApplicationId:applicationKey:completionBlock method should be used to ensure
 that the initial connection has been made before proceeding further into your aplication.

 @param applicationId The Application Id provided by the Splitforce Web server.
 @param applicationKey The Application Key provided by the Splitforce Web server.
 @param completionBlock An SFBooleanBlock which will be called when the SFManager has been connected, or failed to connect.

 */
+ (void)managerWithApplicationId:(NSString *)applicationId
                  applicationKey:(NSString *)applicationKey
                 completionBlock:(SFBooleanBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Class Parameters
 *  ---------------------------------------------------------------------------------------
 */

/*!
 Set the timeout for connecting to the Splitforce backend.  Note that an initial connect requires two round trips, so
 the max time any method would block or the max time for a callback to be called may be twice this value.  Note also
 that you must set this parameter before initialising the manager connection, hence this is a class method.  Changing
 the value after the manager has been established will have no effect.
 
 @param timeoutInterval The length of time in seconds for network timeouts
 */
+ (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

/*!
 Switching on debugMode will provide more detailed logs on the console and should be switched on for all DEBUG builds.
 Debug mode also enables 'Shake to Variation' which allows you to force particular variations to be used from the UI within the app.
 Simply shake the device to get a menu of Experiments and Variations.
 */
+ (void)setDebugMode:(BOOL)debugMode;

/*!
 When using Shake to Variation, you may need to reinitialise singletons or instances that were configured with the data.
 If so then you can do that within this block.
 */
@property (nonatomic, copy) SFVoidBlock shakeToVariationDidChangeVariationBlock;

/*!
 By default, if an experiment is applied when there is no splitforce data available, then the default block
 is called, and users will see the default implementation.  To ensure users always get the same implementation,
 we persist the state that these users are in the default cohort, and therefore will not have experiments applied.
 Set this to NO to have the variation data applied on future runs after the data is available.
 Note that this only applies to the offline failures, experiments that fail due to the experiment being
 undefined at the time of application will not be persisted as failures once the experiment is added to the dataset.

 Note that this parameter is subordinate to transientVariations.  If transientVariations is set then the user will
 always see either new data if available, or default data if the connection is offline.
 */

+ (void)setPersistDefaultCohort:(BOOL)persistDefaultCohort;

/*!
 The Cohort Identifier is a dictionary with Experiment Names for keys and Variant Names for values.
 Set this block before instantiating the SFManager.  This block will then be called on the main thread
 when the cohort has been established.  The Cohort Identifier may be useful for interfacing with third
 party or bespoke Analytics services for example.
 
 Note that this block will not be called if Transient Variations is set.
 
 Also note that the default cohort is represented as an empty dictionary.
 */

+ (void)setIdentifyCohortBlock:(SFCohortIdentifierBlock)identifyCohortBlock;

/*!
 The Cohort Identifier is a dictionary with Experiment Names for keys and Variant Names for values.
 Set this block before instantiating the SFManager.  This block will then be called on the main thread
 when the cohort has been established.  The Cohort Identifier may be useful for interfacing with third
 party or bespoke Analytics services for example.
 
 Note that this block will not be called if Transient Variations is set.
 
 Also note that the default cohort is represented as an empty dictionary.

 When running in Debug mode, your cohort modification block will be called before any Shake to Variation choice is applied.  That is, Shake to Variation takes precedence over cohort modifications made in this block.
 */

+ (void)setWillUseCohortIdentifierBlock:(SFWillUseCohortIdentifierBlock)willUseCohortIdentifierBlock;

/*!
Custom Variation Targetting allows you to use short Javascript scripts to block/allow particular Variations for different groups of users.
 Pass in data to your CVT scripts using setCVTGlobalObjectValues (prior to initialising SFManager).  The keys will be passed to the
 JS Global Object as variables set their corresponding values.
 */
+ (void)setCVTGlobalObjectValues:(NSDictionary *)globalObjectValues;

/**---------------------------------------------------------------------------------------
 * @name Running Experiments
 *  ---------------------------------------------------------------------------------------
 */

/*!
 Get the data for an experiement and execute the variationBlock on the selected variation.
 The SFVariation object provided to the applyVariationBlock will contain the raw data
 in the variationData property.  The SFVariation object shall be used when goal conditions
 are met in order to accurately track the variation and result.  The - [SFVariation bindVariationToObject:] method
 is provided as a convenience an can be used in conjunction with - [SFManager variationForObject:] to 
 retrieve the correct SFVariation object at a later point.
 
 The error block should be used to configure default settings for your user.  The error block can be called
 if there is no connection to the splitforce servers, and no cached content available for your users.
 
 This method is functionally identical to experimentNamed:applyVariationBlock:applyDefaultBlock - however
 the semantics of the latter are clearer, so this method has been deprecated in favour of the latter method.

 @deprecated use method experimentNamed:applyVariationBlock:applyDefaultBlock instead

 @param experimentName The name of an experiment defined on the Splitforce Web Server.
 @param applyVariationBlock An SFExperimentVariationBlock which will be called when there is valid data for this experiement
 @param errorBlock An SFErrorBlock which will be called if there is no valid data for this experiement

 */
- (void)experimentNamed:(NSString *)experimentName
    applyVariationBlock:(SFExperimentVariationBlock)applyVariationBlock
             errorBlock:(SFErrorBlock)errorBlock __attribute__((deprecated("use method experimentNamed:applyVariationBlock:applyDefaultBlock instead")));

/*!
 Get the data for an experiement and execute the variationBlock on the selected variation.
 The SFVariation object provided to the applyVariationBlock will contain the raw data
 in the variationData property.  The SFVariation object shall be used when goal conditions
 are met in order to accurately track the variation and result.  The - [SFVariation bindVariationToObject:] method
 is provided as a convenience an can be used in conjunction with - [SFManager variationForObject:] to
 retrieve the correct SFVariation object at a later point.

 The default block should be used to configure default settings for your user.  The default block can be called
 if there is no connection to the splitforce servers, and no cached content available for your users.

 @param experimentName The name of an experiment defined on the Splitforce Web Server.
 @param variationBlock An SFExperimentVariationBlock which will be called when there is valid data for this experiement
 @param defaultBlock An SFErrorBlock which will be called if there is no valid data for this experiement.  The NSError parameter will indicate the reason for no data.  You should configure a default version of your variation in this block.

 */
- (void)experimentNamed:(NSString *)experimentName
    applyVariationBlock:(SFExperimentVariationBlock)variationBlock
      applyDefaultBlock:(SFErrorBlock)defaultBlock;

/**---------------------------------------------------------------------------------------
 * @name Retrieving a variation later (for goal submission)
 *  ---------------------------------------------------------------------------------------
 */

/*!
 Convenience method to retrieve the correct SFVariation object at a later point, when - [SFVariation bindToObject:]
 has been used.

 @deprecated Use variationForExperimentNamed: instead

 @param object An object which has previously had an SFVariation bound to it using [SFVariation bindVariationToObject:] 
 @return The SFVariation object which was bound to the object (typically it should be the SFVariation which was used to configure this object)

 */
- (SFVariation *)variationForObject:(id)object __attribute__((deprecated("use method variationForExperimentNamed: instead")));

/*!
 Convenience method to retrieve the SFVariation object for the most recent application of an experiment.
 
 Note that calling [variation bindToObject:] within an applyVariationBlock will cause this method to return nil.  If binding to an object call varationForObject: instead.

 @param experimentName A const NSString object matching the experimentName of a previously applied experiment.
 @return The SFVariation object which was bound to the object (typically it should be the SFVariation which was used to configure this object)

 */
- (SFVariation *)variationForExperimentNamed:(NSString *)experimentName;

/**---------------------------------------------------------------------------------------
 * @name Introspection Utilities
 *  ---------------------------------------------------------------------------------------
 */

/*!
 Get the framework version
 */
+ (NSString *)frameworkVersion;

/*!
 Get the list of known variation names for a particular experiment
 */
- (NSArray *)variationNamesForExperiment:(NSString *)experimentName;

/*!
 Get the list of known experiment names
 */
- (NSArray *)allExperimentNames;


/**---------------------------------------------------------------------------------------
 * @name Deprecated Properties & Methods
 *  ---------------------------------------------------------------------------------------
 */

/*!
 By default, users are grouped into a cohort which will always see the same variation for an experiment.
 Switch on transitenVariations to have the users see all of the variations in their relative frequencies.  This is useful for
 debugging your variations and ensuring all of your codepaths are tested.
 
 @deprecated transientVariations are deprecated from 0.4.5 onwards.  Use Debug mode instead, as this includes 'shake to variation'.  Alternatively use Cohort modification.

 */

+ (void)setTransientVariations:(BOOL)transientVariations __attribute__((deprecated("transientVariations are deprecated from 0.4.5 onwards. Use Debug mode instead, as this includes 'shake to variation'.  Alternatively use Cohort modification.")));

/*!
 Sample rate applies experiments to a small proportion of your user base.  This is useful for managing your
 costs and keeping within your user allowance for your selected splitforce package. N.B.  This setting has
 no effect when transientVariations is set to YES so that you can test all code paths more easily.  Note also
 that you must set this parameter before initialising the manager connection, hence this is a class method.  Changing
 the value after the manager has been established will have no effect.

 The default value is 1.0 meaning 100% of your users will be tested.  Minimum value is 0.0, maximum
 value is 1.0.  Setting other values will raise an exception.

 @deprecated Sample Rate is deprecated from Version 0.4.  Use the Splitforce.com website to configure Experiment Coverage.

 */
+ (void)setSampleRate:(double)sampleRate __attribute__((deprecated("Sample Rate is deprecated from Version 0.4.  Use the Splitforce.com website to configure Experiment Coverage.")));


/*!
 Switching on debugMode will provide more detailed logs on the console and should be switched on for all DEBUG builds.

 @deprecated set Class Parameters before instantiating the SFManager instead of these properties
 */

@property (nonatomic) BOOL debugMode  __attribute__((deprecated("use class properties prior to instantiation instead")));


/*!
 By default, users are grouped into a cohort which will always see the same variation for an experiment.
 Switch on transitenVariations to have the users see all of the variations in their relative frequencies.  This is useful for
 debugging your variations and ensuring all of your codepaths are tested.

 @deprecated set Class Parameters before instantiating the SFManager instead of these properties
 */
@property (nonatomic) BOOL transientVariations __attribute__((deprecated("use class properties prior to instantiation instead")));


/*!
 By default, if an experiment is applied when there is no splitforce data available, then the error block
 is called, and users will see an 'unvaried' experiment - a.k.a the default implementation.  In future runs
 this will be replaced with the varied data once it is available.  Alternatively to ensure users always get
 the same implementation, se persistFailedExperiments to YES and users will continue to see the default
 implementation.  This only applies to the offline failures, experiments that fail due to the experiment being
 undefined at the time of application will not be persisted as failures once the experiment is added to the dataset.

 Note that this parameter is subordinate to transientVariations.  If transientVariations is set then the user will
 always see either new data if available, or default data if the connection is offline.
 
 @deprecated set Class Parameters before instantiating the SFManager instead of these properties
 */
@property (nonatomic) BOOL persistFailedExperiments __attribute__((deprecated("use class properties prior to instantiation instead")));

@end
