//
//  JUIContainerViewController.m
//  JellyUI
//
//  Created by Murillo Nicacio de Maraes on 3/4/14.
//  Copyright (c) 2014 m-one. All rights reserved.
//

#import "JUIContainerViewController.h"

@interface JUIContainerViewController () <UIScrollViewDelegate>
#pragma mark - Views
@property (nonatomic) UIScrollView *cardContainerView;
@property (nonatomic) UIView *cardView;
@property (nonatomic) UIView *hiddenView;
@property (nonatomic) UIView *topBarView;
@property (nonatomic) UILabel *defaultTitle;
@property (nonatomic) UILabel *hiddenTitle;

#pragma mark - Card Attributes
@property (nonatomic) NSUInteger count;

#pragma mark - Animation Attributes
@property (nonatomic) CGFloat deltaX;

#pragma mark - Status Attributes
@property (nonatomic) BOOL displayingHiddenView;

@end

@implementation JUIContainerViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addCardContainerView];
    [self addCardView];
    [self addTopBarView];
    
    self.hiddenView = [self newHiddenView];
}

#pragma mark - Button Actions
-(void)toggleHiddenView
{
    if (self.displayingHiddenView) {
        [self hideHiddenView];
    } else {
        [self displayHiddenView];
    }
    self.displayingHiddenView = !self.displayingHiddenView;
}

#pragma mark - View Transitions;

-(void)hideHiddenView
{
    [self.topBarView addSubview:self.defaultTitle];
    
    __weak JUIContainerViewController *weakSelf = self;
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:.5 options:UIViewAnimationOptionTransitionNone animations:^{
        JUIContainerViewController *strongSelf = weakSelf;
        
        strongSelf.hiddenView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        strongSelf.hiddenView.center = CGPointMake(45., kTopBarViewHeight + kStatusBarHeight);
        
        CGPoint centerSwap = strongSelf.hiddenTitle.center;
        strongSelf.hiddenTitle.center = strongSelf.defaultTitle.center;
        strongSelf.defaultTitle.center = centerSwap;
        
    } completion:^(BOOL finished) {
        JUIContainerViewController *strongSelf = weakSelf;
        
        [strongSelf.hiddenView removeFromSuperview];
        [strongSelf.hiddenTitle removeFromSuperview];
    }];
}

-(void)displayHiddenView
{
    self.hiddenView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [self.view addSubview:self.hiddenView];
    [self.topBarView addSubview:self.hiddenTitle];
    
    __weak JUIContainerViewController *weakSelf = self;
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:.5 options:UIViewAnimationOptionTransitionNone animations:^{
        JUIContainerViewController *strongSelf = weakSelf;
        
        strongSelf.hiddenView.transform = CGAffineTransformIdentity;
        strongSelf.hiddenView.center = CGPointMake(strongSelf.view.center.x, strongSelf.view.center.y + (kStatusBarHeight + kTopBarViewHeight)/2.);
        
        CGPoint centerSwap = strongSelf.hiddenTitle.center;
        strongSelf.hiddenTitle.center = strongSelf.defaultTitle.center;
        strongSelf.defaultTitle.center = centerSwap;
        
    } completion:^(BOOL finished) {
        JUIContainerViewController *strongSelf = weakSelf;
        
        [strongSelf.defaultTitle removeFromSuperview];
    }];
}

static NSTimeInterval kCardAnimationMaximumDuration = 0.5;

-(void)animateCardTransitionWithVelocity:(CGPoint)velocity
{
    self.cardContainerView.userInteractionEnabled = NO;
    
    UIView *newCardView = [self newCardView];
    [self.view addSubview:newCardView];
    newCardView.center = self.view.center;
    newCardView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    [self.view bringSubviewToFront:self.cardContainerView];
    
    NSTimeInterval duration = - 2 * kCardAnimationMaximumDuration / velocity.y;
    duration = duration > kCardAnimationMaximumDuration ? kCardAnimationMaximumDuration : duration;
        
    CGFloat finalY = CGRectGetMaxY(self.view.frame) + CGRectGetHeight(self.cardView.frame);
    
    __weak JUIContainerViewController *weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        JUIContainerViewController *strongSelf = weakSelf;
        
        newCardView.transform = CGAffineTransformIdentity;
        strongSelf.cardView.center = CGPointMake(strongSelf.cardView.center.x, finalY);
    } completion:^(BOOL finished) {
        JUIContainerViewController *strongSelf = weakSelf;
        
        [strongSelf.cardView removeFromSuperview];
        [newCardView removeFromSuperview];
        
        newCardView.center = CGPointMake(kCardViewSideLength/2., kCardViewSideLength/2.);
        [strongSelf.cardContainerView setContentOffset:CGPointZero animated:NO];
        [strongSelf.cardContainerView addSubview:newCardView];
        
        strongSelf.cardView = newCardView;
        strongSelf.cardContainerView.userInteractionEnabled = YES;
    }];
}

