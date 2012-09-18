//
//  OLPhotoElementView.h
//  PhotoElement
//
//  Created by Laurentiu on 18/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

#import <UIKit/UIKit.h>


////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OLPhotoElementView : UIView

/*
 *  Set the initial image displayed by the view.
 */
- (void)setInitialImage:(UIImage *)image;

/*
 *  Change the image.
 */
- (void)changeImage:(UIImage *)image;

@end
