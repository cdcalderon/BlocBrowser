//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Carlos Calderon on 10/22/15.
//  Copyright (c) 2015 Carlos Calderon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToScaleWithTransform:(CGAffineTransform)transform;
@end

@interface AwesomeFloatingToolbar : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;
-(instancetype) initWIthFourTitles: (NSArray *) titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@end
