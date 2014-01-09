//
//  UIAlertView+IMBlocks.m
//  SplitPong
//
//  Created by Stephen Price on 16/08/2013.
//  Copyright (c) 2013 ikuramedia.com. All rights reserved.
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

#import "UIAlertView+IMBlocks.h"
#import <objc/runtime.h>

@interface IMBlocksUIAlertViewDelegate : NSObject<UIAlertViewDelegate>

@property (nonatomic, copy) UIAlertViewBlock didDismissBlock;

@end

@implementation IMBlocksUIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.didDismissBlock) self.didDismissBlock(buttonIndex);
}

- (void)dealloc
{
    NSLog(@"%@ dealloced", self);
}

@end

@implementation UIAlertView (IMBlocks)

+ (UIAlertView *)alertViewWithTitle:(NSString *)title
                            message:(NSString *)message
                              block:(UIAlertViewBlock)didDismissBlock
                  cancelButtonTitle:(NSString *)cancelButtonTitle
                  otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;
{
    IMBlocksUIAlertViewDelegate *delegate = [[IMBlocksUIAlertViewDelegate alloc] init];
    delegate.didDismissBlock = didDismissBlock;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];
    const void *key;
    objc_setAssociatedObject(alertView, &key, delegate, OBJC_ASSOCIATION_RETAIN);
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
    {
        [alertView addButtonWithTitle:arg];
    }
    va_end(args);
    return alertView;
}

- (void)dealloc
{
    objc_removeAssociatedObjects(self);
}

@end
