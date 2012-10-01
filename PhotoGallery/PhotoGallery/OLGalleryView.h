//
//  OLGalleryView.h
//  PhotoGallery
//
//  Created by Laurentiu on 11/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

#import <UIKit/UIKit.h>


////////////////////////////////////////////////////////////////////////////////////////////////////
enum OLGalleryOption {
  OLGNormalBehaviour = 0,
  OLGDisableCenteringOfSelectedElement = 1,
  OLGDisableInfiniteScroll = 2,
  OLGDisableGalleryMovementAnimation = 4,
  OLGDisableSelectedElementView = 8,
  OLGDisableAutoSelectElement = 16,
  OLGDisableSelectionAfterDragging = 32,
  OLGDisableAnimationBeforeSelection = 64
};


////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol OLGalleryDelegate;


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OLGalleryView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign) id<OLGalleryDelegate> galleryDelegate;

/*
 *  Init the gallery and set its delegate.
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id<OLGalleryDelegate>)galleryDelegate;

/*
 *  Init the gallery and set its delegate and options.
 */
- (id)initWithFrame:(CGRect)frame
        andDelegate:(id<OLGalleryDelegate>)galleryDelegate
        withOptions:(enum OLGalleryOption)options;

/*
 *  Start animating the gallery.
 */
- (void)startAnimating;

/*
 *  Stop animating the gallery.
 */
- (void)stopAnimating;

/*
 *  Select next element.
 */
- (void)selectNextElement;

/*
 *  Select previous element.
 */
- (void)selectPreviousElement;


@end


////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol OLGalleryDelegate <NSObject>


@required

/*
 *  The view at the given index.
 */
- (UIView *)galleryView:(OLGalleryView *)galleryView viewForItemAtIndex:(NSInteger)index;

/*
 *  Total number of items.
 */
- (NSInteger)numberOfItemsForGalleryView:(OLGalleryView *)galleryView;


@optional

/*
 *  Element spacing.
 */
- (NSInteger)elementSpacingForGalleryView:(OLGalleryView *)galleryView;

/*
 *  Element width.
 */
- (NSInteger)elementWidthForGalleryView:(OLGalleryView *)galleryView;

/*
 *  Gives the index of the selected element.
 */
- (void)galleryView:(OLGalleryView *)galleryView selectedItemAtIndex:(NSInteger)index;


@end
