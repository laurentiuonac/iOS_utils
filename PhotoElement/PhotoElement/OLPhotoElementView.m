//
//  OLPhotoElementView.m
//  PhotoElement
//
//  Created by Laurentiu on 18/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

#import "OLPhotoElementView.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OLPhotoElementView()

@property (nonatomic, strong) UIImageView *imgView1;
@property (nonatomic, strong) UIImageView *imgView2;
@property (nonatomic, weak) UIImageView *visibleView;

@property CGRect outsideFrame;
@property CGRect minimizedFrame;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OLPhotoElementView


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self initializeComponents];
  }
  
  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeComponents
{
  NSInteger width = self.frame.size.width;
  NSInteger height = self.frame.size.height;
  
  NSInteger minWidth = width * 0.3;
  NSInteger minHeight = width * 0.3;
  
  NSInteger minX = (width - minWidth) / 2;
  NSInteger minY = (height - minHeight) / 2;
  
  self.minimizedFrame = CGRectMake(minX, minY, minWidth, minHeight);
  self.outsideFrame = CGRectMake(width, 0, width, height);
  
  self.imgView1 = [[UIImageView alloc] initWithFrame:self.frame];
  [_imgView1 setContentMode:UIViewContentModeScaleAspectFill];
  [_imgView1 setClipsToBounds:YES];
  
  self.imgView2 = [[UIImageView alloc] initWithFrame:_outsideFrame];
  [_imgView2 setContentMode:UIViewContentModeScaleAspectFill];
  [_imgView2 setClipsToBounds:YES];
  
  [self addSubview:_imgView2];
  [self addSubview:_imgView1];
  
  [self setClipsToBounds:YES];
  [self setVisibleView:_imgView1];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setInitialImage:(UIImage *)image
{
  [_imgView1 setImage:image];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)changeImage:(UIImage *)image
{
  if (_visibleView == _imgView2) {
    [_imgView1 setImage:image];
    [self hideView:_imgView2 andShowView:_imgView1];
  } else {
    [_imgView2 setImage:image];
    [self hideView:_imgView1 andShowView:_imgView2];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Customization


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideView:(UIImageView *)toHide andShowView:(UIImageView *)toShow
{
  [self bringSubviewToFront:toShow];
  
  [UIView animateWithDuration:0.7
                        delay:0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [toHide setFrame:_minimizedFrame];
                     [toHide setAlpha:0];
                     [toShow setFrame:self.frame];
                   }
                   completion:^(BOOL finished) {
                     [toHide setFrame:_outsideFrame];
                     [toHide setAlpha:1];
                     _visibleView = toShow;
                   }];
}


@end
