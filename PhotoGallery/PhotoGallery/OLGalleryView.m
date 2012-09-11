//
//  OLGalleryView.m
//  PhotoGallery
//
//  Created by Laurentiu on 11/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

#import "OLGalleryView.h"

#define ELEMENT_WIDTH 180


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OLGalleryView()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mediaHolder;
@property (nonatomic, strong) NSMutableArray *visibleViewsArray;
@property (nonatomic, strong) UIView *scrollHolder;

@property NSInteger numberOfItems;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OLGalleryView


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame andDelegate:(id<OLGalleryDelegate>)delegate
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self setDelegate:delegate];
    [self initializeHolders];
    [self loadData];
  }
  
  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeHolders
{
  NSInteger scrollViewHeight = 150;
  NSInteger mediaHolderHeight = self.frame.size.height - scrollViewHeight;
  NSInteger holdersWidth = self.frame.size.width;
  
  self.scrollView = [[UIScrollView alloc] init];
  self.mediaHolder = [[UIView alloc] init];
  
  [_scrollView setFrame:CGRectMake(0, mediaHolderHeight, holdersWidth, scrollViewHeight)];
  [_mediaHolder setFrame:CGRectMake(0, 0, holdersWidth, mediaHolderHeight)];
  
  [_mediaHolder setBackgroundColor:[UIColor yellowColor]];
  [_scrollView setBackgroundColor:[UIColor blueColor]];
  
  [self setupScrollView];
  
  [self addSubview:_mediaHolder];
  [self addSubview:_scrollView];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupScrollView
{
  [_scrollView setContentSize:CGSizeMake(5000, _scrollView.frame.size.height)];
  
  self.scrollHolder =
  [[UIView alloc] initWithFrame:
   CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height)];
  [_scrollHolder setUserInteractionEnabled:NO];
  
  [_scrollView addSubview:_scrollHolder];
  [_scrollView setShowsHorizontalScrollIndicator:NO];
  [_scrollView setDelegate:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{ 
  [self checkAndRecenterElements];
  
  // tile content in visible bounds
  CGRect visibleBounds = [self convertRect:[self bounds] toView:_scrollHolder];
  CGFloat minX = CGRectGetMinX(visibleBounds);
  CGFloat maxX = CGRectGetMaxX(visibleBounds);
  
  // Arrange elements
  [self computeViewsFromMinX:minX toMaxX:maxX];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Preparing data


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadData
{
  if ([_delegate respondsToSelector:@selector(numberOfItems)]) {
    _numberOfItems = [_delegate numberOfItems];
  }
  
  if (_numberOfItems != 0) {
    [self initiateViewsArray];
  }
  
  [self scrollViewDidScroll:_scrollView];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initiateViewsArray
{
  self.visibleViewsArray = [[NSMutableArray alloc] init];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Displaying data


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)checkAndRecenterElements
{
  CGPoint currentOffset = [_scrollView contentOffset];
  CGFloat contentWidth = [_scrollView contentSize].width;
  CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
  CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
  
  if (distanceFromCenter > (contentWidth / 4.0)) {
    _scrollView.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
    
    // move content by the same amount so it appears to stay still
    for (UIView *view in _visibleViewsArray) {
      CGPoint center = [_scrollHolder convertPoint:view.center toView:self];
      center.x += (centerOffsetX - currentOffset.x);
      view.center = [self convertPoint:center toView:_scrollHolder];
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)getIndexForDirection:(BOOL)direction
{
  NSInteger toReturn = 0;
  
  if ([_visibleViewsArray count] != 0) {
    if (direction) {
      toReturn = ([[_visibleViewsArray lastObject] tag] + 1) % _numberOfItems;
    } else {
      NSInteger leftTag = [[_visibleViewsArray objectAtIndex:0] tag];
      
      toReturn = (leftTag == 0)?_numberOfItems - 1:leftTag - 1;
    }
  }
  
  return toReturn;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)insertView:(BOOL)direction
{
  UIView *toInsert = nil;
  NSInteger indexToInsert = [self getIndexForDirection:direction];
  
  if ([_delegate respondsToSelector:@selector(viewForItemAtIndex:)]) {
    toInsert = [_delegate viewForItemAtIndex:indexToInsert];
    [toInsert setTag:indexToInsert];
  }
  
  [toInsert setFrame:CGRectMake(0, 0, ELEMENT_WIDTH, _scrollHolder.frame.size.height)];
  [_scrollHolder addSubview:toInsert];
  
  return toInsert;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)addViewOnRight:(CGFloat)rightEdge
{
  UIView *insertedView = [self insertView:YES];
  [_visibleViewsArray addObject:insertedView];
  
  CGRect frame = [insertedView frame];
  frame.origin.x = rightEdge;
  frame.origin.y = 0;
  [insertedView setFrame:frame];
  
  return CGRectGetMaxX(frame);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)addViewOnLeft:(CGFloat)leftEdge
{
  UIView *insertedView = [self insertView:NO];
  [_visibleViewsArray insertObject:insertedView atIndex:0];
  
  CGRect frame = [insertedView frame];
  frame.origin.x = leftEdge - frame.size.width;
  frame.origin.y = 0;
  [insertedView setFrame:frame];
  
  return CGRectGetMinX(frame);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)computeViewsFromMinX:(CGFloat)minX toMaxX:(CGFloat)maxX
{
  // Add the first element [initial case]
  if ([_visibleViewsArray count] == 0) {
    [self addViewOnRight:minX];
  }
  
  // Add elements on the right side
  UIView *lastView = [_visibleViewsArray lastObject];
  CGFloat rightEdge = CGRectGetMaxX([lastView frame]);
  while (rightEdge < maxX) {
    rightEdge = [self addViewOnRight:rightEdge];
  }
  
  // Add elements on the left side
  UIView *firstView = [_visibleViewsArray objectAtIndex:0];
  CGFloat leftEdge = CGRectGetMinX([firstView frame]);
  while (leftEdge > minX) {
    leftEdge = [self addViewOnLeft:leftEdge];
  }
  
  // Remove hidden elements from the right edge
  lastView = [_visibleViewsArray lastObject];
  while (lastView.frame.origin.x > maxX) {
    [lastView removeFromSuperview];
    [_visibleViewsArray removeLastObject];
    lastView = [_visibleViewsArray lastObject];
  }
  
  // Remove hidden elements from the left side
  firstView = [_visibleViewsArray objectAtIndex:0];
  while (CGRectGetMaxX([firstView frame]) < minX) {
    [firstView removeFromSuperview];
    [_visibleViewsArray removeObjectAtIndex:0];
    firstView = [_visibleViewsArray objectAtIndex:0];
  }
}


@end
