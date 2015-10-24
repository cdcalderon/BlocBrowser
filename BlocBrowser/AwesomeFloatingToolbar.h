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

@end

@interface AwesomeFloatingToolbar : UIView

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

-(instancetype) initWIthFourTitles: (NSArray *) titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;


@end
