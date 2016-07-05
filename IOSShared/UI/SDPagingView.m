//
//  SDPagingView.m
//  Photos
//
//  Created by Brandon Sneed on 5/10/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDPagingView.h"

@implementation SDPagingView
{
    UIScrollView *_scrollView;
    NSInteger _currentPage;
    NSInteger _totalCount;
    
    UIView *_leftView;
    UIView *_centerView;
    UIView *_rightView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self _initialize];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self _initialize];
    return self;
}

- (void)_initialize
{
    _currentPage = NSIntegerMax;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.multipleTouchEnabled = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.delaysContentTouches = YES;
    _scrollView.clipsToBounds = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.bounces = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.scrollsToTop = NO;
    
    [self addSubview:_scrollView];
    
    self.spaceBetweenPages = 20;
}

- (void)setDataSource:(__strong id<SDPagingViewDataSource>)dataSource
{
    if (!dataSource)
        _dataSource = nil;
    
    // nice, saves us from doing respondsToSelector all over the place.
    if (self.dataSource != dataSource && [dataSource conformsToProtocol:@protocol(SDPagingViewDataSource)])
    {
        _dataSource = dataSource;
    }
}

- (void)setSpaceBetweenPages:(CGFloat)spaceBetweenPages
{
    if (_spaceBetweenPages == spaceBetweenPages)
        return;
        
    _spaceBetweenPages = spaceBetweenPages;
    
    CGRect scrollViewFrame = self.bounds;
    scrollViewFrame.origin.x -= _spaceBetweenPages / 2;
    scrollViewFrame.size.width += spaceBetweenPages;
    _scrollView.frame = CGRectIntegral(scrollViewFrame);
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalCount, _scrollView.frame.size.height);
    
    [self layoutViewsForPage:_currentPage];
}

- (NSInteger)currentPage
{
    return _currentPage;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated
{
    if (currentPage >= 0 && currentPage < _totalCount)
    {
        _currentPage = currentPage;
        
        CGRect rect = CGRectIntegral(CGRectMake(_scrollView.frame.size.width * _currentPage, 0, _scrollView.frame.size.width, _scrollView.frame.size.height));
        [_scrollView scrollRectToVisible:rect animated:animated];
        if (!animated)
            [self layoutViewsForPage:self.currentPage];
    }
}

- (void)reloadData
{
    __strong id<SDPagingViewDataSource> dataSource = self.dataSource;
    if (!dataSource)
        return;
    
    _currentPage = NSIntegerMax;
    
    _totalCount = [dataSource numberOfViewsInPagingView:self];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalCount, _scrollView.frame.size.height);
    
    _leftView = [dataSource viewForPagingView:self];
    _centerView = [dataSource viewForPagingView:self];
    _rightView = [dataSource viewForPagingView:self];
    
    [_scrollView addSubview:_leftView];
    [_scrollView addSubview:_centerView];
    [_scrollView addSubview:_rightView];

    [self layoutSubviews];
}

#pragma mark - Layout

- (void)layoutViewsForPage:(NSInteger)page
{
    __strong id<SDPagingViewDataSource> dataSource = self.dataSource;

    UIView *oldCenter = _centerView;
    UIView *oldRight = _rightView;
    UIView *oldLeft = _leftView;
    
    BOOL centerChanged = YES;
    
    if (_currentPage < page)
    {
        _centerView = oldRight;
        _leftView = oldCenter;
        _rightView = oldLeft;
    }
    else
    if (_currentPage > page)
    {
        _centerView = oldLeft;
        _leftView = oldRight;
        _rightView = oldCenter;
    }
    else
    {
        centerChanged = NO;
    }
    
    _currentPage = page;
    
    CGFloat halfSpace = _spaceBetweenPages / 2;
    CGFloat fullSpace = _spaceBetweenPages;
    
    // the visible view
    [dataSource pagingView:self updateView:_centerView atIndex:_currentPage];
    _centerView.frame = CGRectIntegral(CGRectMake(_scrollView.contentOffset.x + halfSpace, 0, _scrollView.frame.size.width - fullSpace, _scrollView.frame.size.height));
    
    // its the one in the center.  notify the delegate.
    if (centerChanged && [dataSource respondsToSelector:@selector(pagingView:viewBecameCenter:atIndex:)])
        [dataSource pagingView:self viewBecameCenter:_centerView atIndex:_currentPage];
    
    // the view to the right
    if (page + 1 < _totalCount)
    {
        [dataSource pagingView:self updateView:_rightView atIndex:_currentPage + 1];
        _rightView.frame = CGRectIntegral(CGRectMake((_scrollView.contentOffset.x + _scrollView.frame.size.width) + halfSpace, 0, _scrollView.frame.size.width - fullSpace, _scrollView.frame.size.height));
        _rightView.hidden = NO;
    }
    else
    {
        _rightView.hidden = YES;
    }
    
    // the view to the left
    if (page - 1 >= 0)
    {
        [dataSource pagingView:self updateView:_leftView atIndex:_currentPage - 1];
        _leftView.frame = CGRectIntegral(CGRectMake((_scrollView.contentOffset.x - _scrollView.frame.size.width) + halfSpace, 0, _scrollView.frame.size.width - fullSpace, _scrollView.frame.size.height));
        _leftView.hidden = NO;
    }
    else
    {
        _leftView.hidden = YES;
    }
    
    [_scrollView bringSubviewToFront:_centerView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat pageWidth = _scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page == _currentPage)
        return;

    [self layoutViewsForPage:page];
}

#pragma mark - Scrollview delegates

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self layoutSubviews];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self layoutViewsForPage:self.currentPage];
}

@end
