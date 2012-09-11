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

@property (nonatomic, strong) NSMutableArray *visibleViewsArray;
@property (nonatomic, strong) UIView *scrollHolder;

@property NSInteger numberOfItems;
@property NSInteger scrollEnters;
@property BOOL dontEnter;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OLGalleryView


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame andDelegate:(id<OLGalleryDelegate>)galleryDelegate
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self setGalleryDelegate:galleryDelegate];
    [self initializeComponents];
    [self loadData];
  }
  
  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeComponents
{  
  [self setupScrollView];
  
  _scrollEnters = 0;
  _dontEnter = NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupScrollView
{
  [self setContentSize:CGSizeMake(5000, self.frame.size.height)];
  
  self.scrollHolder =
  [[UIView alloc] initWithFrame:
   CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
  [_scrollHolder setUserInteractionEnabled:YES];
  
  [self addSubview:_scrollHolder];
  [self setShowsHorizontalScrollIndicator:NO];
  [self setCanCancelContentTouches:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
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
#pragma mark - Actions


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTap:(UIGestureRecognizer *)sender
{
  NSInteger index = sender.view.tag;
  
  if ([_galleryDelegate respondsToSelector:@selector(selectedItemAtIndex:)]) {
    [_galleryDelegate selectedItemAtIndex:index];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Preparing data


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadData
{
  if ([_galleryDelegate respondsToSelector:@selector(numberOfItems)]) {
    _numberOfItems = [_galleryDelegate numberOfItems];
  }
  
  if (_numberOfItems != 0) {
    [self initiateViewsArray];
  }
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
  CGPoint currentOffset = self.contentOffset;
  CGFloat contentWidth = self.contentSize.width;
  CGFloat centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0;
  CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
  
  if (distanceFromCenter > (contentWidth / 4.0)) {
    _dontEnter = YES;
    self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
    
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
  
  if ([_galleryDelegate respondsToSelector:@selector(viewForItemAtIndex:)]) {
    toInsert = [_galleryDelegate viewForItemAtIndex:indexToInsert];
    [toInsert setTag:indexToInsert];
  }
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(didTap:)];
  [tapRecognizer setNumberOfTapsRequired:1];
  [tapRecognizer setNumberOfTouchesRequired:1];
  
  [toInsert setFrame:CGRectMake(0, 0, ELEMENT_WIDTH, _scrollHolder.frame.size.height)];
  [toInsert addGestureRecognizer:tapRecognizer];
  [toInsert setUserInteractionEnabled:YES];
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
    NSLog(@"Add right: %d", [_visibleViewsArray count]);
  }
  
  // Add elements on the left side
  UIView *firstView = [_visibleViewsArray objectAtIndex:0];
  CGFloat leftEdge = CGRectGetMinX([firstView frame]);
  while (leftEdge > minX) {
    leftEdge = [self addViewOnLeft:leftEdge];
    NSLog(@"Add left: %d", [_visibleViewsArray count]);
  }
  
  // Remove hidden elements from the right edge
  lastView = [_visibleViewsArray lastObject];
  while (lastView.frame.origin.x > maxX) {
    [lastView removeFromSuperview];
    [_visibleViewsArray removeLastObject];
    lastView = [_visibleViewsArray lastObject];
    
    NSLog(@"Remove right: %d", [_visibleViewsArray count]);
  }
  
  // Remove hidden elements from the left side
  firstView = [_visibleViewsArray objectAtIndex:0];
  while (CGRectGetMaxX([firstView frame]) < minX) {
    [firstView removeFromSuperview];
    [_visibleViewsArray removeObjectAtIndex:0];
    firstView = [_visibleViewsArray objectAtIndex:0];
    
    NSLog(@"Remove left: %d", [_visibleViewsArray count]);
  }
}


@end
