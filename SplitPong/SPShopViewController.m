//
//  SPShopViewController.m
//  SplitPong
//
//  Created by Price Stephen on 07/11/2013.
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

#import "SPShopViewController.h"
#import "IMStoreManager.h"
#import <StoreKit/StoreKit.h>

@interface SPShopViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIView *progressOverlay;

@end

@implementation SPShopViewController {
    BOOL playSounds;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [[SFManager currentManager] experimentNamed:@"ShopFront"
                            applyVariationBlock:^(SFVariation *variation) {
                                self.progressOverlay.hidden = YES;

                                // Configuration for 'Description'
                                NSString *description = variation.variationData[@"Description"];

                                // Configuration for 'PlayThumbnailSounds'
                                BOOL playThumbnailSounds = [variation.variationData[@"PlayThumbnailSounds"] boolValue];

                                // Configuration for 'ButtonText'
                                NSString *buttonText = variation.variationData[@"ButtonText"];

                                // Configuration for 'ButtonTextColor'
                                UIColor *buttonTextColor = [SFUtils colorFromHexString:variation.variationData[@"ButtonTextColor"]];


                                // Configure our UI with the data
                                [self.buyButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
                                [self.buyButton setTitle:buttonText forState:UIControlStateNormal];
                                self.descriptionLabel.text = description;
                                playSounds = playThumbnailSounds;

                            } applyDefaultBlock:^(NSError *error) {
                                self.progressOverlay.hidden = YES;

                                if (error) NSLog(@"Splitforce Error: %@", error);
                                ;
                            }];

    [[IMStoreManager sharedManager] userHasPurchasedProductId:kProductID
                                               withCompletion:^(BOOL response) {
                                                   self.buyButton.enabled = !response;
                                                   self.restoreButton.hidden = response;
                                               }];
}

- (IBAction)buyThemes:(id)sender {
    self.progressOverlay.hidden = NO;

    [[IMStoreManager sharedManager] getProductListArray:^(NSArray *products) {

        for (SKProduct *product in products)
        {
            if ([product.productIdentifier isEqualToString:kProductID])
            {
                [[IMStoreManager sharedManager] purchaseProduct:product
                                                                                                         withCompletion:^(id object) {
                                                                                                             self.progressOverlay.hidden = YES;

                                                                                                             if (object) [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                                                                         }];
                return;
            }
        }
        self.progressOverlay.hidden = YES;

        NSLog(@"Error, no matching products found");
    }];
}

- (IBAction)restoreThemes:(id)sender {
    self.progressOverlay.hidden = NO;

    [[IMStoreManager sharedManager] restoreTransactionsWithCompletion:^(BOOL response) {
        self.progressOverlay.hidden = YES;

        if (response) [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}
- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
