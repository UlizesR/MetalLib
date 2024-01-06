#pragma once 

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <simd/simd.h>

typedef NS_ENUM(NSInteger, MouseCodes) {
    MouseCodesLeft = 0,
    MouseCodesRight = 1,
    MouseCodesCenter = 2
};

@interface Mouse : NSObject

+ (void)setMouseButtonPressed:(NSInteger)button isOn:(BOOL)isOn;
+ (BOOL)isMouseButtonPressed:(MouseCodes)button;
+ (void)setOverallMousePosition:(vector_float2)position;
+ (void)setMousePositionChangeWithOverallPosition:(vector_float2)overallPosition deltaPosition:(vector_float2)deltaPosition;
+ (void)scrollMouse:(float)deltaY;
+ (vector_float2)getMouseWindowPosition;
+ (float)getDWheel;
+ (float)getDY;
+ (float)getDX;
+ (vector_float2)getMouseViewportPosition:(vector_float2)viewportSize;

@end

#endif // __OBJC__