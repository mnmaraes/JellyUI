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

#pragma mark - Card Attributes
@property (nonatomic) NSUInteger count;

@end

@implementation JUIContainerViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addCardContainerView];
    [self addCardView];
    [self.view addSubview:[self topBarView]];
}

#pragma mark - Button Actions
-(void)showHiddenView
{

}

#pragma mark - View Transitions;
-(void)animateCardTransitionWithVelocity:(CGPoint)velocity
{
    UIView *newCardView = [self newCardView];
    [self.view addSubview:newCardView];
    newCardView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    [self.view bringSubviewToFront:self.cardContainerView];
    
    NSTimeInterval duration = -1. / velocity.y;
    duration = duration > .5 ? .5 : duration;
        
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
        
        [strongSelf.cardContainerView setContentOffset:CGPointZero animated:NO];
        [strongSelf.cardContainerView addSubview:newCardView];
        
        strongSelf.cardView = newCardView;
    }];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yTranslation = [scrollView contentOffset].y / 75.;
    yTranslation = yTranslation <= -1.0 ? -1.0 : yTranslation;
    if (yTranslation <= 0.) {
        self.cardView.transform = CGAffineTransformMakeRotation(-M_PI/16. * yTranslation);
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat yTranslation = [scrollView contentOffset].y;
    
    if (yTranslation < -75.0) {
        *targetContentOffset = scrollView.contentOffset;
        [self animateCardTransitionWithVelocity:velocity];
    }
}

#pragma mark - View Layout
-(void)addCardContainerView
{
    self.cardContainerView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.cardContainerView.delegate = self;
    self.cardContainerView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.cardContainerView];
}

-(UIView *)topBarView
{
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 20., 320., 44.)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Press Me" forState:UIControlStateNormal];
    button.frame = CGRectMake(20., 11., 70., 22.);
    [button addTarget:self action:@selector(showHiddenView) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:button];
    
    UILabel *label = [UILabel new];
    label.bounds = CGRectMake(0.0, 0.0, 60., 22.);
    label.center = CGPointMake(160., 22.);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Title";
    [topBar addSubview:label];
    
    return topBar;
}

-(void)addCardView
{
    self.cardView = [self newCardView];
    [self.cardContainerView addSubview:self.cardView];
}

-(UIView *)newCardView
{
    UIView *cardView = [UIView new];
    cardView.bounds = CGRectMake(0.0, 0.0, 240., 240.);
    cardView.center = self.view.center;
    cardView.backgroundColor = [UIColor blueColor];
    
    UILabel *cardLabel = [UILabel new];
    cardLabel.bounds = CGRectMake(0.0, 0.0, 80., 80.);
    cardLabel.center = CGPointMake(120., 120.);
    cardLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count++];
    cardLabel.textAlignment = NSTextAlignmentCenter;
    cardLabel.font = [UIFont systemFontOfSize:60.];
    cardLabel.textColor = [UIColor whiteColor];
    
    [cardView addSubview:cardLabel];
    
    return cardView;
}

@end
