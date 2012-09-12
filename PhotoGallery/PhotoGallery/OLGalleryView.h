//
//  OLGalleryView.h
//  PhotoGallery
//
//  Created by Laurentiu on 11/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OLGalleryDelegate;


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OLGalleryView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign) id<OLGalleryDelegate> galleryDelegate;

/*
 * Init the gallery and set its delegate and properties.
 */
- (id)initWithFrame:(CGRect)frame
        andDelegate:(id<OLGalleryDelegate>)galleryDelegate
     withProperties:(NSArray *)propertiesArray;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol OLGalleryDelegate <NSObject>


@required

/*
 * The view at the given index.
 */
- (UIView *)galleryView:(OLGalleryView *)galleryView viewForItemAtIndex:(NSInteger)index;

/*
 * Total number of items.
 */
- (NSInteger)numberOfItemsForGalleryView:(OLGalleryView *)galleryView;


@optional

/*
 * Element spacing.
 */
- (NSInteger)elementSpacingForGalleryView:(OLGalleryView *)galleryView;

/*
 * Element width.
 */
- (NSInteger)elementWidthForGalleryView:(OLGalleryView *)galleryView;

/*
 * Gives the index of the selected element.
 */
- (void)galleryView:(OLGalleryView *)galleryView selectedItemAtIndex:(NSInteger)index;



@end