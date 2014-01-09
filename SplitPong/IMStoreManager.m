//
//  IMStoreManager.m
//  SplitPong
//
//  Created by Price Stephen on 19/03/2013.
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


#import "IMStoreManager.h"
#import <StoreKit/StoreKit.h>
#import "KeychainItemWrapper.h"

static NSString *productInfo = nil;

@interface IMStoreManager()<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSArray *myProducts;
    IMStoreManagerObjectBlock productListBlock;
    IMStoreManagerBoolBlock restoreProductsBlock;
    IMStoreManagerObjectBlock purchaseProductBlock;
}

@end

@implementation IMStoreManager {
    BOOL _paymentsAreDisabled;
}

static IMStoreManager *sharedManager = nil;

+(IMStoreManager *)sharedManager
{
    if (sharedManager == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[IMStoreManager alloc] init];
            if ([SKPaymentQueue canMakePayments]) {
                [[SKPaymentQueue defaultQueue] addTransactionObserver:sharedManager];
            } else sharedManager->_paymentsAreDisabled = YES;

        });
    }

    return sharedManager;
}

- (BOOL)paymentsAreDisabled
{
    if (_paymentsAreDisabled == NO) return NO;
    if ([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:sharedManager];
        return _paymentsAreDisabled = NO;
    } else return _paymentsAreDisabled = YES;
}

- (NSArray *)products
{
    if (myProducts) return myProducts;
    return nil;
}

- (void)requestProductData
{
    if (myProducts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (productListBlock)
            {
                productListBlock(myProducts);
                productListBlock = nil;
            }
        });

        return;
    }

    NSSet *ids = kProductIdentifiers;
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:ids];
    request.delegate = self;
    [request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    myProducts = response.products;

    if (productListBlock)
    {
        productListBlock([myProducts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES]]]);
        productListBlock = nil;
    }
    // Populate your UI from the products list.
    // Save a reference to the products list.
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if ([request isKindOfClass:[SKProductsRequest class]]) {
        if (productListBlock) {productListBlock(nil); productListBlock = nil;}
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];

    if (transaction.payment)
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    if (purchaseProductBlock) {
        purchaseProductBlock(nil);
        purchaseProductBlock = nil;
    }
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordRestoreTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{

    UIAlertView *alert = nil;
    

    if (transaction.error.code != SKErrorPaymentCancelled) {
        // Optionally, display an error here.
        alert = [[UIAlertView alloc] initWithTitle:transaction.error.localizedDescription
                                   message:@"Please check your settings and try again"
                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    if (purchaseProductBlock) {
        purchaseProductBlock(transaction.error);
        purchaseProductBlock = nil;
    }

    [alert show];
}

- (void)purchaseProduct:(SKProduct *)selectedProduct
{
    SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if (self.didRecordTransaction) self.didRecordTransaction(transaction);
}

- (void)recordRestoreTransaction:(SKPaymentTransaction *)transaction
{
    if (self.didRestoreTransaction) self.didRestoreTransaction(transaction);
}

- (void)provideContent:(NSString *)productIdentifier
{
    NSString *keyData = [productIdentifier componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]].lastObject;

    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainID accessGroup:nil];

    NSString *currentProductData = [keychain objectForKey:(__bridge id)kSecValueData];
    if (currentProductData.length == 0) currentProductData = keyData; else if ([currentProductData rangeOfString:keyData].location == NSNotFound) currentProductData = [productIdentifier stringByAppendingFormat:@",%@", currentProductData];

    [keychain setObject:currentProductData forKey:(__bridge id)kSecValueData];
    
    productInfo = currentProductData;
}

#pragma mark - Abstraction Routines

// Calls the block with NSArray of SKProducts
- (void)getProductListArray:(IMStoreManagerObjectBlock)listRetrievedBlock
{
    NSLog(@"Retrieving proudct list array");
    if (productListBlock) return;
    
    productListBlock = [listRetrievedBlock copy];
    
    [self requestProductData];
}

// Calls the block with YES / NO depending on success of restore operation
- (void)restoreTransactionsWithCompletion:(IMStoreManagerBoolBlock)completion
{
    restoreProductsBlock = [completion copy];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (restoreProductsBlock) restoreProductsBlock(NO);
    restoreProductsBlock = nil;
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if (restoreProductsBlock) restoreProductsBlock(YES);
    restoreProductsBlock = nil;
}

// Calls the block with YES / NO depending on success of purchase operation
- (void)purchaseProduct:(id)product withCompletion:(IMStoreManagerObjectBlock)completion
{
    purchaseProductBlock = [completion copy];

    [self purchaseProduct:product];
}

// Tells the model whether the user has purchaed this particular product.
- (void)userHasPurchasedProductId:(NSString *)productId withCompletion:(IMStoreManagerBoolBlock)completion
{
    if (productInfo == nil)
    {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainID accessGroup:nil];

        productInfo = [keychain objectForKey:(__bridge id)kSecValueData];
    }

    NSString *keyData = [productId componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]].lastObject;

    BOOL purchased = [productInfo rangeOfString:keyData].location != NSNotFound;
    
    if (completion) completion(purchased);
}

- (void)clearAnyCachedKeychainItems
{
    productInfo = nil;
    
    [self clearPurchaseForKey:kKeychainID];

    for (NSString *productId in kProductIdentifiers) [self clearPurchaseForKey:[productId componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]].lastObject];
}

- (void)clearPurchaseForKey:(NSString *)productId
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:productId accessGroup:nil];

    [keychain resetKeychainItem];
    productInfo = nil;
}


@end
