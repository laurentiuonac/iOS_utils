//
//  OLConstants.h
//  PhotoGallery
//
//  Created by Laurentiu on 12/9/12.
//  Copyright (c) 2012 Laurentiu. All rights reserved.
//

// Utils
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// Debugging
#define DEBUG_LOG

#ifdef DEBUG_LOG
  #define DLog(s, ...) NSLog( @"<%@:(%d)> %@", \
  [[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
  __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
  #define DLog(s, ...)
#endif