#pragma mark - UIScrollViewDelegate

static CGFloat kCardContainerScrollViewPointOfTransition = -75.;

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIPanGestureRecognizer *gestureRecognizer = scrollView.panGestureRecognizer;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.deltaX = 2 * ([scrollView.panGestureRecognizer locationInView:scrollView].x - kCardViewSideLength/2.) / kCardViewSideLength;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.deltaX = 0.;
    }
    
    
    CGFloat yTranslation = [scrollView contentOffset].y / kCardContainerScrollViewPointOfTransition;
    yTranslation = yTranslation >= 1.0 ? 1.0 : yTranslation;
    
    if (yTranslation >= 0.) {
        self.cardView.transform = CGAffineTransformMakeRotation(M_PI/8. * yTranslation * self.deltaX);
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat yTranslation = [scrollView contentOffset].y;
    
    if (yTranslation < kCardContainerScrollViewPointOfTransition) {
        *targetContentOffset = scrollView.contentOffset;
        [self animateCardTransitionWithVelocity:velocity];
    } else {
        scrollView.userInteractionEnabled = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled = YES;
}

#pragma mark - View Layout

static CGFloat kTopBarViewHeight = 44.;
static CGFloat kStatusBarHeight = 20.;

-(void)addCardContainerView
{
    self.cardContainerView = [UIScrollView new];
    self.cardContainerView.bounds = CGRectMake(0.0, 0.0, kCardViewSideLength, kCardViewSideLength);
    self.cardContainerView.center = self.view.center;
    self.cardContainerView.clipsToBounds = NO;
    self.cardContainerView.delegate = self;
    self.cardContainerView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.cardContainerView];
}

-(void)addTopBarView
{
    self.topBarView = [self newTopBarView];
    [self.view addSubview:self.topBarView];
}

-(UIView *)newTopBarView
{
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, kStatusBarHeight, 320., kTopBarViewHeight)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Press Me" forState:UIControlStateNormal];
    button.frame = CGRectMake(20., 11., 70., 22.);
    [button addTarget:self action:@selector(toggleHiddenView) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:button];
    
    UILabel *label = [UILabel new];
    label.bounds = CGRectMake(0.0, 0.0, 60., 22.);
    label.center = CGPointMake(160., kTopBarViewHeight/2.);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Title";
    [topBar addSubview:label];
    self.defaultTitle = label;
    
    label = [UILabel new];
    label.bounds = CGRectMake(0.0, 0.0, 80., 22.);
    label.center = CGPointMake(160., -kTopBarViewHeight);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Other Title";
    self.hiddenTitle = label;
    
    return topBar;
}

-(UIView *)newHiddenView
{
    UIView *hiddenView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kTopBarViewHeight + kStatusBarHeight, 320, CGRectGetHeight(self.view.frame) - kTopBarViewHeight - kStatusBarHeight)];
    hiddenView.backgroundColor = [UIColor greenColor];
    hiddenView.center = CGPointMake(45., kTopBarViewHeight + kStatusBarHeight);
    
    return hiddenView;
}

-(void)addCardView
{
    self.cardView = [self newCardView];
    [self.cardContainerView addSubview:self.cardView];
}

static CGFloat kCardViewSideLength = 280.;

-(UIView *)newCardView
{
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kCardViewSideLength, kCardViewSideLength)];
    cardView.backgroundColor = [UIColor blueColor];
    
    UILabel *cardLabel = [UILabel new];
    cardLabel.bounds = CGRectMake(0.0, 0.0, kCardViewSideLength, 80.);
    cardLabel.center = CGPointMake(kCardViewSideLength/2., kCardViewSideLength/2.);
    cardLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count++];
    cardLabel.textAlignment = NSTextAlignmentCenter;
    cardLabel.font = [UIFont systemFontOfSize:60.];
    cardLabel.textColor = [UIColor whiteColor];
    
    [cardView addSubview:cardLabel];
    
    return cardView;
}

@end
