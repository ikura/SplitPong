//
//  SPPongScene.m
//  SplitPong
//
//  Created by Price Stephen on 01/10/2013.
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

#import "SPPongScene.h"
#import "SPGameParameters.h"
#import "SPThemeManager.h"
#import <AVFoundation/AVAudioPlayer.h>

/**
 TODO:
    1) Play sound when gain a life
    2) Parameterize starting number of lives & number of consecpoints for extra life
    3) Animate loss & gain of life
    4) Hide the ball for 1 second before repositioning and continuing
 */

@interface SPPongScene()<SKPhysicsContactDelegate>

@end

@implementation SPPongScene {
    SKNode *theBall;

    //    SKLabelNode *myScoreLabel;
    SKLabelNode *userScoreLabel;
    SKLabelNode *remainingLivesLabel;

    //    NSUInteger myScore;
    NSUInteger userScore;
    NSUInteger livesRemaining;
    NSUInteger userConsecutivePoints;

    NSUInteger currentTouches;
    NSUInteger totalPointsPlayed;
    NSDate *gameStartDate;

    // Time stamp of the last frame
    NSTimeInterval lastTime;

    BOOL startTheBall;
    BOOL oppositeDirection;
    BOOL ballOnHold;
    
    __weak UIViewController *owner;
}

static NSMutableDictionary *avPlayers;


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        CGFloat paddleInset = [kGameParams[kPaddleInsetKey] doubleValue];
        CGFloat scoreInset = [kGameParams[kScoreInsetKey] doubleValue];

        // Setup instance variables
        avPlayers = NSMutableDictionary.dictionary;
        userScore = 0;
        gameStartDate = NSDate.date;
        livesRemaining = 5;

        // Setup the Score Labels
        userScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Thin"];
        remainingLivesLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Thin"];
        userScoreLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - scoreInset*0.67, CGRectGetMaxY(self.frame) - scoreInset);
        remainingLivesLabel.position = CGPointMake(scoreInset*0.67, CGRectGetMaxY(self.frame) - scoreInset);
        [self updateLabels];

        // Setup the Ground Box
        SKShapeNode *groundBox = [SKShapeNode node];
        groundBox.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

        // Setup the Ball
        theBall = [[SPThemeManager.sharedManager classForBallNode] node];
        CGFloat ballSize = [kGameParams[kBallSizeKey] doubleValue];

        theBall.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        theBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ballSize/2.0];
        theBall.physicsBody.friction = 0.0;
        theBall.physicsBody.affectedByGravity = NO;
        theBall.physicsBody.velocity = [kGameParams[kBallInitialVelocityKey] vectorValue];
        theBall.physicsBody.restitution = [kGameParams[kBallRestitutionKey] doubleValue];
        theBall.physicsBody.linearDamping = 0.0;
        theBall.physicsBody.angularDamping = 0.0;
        theBall.physicsBody.usesPreciseCollisionDetection = YES;
        theBall.physicsBody.contactTestBitMask = 0xFFFFFFFF;

        // Geometry for Paddles, we use an ellipse for the paddle physics to create the behaviour of angled bounces
        CGRect paddleRect = centeredRect([kGameParams[kPaddleRectKey] CGRectValue]);
        CGPathRef paddlePhysicsPath = CFAutorelease(CGPathCreateWithEllipseInRect(paddleRect, NULL));

        // AI Paddle (maybe 2nd players paddle in two-player mode)
        aiPaddle = [[SPThemeManager.sharedManager classForPaddleNode] node];
        aiPaddle.position = CGPointMake(CGRectGetMidX(self.frame),
                                        CGRectGetMaxY(self.frame) - paddleInset - scoreInset);
        aiPaddle.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:paddlePhysicsPath];

        // User's Paddle (maybe 1st players paddle in two-player mode)
        usersPaddle = [[SPThemeManager.sharedManager classForPaddleNode] node];
        usersPaddle.position = CGPointMake(CGRectGetMidX(self.frame),
                                           paddleInset);
        usersPaddle.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:paddlePhysicsPath];
        usersPaddle.physicsBody.dynamic = NO;
        usersPaddle.alpha = 0.5;

        // Apply Theming
        [SPThemeManager.sharedManager applyThemeToBall:theBall withSize:ballSize];
        [SPThemeManager.sharedManager applyThemeToPaddle:aiPaddle withSize:paddleRect.size];
        [SPThemeManager.sharedManager applyThemeToPaddle:usersPaddle withSize:paddleRect.size];
        [SPThemeManager.sharedManager applyThemeToBackground:self];
        [self loopSoundAt:[[SPThemeManager sharedManager] pathForBackgroundMusic]];

        // Nice bloom effect for our nodes
        SKEffectNode *ballBloomEffect = [SKEffectNode node];
        ballBloomEffect.filter = [CIFilter filterWithName:@"CIBloom"];
        ballBloomEffect.shouldRasterize = YES;

        SKEffectNode *paddle1BloomEffect = [SKEffectNode node];
        paddle1BloomEffect.filter = [CIFilter filterWithName:@"CIBloom"];
        paddle1BloomEffect.shouldRasterize = YES;

        SKEffectNode *paddle2BloomEffect = [SKEffectNode node];
        paddle2BloomEffect.filter = [CIFilter filterWithName:@"CIBloom"];
        paddle2BloomEffect.shouldRasterize = YES;

        // Add everything to the Scene
        [self addChild:ballBloomEffect];
        [self addChild:paddle1BloomEffect];
        [self addChild:paddle2BloomEffect];
        [ballBloomEffect addChild:theBall];
        [paddle1BloomEffect addChild:aiPaddle];
        [paddle2BloomEffect addChild:usersPaddle];
        [self addChild:groundBox];
        [self addChild:userScoreLabel];
        [self addChild:remainingLivesLabel];

        // Start in paused mode until the user presses his paddle
        self.physicsWorld.speed = 0.0;
        self.physicsWorld.contactDelegate = self;
        usersPaddle.alpha = 0.5;
    }
    
    return self;
}


