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
@interface OLGalleryView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id<OLGalleryDelegate> delegate;

/*
 * Init the gallery and set its delegate.
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id<OLGalleryDelegate>)delegate;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol OLGalleryDelegate <NSObject>

@required

/*
 * The view at the given index.
 */
- (UIView *)viewForItemAtIndex:(NSInteger)index;

/*
 * Total number of items.
 */
- (NSInteger)numberOfItems;

@end