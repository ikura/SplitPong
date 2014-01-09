//
//  SPGameParameters.m
//  SplitPong
//
//  Created by Price Stephen on 02/10/2013.
//  Copyright (c) 2013 Ikura Group Ltd. All rights reserved.
//
/*
 Disclaimer: IMPORTANT:  This ikuramedia software is supplied to you by Ikura Group
 Ltd. ("ikuramedia") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this ikuramedia software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this ikuramedia software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, ikuramedia grants you a personal, non-exclusive
 license, under ikuramedia's copyrights in this original ikuramedia software (the
 "Ikuramedia Software"), to use, reproduce, modify and redistribute the Ikuramedia
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Ikuramedia Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Ikuramedia Software.
 Neither the name, trademarks, service marks or logos of Ikura Group Ltd may
 be used to endorse or promote products derived from the Ikuramedia Software
 without specific prior written permission from ikuramedia.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by ikuramedia herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Ikuramedia Software may be incorporated.

 The Ikuramedia Software is provided by ikuramedia on an "AS IS" basis.  IKURAMEDIA
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE IKURAMEDIA SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL IKURAMEDIA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE IKURAMEDIA SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF IKURAMEDIA HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPGameParameters.h"
#import <Splitforce/SFKit.h>

const NSString *kPaddleInsetKey = @"paddleInset";
const NSString *kScoreInsetKey = @"scoreInset";
const NSString *kBallInitialVelocityKey = @"ballInitialVelocity";
const NSString *kBallRestitutionKey = @"ballRestitution";
const NSString *kPaddleRestitutionKey = @"paddleRestitution";
const NSString *kPaddleRectKey = @"paddleRect";
const NSString *kBallSizeKey = @"ballSize";
const NSString *kCohortIdKey = @"cohortId";
const NSString *kAISpeedKey = @"aiSpeed";

@implementation SPGameParameters {
    NSMutableArray *blocks;
    NSMutableDictionary *internalDictionary;
}


#pragma mark - Keyed Subscripting Support

- (id)objectForKeyedSubscript:(id)key;
{
    return internalDictionary[key];
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;
{
    if (internalDictionary == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            internalDictionary = NSMutableDictionary.dictionary;
        });
    }

    if (object) internalDictionary[key] = object;
}

#pragma mark - Asynchronous Loading

- (void)executeWhenLoaded:(void (^)(void))block
{
    if ([self dataLoaded]) {
        block();
        return;
    }

    if (blocks == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            blocks = NSMutableArray.array;
        });
    }

    [blocks addObject:block];
}

- (void)purgePendingBlocks
{
    for (id block in blocks) [self executeWhenLoaded:block];
    blocks = nil;
}

static BOOL dataLoaded;
- (BOOL)dataLoaded
{
    return dataLoaded;
}

- (void)finishedLoading
{
    dataLoaded = YES;
    [self purgePendingBlocks];
    [self setupParams];
}

#pragma mark - Hook into the Background / Foreground Notificaitons

+ (void)load
{
    [super load];

    [[NSNotificationCenter defaultCenter] addObserver:[self gameParameters]
                                             selector:@selector(appEnteredBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[self gameParameters]
                                             selector:@selector(appEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                            object:nil];
}

- (void)appEnteredBackground:(NSNotification*)note
{
    SFVariation *variant = [SFManager.currentManager variationForExperimentNamed:kGameParamsExperimentName];
    [variant timedResultNamed:@"sessionLength"];
}

- (void)appEnteredForeground:(NSNotification *)note
{
    [self setupParams]; // This causes the experiment to start again, logging a new value of time
}

#pragma mark - Splitforce: Get our GamePhysics experiment

- (void)setupParams
{
    [SFManager.currentManager experimentNamed:kGameParamsExperimentName
                          applyVariationBlock:^(SFVariation *variation) {
                              // Configuration for ballInitialVelocity
                              NSNumber *ballInitialVelocity = variation.variationData[@"ballInitialVelocity"];

                              // Configuration for paddleWidth
                              NSNumber *paddleWidth = variation.variationData[@"paddleWidth"];

                              // Configuration for paddleHeight
                              NSNumber *paddleHeight = variation.variationData[@"paddleHeight"];

                              // Configuration for ballSize
                              NSNumber *ballSize = variation.variationData[@"ballSize"];

                              // Configuration for aiSpeed
                              NSNumber *aiSpeed = variation.variationData[@"aiSpeed"];

                              self[kBallInitialVelocityKey] = [NSValue valueWithCGVector:CGVectorMake(0,ballInitialVelocity.doubleValue)];
                              self[kPaddleRectKey] = [NSValue valueWithCGRect:CGRectMake(0, 0, paddleWidth.doubleValue, paddleHeight.doubleValue)];
                              self[kBallSizeKey] = ballSize;
                              self[kAISpeedKey] = aiSpeed;
                              [self trackRecencyGoal];
                              
                          } applyDefaultBlock:^(NSError *error) {
                              // The instance configures the default values so there is nothing to do here except track the user's recency
                              [self trackRecencyGoal];
                          }];
}

#pragma mark - Track Recency of Visit

- (void)trackRecencyGoal
{
    NSString *defaultsKey = @"com.splitforce.splitpongLastLaunched";
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDate *lastLaunched = [defaults objectForKey:defaultsKey];

    if (lastLaunched)
    {
        NSTimeInterval timeSinceLastLaunch = [NSDate.date timeIntervalSinceDate:lastLaunched];
        SFVariation *variation = [SFManager.currentManager variationForExperimentNamed:kGameParamsExperimentName];
        [variation timedResultNamed:@"Recency" withTime:timeSinceLastLaunch];
    }

    [defaults setObject:NSDate.date forKey:defaultsKey];
    [defaults synchronize];
}

#pragma mark - Loose singleton

static SPGameParameters * sharedParams = nil;

+ (instancetype) gameParameters
{
    if (sharedParams) return sharedParams;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedParams = [[SPGameParameters alloc] init];
    });
    return (id)sharedParams;
}

- (id)init
{
    self = [super init];
    if (self) {
        self[kPaddleInsetKey] = @60.0;
        self[kScoreInsetKey] = @60.0;
        self[kBallInitialVelocityKey] = [NSValue valueWithCGVector:CGVectorMake(0,750)];
        self[kBallRestitutionKey] = @1.0;
        self[kPaddleRestitutionKey] = @1.0;
        self[kPaddleRectKey] = [NSValue valueWithCGRect:CGRectMake(0, 0, 120.0, 20.0)];
        self[kBallSizeKey] = @15.0;
        self[kAISpeedKey] = @1.0;
    }
    return self;
}

@end

#pragma mark - NSValue CGVector Category

@implementation NSValue(IMCGVectorAdditions)

+ (NSValue *)valueWithCGVector:(CGVector)vector;
{
    CGSize vectorAsSize = CGSizeMake(vector.dx, vector.dy);
    return [self valueWithCGSize:vectorAsSize];
}

- (CGVector)vectorValue;
{
    CGSize vectorAsSize = [self CGSizeValue];
    return CGVectorMake(vectorAsSize.width, vectorAsSize.height);
}

@end