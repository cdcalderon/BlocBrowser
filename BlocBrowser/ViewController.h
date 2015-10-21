//
//  ViewController.h
//  BlocBrowser
//
//  Created by Carlos Calderon on 10/20/15.
//  Copyright (c) 2015 Carlos Calderon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIAlertViewDelegate> {
    NSTimer *dismissAlertViewTimer;
    UIAlertView *welcomeAlertView;
}

- (void) resetWebView;

@end

