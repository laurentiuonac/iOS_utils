//
//  OLViewController.m
//  PhotoGallery
//
//  Created by Laurentiu on 11/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

#import "OLViewController.h"
#import "OLConstants.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OLViewController ()

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OLViewController


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  OLGalleryView *galleryView =
  [[OLGalleryView alloc]
   initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 150)
   andDelegate:self withOptions:OLGDisableSelectionAfterDragging];
  [self.view addSubview:galleryView];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
  [super viewDidUnload];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - OLGalleryDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)elementSpacingForGalleryView:(OLGalleryView *)galleryView
{
  return 2;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfItemsForGalleryView:(OLGalleryView *)galleryView
{
  return 10;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)elementWidthForGalleryView:(OLGalleryView *)galleryView
{
  return 300;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)galleryView:(OLGalleryView *)galleryView viewForItemAtIndex:(NSInteger)index
{
  UIView *view = [[UIView alloc] init];
  [view setBackgroundColor:[UIColor colorWithRed:index*10/255.0
                                           green:index*15/255.0
                                            blue:index*15/255.0
                                           alpha:1]];
  
  return view;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)galleryView:(OLGalleryView *)galleryView selectedItemAtIndex:(NSInteger)index
{
  DLog(@"Selected item: %d", index);
}


@end