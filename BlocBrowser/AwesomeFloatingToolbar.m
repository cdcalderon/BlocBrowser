//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Carlos Calderon on 10/22/15.
//  Copyright (c) 2015 Carlos Calderon. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) UIButton *currentButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initWIthFourTitles:(NSArray *)titles {
    self = [super init];
    
    if(self) {
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
    
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        NSUInteger tagIndex = 1;
        for(NSString *currentTitle in self.currentTitles){
            
            UIButton *button = [UIButton buttonWithType:
                                         UIButtonTypeRoundedRect];
            button.userInteractionEnabled = YES;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            [button setBackgroundColor: colorForThisButton];
           
            [button setTag:tagIndex];
            tagIndex++;
            [labelsArray addObject:button];
        }
        self.labels = labelsArray;
        
        for(UIButton *thisButton in self.labels){
            [self addSubview: thisButton];
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.tapGesture];
        
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer: self.longPressGesture];
        
//        self.userInteractionEnabled = TRUE;
    }
    return self;
    
}

- (void) layoutSubviews {
    
    for(UIButton *thisLabel in self.labels){
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        if(currentLabelIndex < 2){
            labelY = 0;
        } else {
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if( currentLabelIndex % 2 == 0){
            labelX = 0;
        } else {
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        
    }
}

- (void)tapFired:(UITapGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateRecognized){
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if([self.labels containsObject:tappedView]) {
            if([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]){
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)tappedView).titleLabel.text];
            }
        }
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]){
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateChanged){
        if(recognizer.scale > 1.0f && recognizer.scale < 3.0f){
            CGAffineTransform transform = CGAffineTransformMakeScale(recognizer.scale, recognizer.scale);
            [self.delegate floatingToolbar:self didTryToScaleWithTransform:transform];
        }
    }
    
}

- (void)longPressFired: (UILongPressGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateChanged || recognizer.state ==  UIGestureRecognizerStateBegan){
        for(int i = 1; i <= self.labels.count; i++){
            UIButton *button = (UIButton*)[self viewWithTag:i];
            UIColor *buttonNextColor;
            if(i < self.labels.count){
                UIButton *buttonNext = (UIButton*)[self viewWithTag:i + 1];
                buttonNextColor = [buttonNext backgroundColor];
            } else {
                UIButton *buttonNext = (UIButton*)[self viewWithTag:1];
                buttonNextColor = [buttonNext backgroundColor];
            }
            
            if([button isKindOfClass:[UIButton class]]){
                [button setBackgroundColor:buttonNextColor];
            }
        }
    }
}

//- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    
////    if([touch.view isKindOfClass:[UIControl class]]){
////        return YES;
////    }
////    return NO;
//}



#pragma mark - Touch Handling

- (UIButton *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if([subview isKindOfClass:[UIButton class]]) {
        return (UIButton *) subview;
    } else {
        return nil;
    }
}

#pragma mark - Button Enabling
- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if(index != NSNotFound){
        UIButton *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.5;
    }
}


@end