// Start a new game - serve in the correct direction
- (void)resetBall:(BOOL)oppositeDirection_
{
    theBall.physicsBody.velocity = CGVectorMake(0, 0);
    theBall.physicsBody.angularVelocity = 0.0;
    theBall.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    ballOnHold = YES;
    oppositeDirection = oppositeDirection_;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        startTheBall = YES;
    });
}

- (void)incrementUsersScore
{
    userScore++;
    userConsecutivePoints++;
    if (0 == (userConsecutivePoints % 5))
    {
        livesRemaining++;
    }
    totalPointsPlayed++;
    [self playSoundAt:[[SPThemeManager sharedManager] pathForScoreWinSound]];
    [self updateLabels];
}

- (void)decrementUsersScore
{
    livesRemaining--;
    userConsecutivePoints = 0;
    totalPointsPlayed++;
    userScoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)userScore];
    [self playSoundAt:[[SPThemeManager sharedManager] pathForScoreLostSound]];
    [self updateLabels];

    if (livesRemaining == 0) [self gameOver];
}

- (void)updateLabels
{
    userScoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)userScore];
    NSMutableString *livesString = [@"" mutableCopy];
    for (int i = 0; i< livesRemaining; i++)
    {
        [livesString appendString:@"•"];
    }
    remainingLivesLabel.text = livesString;
}

- (void)gameOver
{
    self.physicsWorld.speed = 0.0;
  /*
        Splitforce - Our goal is to see how changes in the game parameters affect the gameplay.  So first we grab the SFVariation object.
        Then we track:
            1. the total number of points played
            2. the duration of the game
        Elsewhere we will use the same variation object to track the length of time between each game (recency)
     */
    SFVariation *variation = [SFManager.currentManager variationForExperimentNamed:kGameParamsExperimentName];
    [variation quantifiedResultNamed:@"totalPointsPlayed" quantity:totalPointsPlayed];
    [variation timedResultNamed:@"gameLength" withTime:[NSDate.date timeIntervalSinceDate:gameStartDate]];

    [[UIAlertView alertViewWithTitle:@"Game Over"
                             message:@""
                               block:^(NSUInteger buttonIndex) {
                                   if (self.gameOverBlock)
                                       self.gameOverBlock();
                               }
                   cancelButtonTitle:@"Boo!"
                   otherButtonTitles:nil] show];
}

- (void)dealloc
{
    [self stopSounds];
}

