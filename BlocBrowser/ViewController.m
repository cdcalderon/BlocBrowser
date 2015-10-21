//
//  ViewController.m
//  BlocBrowser
//
//  Created by Carlos Calderon on 10/20/15.
//  Copyright (c) 2015 Carlos Calderon. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
 @end

@implementation ViewController

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    [self displayWelcomeAlert];
}

-(void)loadView {
    UIView *mainView = [UIView new];
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for the web URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled: NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back Command") forState:UIControlStateNormal];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward Command") forState:UIControlStateNormal];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop Command") forState:UIControlStateNormal];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload Command") forState:UIControlStateNormal];
    
    [self addBUttonTargets];
    
   
    for (UIView *viewToAdd in @[self.webView, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]){
        [mainView addSubview: viewToAdd];
    }
    
    self.view = mainView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButtonX = 0;
    
    for(UIButton *buttonToAdd in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]){
        buttonToAdd.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
    
}

- (void)resetWebView {
    [self.webView removeFromSuperview];
    WKWebView *newWebview = [[WKWebView alloc] init];
    newWebview.navigationDelegate = self;
    [self.view addSubview: newWebview];
    
    self.webView = newWebview;
    
    [self addBUttonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

- (void) addBUttonTargets {
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]){
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.backButton addTarget: self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget: self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget: self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget: self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *urlString = textField.text;
    NSArray *words = [urlString componentsSeparatedByString:@" "];
    NSArray *filteredWords = [words filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    NSURL *url = [NSURL URLWithString: urlString];
    
    if([filteredWords count] > 1){
        url = [NSURL URLWithString: [self constructGoogleUrl:filteredWords]];
    } else {
        if(!url.scheme){
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
        }
    }

    if(url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:request];
    }
    return NO;
}

#pragma mark - WKNavigationDelegate
- (void) webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void) webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code != NSURLErrorCancelled){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Error", @"Error")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    [self updateButtonsAndTitle];
}

- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

#pragma mark - Miscellaneous

- (void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webView.title copy];
    if([webpageTitle length]){
        self.title = webpageTitle;
    } else {
        self.title = self.webView.URL.absoluteString;
        
    }
    
    if(self.webView.isLoading){
        [self.activityIndicator startAnimating];

    } else {
        [self.activityIndicator stopAnimating];

    }
    
    self.backButton.enabled = [self.webView canGoForward];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    self.reloadButton.enabled = !self.webView.isLoading && self.webView.URL;
}

- (NSString *) constructGoogleUrl: (NSArray *) words{
    return [NSString stringWithFormat:@"http://google.com/search?q=%@", [words componentsJoinedByString:@"+"]];
}

- (void) displayWelcomeAlert {
    //Alert with OK dismiss
//    UIAlertController *welcomeAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BlocBrowser", @"Welcome message")
//                                                                          message:@"Welcome to Bloc Browser"
//                                                                   preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *infoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDestructive handler:nil];
//    
//    [welcomeAlert addAction:infoAction];
//    [self presentViewController:welcomeAlert animated:YES completion:nil];
    
    
    
    // dismiss alert after 2 seconds version
    welcomeAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Welcome to Bloc Browser" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [welcomeAlertView show];
    
    //Method Dismiss #1
    //[self performSelector:@selector(dismissAlertView) withObject:welcomeAlertView afterDelay:2.0f];
    
    //Method Dismiss #2 using NSTImer
    dismissAlertViewTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissAlertView) userInfo:nil repeats:NO];

}

//Function called only by imer to dismiss the alertview

- (void) dismissAlertView {
    [welcomeAlertView dismissWithClickedButtonIndex:-1 animated:YES];
}

// Alert View Delegate

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if(dismissAlertViewTimer != nil){
        [dismissAlertViewTimer invalidate];
        dismissAlertViewTimer = nil;
    }
}

@end
