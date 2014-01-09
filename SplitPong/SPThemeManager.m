//
//  SPThemeManager.m
//  SplitPong
//
//  Created by Price Stephen on 28/10/2013.
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

#import "SPThemeManager.h"

static SPThemeManager *sharedManager;

@implementation SPThemeManager {
    NSString *theme;
}

+ (instancetype)sharedManager
{
    if (sharedManager) return sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SPThemeManager alloc] init];
    });

    sharedManager->theme = @"Vector";

    return sharedManager;
}

- (NSArray *)themeNames
{
    return @[@"Vector", @"Beach", @"Sketch", @"Ice"];
}

- (void)selectThemeNamed:(NSString *)themeName
{
    if ([self themeIsUnlocked:themeName]) theme = themeName;
}

- (BOOL)themeIsUnlocked:(NSString *)themeName
{
    return [[self themeNames] containsObject:themeName];
}

- (UIImage *)thumbnailForTheme:(NSString *)themeName
{
    return nil;
}

- (Class)classForBallNode
{
    return [theme isEqualToString:@"Vector"] ? SKShapeNode.class : SKSpriteNode.class;
}

- (Class)classForPaddleNode
{
    return [theme isEqualToString:@"Vector"] ? SKShapeNode.class : SKSpriteNode.class;
}

- (void)applyThemeToBall:(SKNode *)ballNode withSize:(CGFloat)ballSize
{
    if ([self classForBallNode] == SKShapeNode.class)
    {
        SKShapeNode *ball = (id)ballNode;
        ball.fillColor = UIColor.whiteColor;
        ball.lineWidth = 0.0;
        ball.path = CFAutorelease(CGPathCreateWithEllipseInRect(CGRectMake(ballSize/-2.0, ballSize/-2.0, ballSize, ballSize), NULL));
    }

    if ([self classForBallNode] == SKSpriteNode.class)
    {
        
        SKSpriteNode *ball = (id)ballNode;
        if ([theme isEqualToString:@"Ice"]) ball.texture = [SKTexture textureWithImageNamed:@"splitpong ball"];
        else if ([theme isEqualToString:@"Beach"]) ball.texture = [SKTexture textureWithImageNamed:@"beachBall"];
        else ball.texture = [SKTexture textureWithImageNamed:@"ballImage"];
        ball.size = CGSizeMake(ballSize, ballSize);
    }
}

- (void)applyThemeToPaddle:(SKNode *)paddleNode withSize:(CGSize)size
{
    if ([self classForPaddleNode] == SKShapeNode.class)
    {
        SKShapeNode *paddle = (id)paddleNode;
        paddle.fillColor = UIColor.whiteColor;
        paddle.lineWidth = 0.0;
        CGRect paddleRect = centeredRect(CGRectMake(0, 0, size.width, size.height));
        CGPathRef paddleShapePath = CFAutorelease(CGPathCreateWithRect(paddleRect, NULL));
        paddle.path = paddleShapePath;
    }

    if ([self classForPaddleNode] == SKSpriteNode.class)
    {
        SKSpriteNode *paddle = (id)paddleNode;
        if ([theme isEqualToString:@"Ice"]) paddle.texture = [SKTexture textureWithImageNamed:@"splitpong paddle"];
        else if ([theme isEqualToString:@"Beach"]) paddle.texture = [SKTexture textureWithImageNamed:@"beachPaddle"];
        else paddle.texture = [SKTexture textureWithImageNamed:@"paddleImage"];
        paddle.size = size;
    }
}

// Convenience method to create a rectangle centered at it's center
CGRect centeredRect(CGRect rect)
{
    return CGRectMake(rect.origin.x + rect.size.width / -2.0,
                      rect.origin.y + rect.size.height / -2.0,
                      rect.size.width,
                      rect.size.height);
}

- (void)applyThemeToBackground:(SKScene *)backgroundView
{
    if ([theme isEqualToString:@"Sketch"])
    {
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        background.size = backgroundView.frame.size;
        background.position = CGPointMake(background.size.width / 2.0, background.size.height / 2.0);
        [backgroundView addChild:background];
    } else if ([theme isEqualToString:@"Ice"])
    {
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"ice background"];
        background.size = backgroundView.frame.size;
        background.position = CGPointMake(background.size.width / 2.0, background.size.height / 2.0);
        [backgroundView addChild:background];
    } else if ([theme isEqualToString:@"Beach"])
    {
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"beachBackground"];
        background.size = backgroundView.frame.size;
        background.position = CGPointMake(background.size.width / 2.0, background.size.height / 2.0);
        [backgroundView addChild:background];
    }
        backgroundView.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
}

- (NSString *)pathForPaddle1HitSound;
{
    if ([theme isEqualToString:@"Beach"]) return [[NSBundle mainBundle] pathForResource:@"beachBounce" ofType:@"caf"];
    return [[NSBundle mainBundle] pathForResource:@"MY SHOT" ofType:@"caf"];
    return nil;
}

- (NSString *)pathForPaddle2HitSound;
{
    if ([theme isEqualToString:@"Beach"]) return [[NSBundle mainBundle] pathForResource:@"beachBounce" ofType:@"caf"];
    return [[NSBundle mainBundle] pathForResource:@"HIS SHOT" ofType:@"caf"];
    return nil;
}

- (NSString *)pathForBackgroundMusic
{
    if ([theme isEqualToString:@"Beach"]) return [[NSBundle mainBundle] pathForResource:@"beach" ofType:@"caf"];
    if ([theme isEqualToString:@"Vector"]) return [[NSBundle mainBundle] pathForResource:@"dark" ofType:@"m4a"];

    return nil;
}

- (NSString *)pathForScoreWinSound
{
    return [[NSBundle mainBundle] pathForResource:@"WIN" ofType:@"caf"];
    return nil;
}

- (NSString *)pathForScoreLostSound
{
    return [[NSBundle mainBundle] pathForResource:@"LOSE" ofType:@"caf"];
    return nil;
}

@end
