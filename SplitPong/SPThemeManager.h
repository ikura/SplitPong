//
//  SPThemeManager.h
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

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface SPThemeManager : NSObject

+ (instancetype) sharedManager;

- (NSArray *)themeNames;
- (void)selectThemeNamed:(NSString *)themeName;
- (BOOL)themeIsUnlocked:(NSString *)themeName;
- (UIImage *)thumbnailForTheme:(NSString *)themeName;

- (Class)classForBallNode;
- (Class)classForPaddleNode;
- (void)applyThemeToBall:(SKNode *)ballNode withSize:(CGFloat)ballSize;
- (void)applyThemeToPaddle:(SKNode *)paddleNode withSize:(CGSize)size;
- (void)applyThemeToBackground:(SKScene *)backgroundView;

- (NSString *)pathForPaddle1HitSound;
- (NSString *)pathForPaddle2HitSound;
- (NSString *)pathForBackgroundMusic;
- (NSString *)pathForScoreWinSound;
- (NSString *)pathForScoreLostSound;

@end

CGRect centeredRect(CGRect rect);
