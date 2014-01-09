//
//  IMStoreManager.h
//  SplitPong
//
//  Created by Price Stephen on 19/03/2013.
//  Copyright (c) 2013 Ikura Group Ltd. All rights reserved.
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

#define kProductID @"com.splitforce.splitpong.unlockThemes"
#define kProductIdentifiers [NSSet setWithObjects:kProductID, nil]

#define kKeychainID @"com.splitforce.splitpong"

typedef void(^IMStoreManagerObjectBlock)(id object);
typedef void(^IMStoreManagerBoolBlock)(BOOL response);

@interface IMStoreManager : NSObject

+(IMStoreManager *)sharedManager;

@property (nonatomic, readonly) BOOL paymentsAreDisabled;

@property (nonatomic, copy) IMStoreManagerObjectBlock didRecordTransaction;
@property (nonatomic, copy) IMStoreManagerObjectBlock didRestoreTransaction;

// Store Block Functions

// Calls the block with NSArray of SKProducts
- (void)getProductListArray:(IMStoreManagerObjectBlock)listRetrievedBlock;

// Calls the block with YES / NO depending on success of restore operation
- (void)restoreTransactionsWithCompletion:(IMStoreManagerBoolBlock)completion;

// Calls the block with YES / NO depending on success of purchase operation
- (void)purchaseProduct:(id)product withCompletion:(IMStoreManagerObjectBlock)completion;

// Tells the model whether the user has purchaed this particular product.  The model should know only of the Product ID and not care about the contents of product
- (void)userHasPurchasedProductId:(NSString *)productId withCompletion:(IMStoreManagerBoolBlock)completion;

- (void)clearAnyCachedKeychainItems;

@end