#pragma mark - Touch Handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    currentTouches += touches.count;

    self.physicsWorld.speed = 1.0;
    usersPaddle.alpha = 1.0;

    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];

        usersPaddle.position = CGPointMake(location.x, usersPaddle.position.y);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];

        usersPaddle.position = CGPointMake(location.x, usersPaddle.position.y);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentTouches -=touches.count;
    if (currentTouches == 0) { self.physicsWorld.speed = 0.0; usersPaddle.alpha = 0.5; }
}

#pragma mark - AI Control
- (void)updateMyPaddle:(NSTimeInterval)timeInterval
{
    CGPoint myPosition = aiPaddle.position;
    CGPoint ballPosition = theBall.position;

    // Visibility is half the screen
    CGFloat proximity = (self.frame.size.height - fabs(ballPosition.y - myPosition.y)) / self.frame.size.height;

    CGFloat maxSpeed = 320.0;

    CGFloat speed = maxSpeed * proximity * timeInterval;
    speed *= [kGameParams[kAISpeedKey] doubleValue];

    CGFloat xdiff = ballPosition.x - myPosition.x;
    if (xdiff < 0.0) speed = -speed;

    // Velocity is 1/3rd the horizontal ball velocity
    if (fabs(xdiff) > fabs(speed)) xdiff = speed ;
    aiPaddle.position = CGPointMake(myPosition.x + xdiff, aiPaddle.position.y);
}

#pragma mark - Collision Detection
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    NSString *path = nil;
    if (contact.bodyA == aiPaddle.physicsBody)
    {
        path = [[SPThemeManager sharedManager] pathForPaddle1HitSound];
    }
    else if (contact.bodyA == usersPaddle.physicsBody)
    {
        path = [[SPThemeManager sharedManager] pathForPaddle2HitSound];
    }

    [self playSoundAt:path];
}


#pragma mark - Sound
- (void)playSoundAt:(NSString *)path
{
    if (path == nil) return;

    // Lazy on demand AVPlayer creation
    if (avPlayers[path] == nil)
    {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        if (player) avPlayers[path] = player;
    }

    AVAudioPlayer *player = avPlayers[path];
    if (player.playing) player.currentTime = 0.0;
    else [player play];
}

- (void)loopSoundAt:(NSString *)path
{
    if (path == nil) return;

    // Lazy on demand AVPlayer creation
    if (avPlayers[path] == nil)
    {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        if (player) avPlayers[path] = player;
        player.numberOfLoops = -1;
        [player play];
    }
}

- (void)stopSounds
{
    for (AVAudioPlayer *player in avPlayers.allValues) [player stop];
    [avPlayers removeAllObjects];
}

+ (void)prepareSounds
{
    NSArray *paths = @[
                       [[SPThemeManager sharedManager] pathForPaddle1HitSound],
                       [[SPThemeManager sharedManager] pathForPaddle2HitSound],
                       [[SPThemeManager sharedManager] pathForScoreWinSound],
                       [[SPThemeManager sharedManager] pathForScoreLostSound]
                       ];

    for (NSString *path in paths)
    {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        if (player) avPlayers[path] = player;
        [player prepareToPlay];
    }
}


#pragma mark - Game Logic
-(void)update:(NSTimeInterval)currentTime
{
    if (startTheBall)
    {
        startTheBall = NO;
        ballOnHold = NO;
        CGVector initialVelocity = [kGameParams[kBallInitialVelocityKey] vectorValue];
        if (oppositeDirection) initialVelocity.dy = -initialVelocity.dy;
        theBall.physicsBody.velocity = initialVelocity;
        return;
    }
    if (lastTime == 0.0) lastTime = currentTime - 1.0/60.0;
    [self updateMyPaddle:currentTime-lastTime];
    lastTime = currentTime;

    if (theBall.physicsBody.isDynamic)
    {
        CGVector ballVelocity = theBall.physicsBody.velocity;
        if (!ballOnHold && fabs(ballVelocity.dy) < 320.0)
        {
            CGVector impulse = CGVectorMake(0.0, ballVelocity.dy < 0.0 ? -1.0 : 1.0);
            [theBall.physicsBody applyImpulse:impulse];
        }

        if (theBall.position.y < usersPaddle.position.y)
        {
            //            [self incrementMyScore];
            [self decrementUsersScore];
            [self resetBall:NO];
        }
        else if (theBall.position.y > aiPaddle.position.y)
        {
            [self incrementUsersScore];
            [self resetBall:YES];
        }
    }
}

@end
