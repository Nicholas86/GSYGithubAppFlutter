#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FluttertoastPlugin.h"
#import "UIView+Toast.h"

FOUNDATION_EXPORT double fluttertoastVersionNumber;
FOUNDATION_EXPORT const unsigned char fluttertoastVersionString[];

