//
//  OLGalleryView.m
//  PhotoGallery
//
//  Created by Laurentiu on 11/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

#import "OLGalleryView.h"
#import "OLConstants.h"

#define INIT_ELEMENT_WIDTH 266


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OLGalleryView()

@property (nonatomic, strong) NSMutableArray *visibleViewsArray;
@property (nonatomic, strong) UIView *scrollHolder;

@property NSInteger numberOfItems;
@property NSInteger elementSpacing;
@property NSInteger elementWidth;

/*
 * Gallery properties
 */
@property BOOL infiniteScroll;
@property BOOL centerSelectedElement;

@property BOOL elementsFit;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OLGalleryView


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
        andDelegate:(id<OLGalleryDelegate>)galleryDelegate
     withProperties:(NSArray *)propertiesArray
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self assignProperties:propertiesArray];
    [self setGalleryDelegate:galleryDelegate];
    [self loadElementData];
    [self setupScrollView];
  }
  
  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)assignProperties:(NSArray *)propertiesArray
{
  if (propertiesArray) {
    _centerSelectedElement = NO;
    _infiniteScroll = NO;
    
    if ([propertiesArray indexOfObject:@"centerSelectedElement"] != NSNotFound) {
      _centerSelectedElement = YES;
    }
    
    if ([propertiesArray indexOfObject:@"infiniteScroll"] != NSNotFound) {
      _infiniteScroll = YES;
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupScrollView
{
  NSInteger contentWidth = 5000;
  
  if (!_infiniteScroll) {
     contentWidth = _numberOfItems * _elementWidth + (_numberOfItems + 1) * _elementSpacing;
  }
  
  [self setContentSize:CGSizeMake(contentWidth, self.frame.size.height)];
  
  self.scrollHolder =
  [[UIView alloc] initWithFrame:
   CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
  [_scrollHolder setUserInteractionEnabled:YES];
  
  [self addSubview:_scrollHolder];
  [self setShowsHorizontalScrollIndicator:NO];
  [self setCanCancelContentTouches:YES];
  [self setDecelerationRate:UIScrollViewDecelerationRateFast];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadElementData
{
  _numberOfItems = 0;
  _elementSpacing = 0;
  _elementsFit = NO;
  _elementWidth = INIT_ELEMENT_WIDTH;
  
  if ([_galleryDelegate respondsToSelector:@selector(numberOfItemsForGalleryView:)]) {
    _numberOfItems = [_galleryDelegate numberOfItemsForGalleryView:self];
  }
  
  if ([_galleryDelegate respondsToSelector:@selector(elementSpacingForGalleryView:)]) {
    _elementSpacing = [_galleryDelegate elementSpacingForGalleryView:self];
  }
  
  if ([_galleryDelegate respondsToSelector:@selector(elementWidthForGalleryView:)]) {
    _elementWidth = [_galleryDelegate elementWidthForGalleryView:self];
  }
  
  if (!_infiniteScroll) {
    NSInteger totalSize = _numberOfItems * _elementWidth + (_numberOfItems + 1) * _elementSpacing;
    if (totalSize <= self.frame.size.width) {
      _elementsFit = YES;
    }
  }
  
  if (_numberOfItems != 0) {
    [self initiateViewsArray];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
  if (_numberOfItems != 0) {
    if (_infiniteScroll) {
      [self checkAndRecenterElements];
    }
    
    // Arrange content in visible bounds
    CGRect visibleBounds = [self convertRect:[self bounds] toView:_scrollHolder];
    CGFloat minX = CGRectGetMinX(visibleBounds);
    CGFloat maxX = CGRectGetMaxX(visibleBounds);

    [self computeViewsFromMinX:minX toMaxX:maxX];
    
    if (_elementsFit) {
      [self centerElementsAndDisableScrolling];
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)centerElementsAndDisableScrolling
{
  UIView *subView = [self.subviews objectAtIndex:0];
  
  CGFloat offsetX = (self.bounds.size.width > self.contentSize.width)?
  (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
  
  CGFloat offsetY = (self.bounds.size.height > self.contentSize.height)?
  (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;
  
  subView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                               self.contentSize.height * 0.5 + offsetY);
  
  [self setScrollEnabled:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTap:(UIGestureRecognizer *)sender
{
  NSInteger index = sender.view.tag;
  
  if ([_galleryDelegate respondsToSelector:@selector(galleryView:selectedItemAtIndex:)]) {
    [_galleryDelegate galleryView:self selectedItemAtIndex:index];
  }
  
  // Center selected element
  if (_centerSelectedElement) {
    // Required number of elements to scroll in one direction
    NSInteger reqNumberOfElements = floor((self.frame.size.width / 2) / _elementWidth + 0.5);
    
    // Check if there are enough elements on the right side
    if (!_infiniteScroll && sender.view.tag + 1 + reqNumberOfElements > _numberOfItems) {
      NSInteger remainingElementsRight = _numberOfItems - (sender.view.tag + 1);
      NSInteger remainingSizeRight = remainingElementsRight * _elementWidth +
      _elementWidth / 2 + _elementSpacing * (remainingElementsRight + 1);
      
      NSInteger objectX = CGRectGetMidX(sender.view.frame) + remainingSizeRight - _elementWidth;
      NSInteger objectY = 0;
      
      CGRect lastObject = CGRectMake(objectX, objectY, _elementWidth, self.frame.size.height);
      
      [self scrollRectToVisible:lastObject animated:YES];

      // Or in the left side
    } else if (!_infiniteScroll && sender.view.tag + 1 - reqNumberOfElements <= 0) {
      NSInteger remainingElementsLeft = sender.view.tag;
      NSInteger remainingSizeLeft = remainingElementsLeft * _elementWidth +
      _elementWidth / 2 + _elementSpacing * (remainingElementsLeft + 1);

      NSInteger objectX = CGRectGetMidX(sender.view.frame) - remainingSizeLeft;
      NSInteger objectY = 0;
      
      CGRect lastObject = CGRectMake(objectX, objectY, _elementWidth, self.frame.size.height);
      
      [self scrollRectToVisible:lastObject animated:YES];
      
      // Or perform the regular centering
    } else {
      CGRect viewFrame = [self convertRect:sender.view.frame toView:self.superview];
      CGFloat centerX = CGRectGetMidX(viewFrame);
      CGPoint currentOffset = self.contentOffset;
      currentOffset.x -= self.center.x - centerX;
      
      [self setContentOffset:currentOffset animated:YES];
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Preparing data


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
  
  if ([_galleryDelegate respondsToSelector:@selector(galleryView:viewForItemAtIndex:)]) {
    toInsert = [_galleryDelegate galleryView:self viewForItemAtIndex:indexToInsert];
    [toInsert setTag:indexToInsert];
  }
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(didTap:)];
  [tapRecognizer setNumberOfTapsRequired:1];
  [tapRecognizer setNumberOfTouchesRequired:1];
  
  [toInsert setFrame:CGRectMake(0, 0, _elementWidth, _scrollHolder.frame.size.height)];
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
  frame.origin.x = rightEdge + _elementSpacing;
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
  frame.origin.x = leftEdge - frame.size.width - _elementSpacing;
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
    if (!_infiniteScroll) {
      if ([_visibleViewsArray count] == _numberOfItems || lastView.tag == _numberOfItems - 1) {
        break;
      }
    }
    
    rightEdge = [self addViewOnRight:rightEdge];
    DLog(@"Add right: %d", [_visibleViewsArray count]);
  }
  
  // Add elements on the left side
  UIView *firstView = [_visibleViewsArray objectAtIndex:0];
  CGFloat leftEdge = CGRectGetMinX([firstView frame]);
  while (leftEdge > minX) {
    if (!_infiniteScroll) {
      if ([_visibleViewsArray count] == _numberOfItems || firstView.tag == 0) {
        break;
      }
    }
    
    leftEdge = [self addViewOnLeft:leftEdge];
    DLog(@"Add left: %d", [_visibleViewsArray count]);
  }
  
  // Remove hidden elements from the right edge
  lastView = [_visibleViewsArray lastObject];
  while (lastView.frame.origin.x > maxX) {
    [lastView removeFromSuperview];
    [_visibleViewsArray removeLastObject];
    lastView = [_visibleViewsArray lastObject];
    
    DLog(@"Remove right: %d", [_visibleViewsArray count]);
  }
  
  // Remove hidden elements from the left side
  firstView = [_visibleViewsArray objectAtIndex:0];
  while (CGRectGetMaxX([firstView frame]) < minX) {
    [firstView removeFromSuperview];
    [_visibleViewsArray removeObjectAtIndex:0];
    firstView = [_visibleViewsArray objectAtIndex:0];
    
    DLog(@"Remove left: %d", [_visibleViewsArray count]);
  }
}


@end
