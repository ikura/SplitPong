//
//  SFMotionHandlerView.h
//  SplitPong
//
//  Created by Price Stephen on 17/12/2013.
//  Copyright (c) 2013 Ikura Group Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SFMotionHandlerBlock)(void);

@interface SFMotionHandlerView : UIView

@property (nonatomic, copy) SFMotionHandlerBlock variationDidChangeBlock;

@end
