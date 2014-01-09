//
//  SFMotionHandlerView.m
//  SplitPong
//
//  Created by Price Stephen on 17/12/2013.
//  Copyright (c) 2013 Ikura Group Ltd. All rights reserved.
//

#import "SFMotionHandlerView.h"

@interface SFMotionHandlerView()<UIActionSheetDelegate>

@end

@implementation SFMotionHandlerView {
    NSString *gamePhysicsVariation;
    NSMutableArray *variations;
    NSMutableDictionary *mapForcedCohorts;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - NOT FOR FINAL PROJECT, Import to Splitforce Library

- (void)setupExperimentData
{
    mapForcedCohorts = NSMutableDictionary.dictionary;
    NSDictionary *experimentData = [SFManager.currentManager performSelector:NSSelectorFromString(@"experimentData") withObject:nil];

    variations = NSMutableArray.array;
    for (NSString *key in experimentData.allKeys)
    {
        for (NSDictionary *variation in experimentData[key])
            if (variation[@"name"]) [variations addObject:@{key:variation[@"name"]}];
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (mapForcedCohorts == nil) [self setupExperimentData];

    if (event.type == UIEventSubtypeMotionShake)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Splitforce - Game Physics"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil otherButtonTitles:nil];
        for (NSDictionary *variation in variations) [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@: %@", variation.allKeys.firstObject, variation.allValues.firstObject]];
        [sheet addButtonWithTitle:@"Cancel"];
        sheet.cancelButtonIndex = variations.count;
        [sheet showInView:self.window];
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    //BOOM!
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) return;

    NSDictionary *chosenVariation = variations[buttonIndex];
    mapForcedCohorts[chosenVariation.allKeys.firstObject] = chosenVariation.allValues.firstObject;

    [SFManager setWillUseCohortIdentifierBlock:^NSDictionary *(NSDictionary *cohortIdentifier) {
        NSMutableDictionary *mutableCohortId = cohortIdentifier.mutableCopy;

        for (NSString *key in mapForcedCohorts)
        {
            mutableCohortId[key] = mapForcedCohorts[key];
        }
        return mutableCohortId;
    }];

#warning - this needs to change
    [SFManager restartWithCompletionBlock:^(BOOL success) {
                            if (self.variationDidChangeBlock) self.variationDidChangeBlock();
                        }];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
