#ifndef MAC_VIEW_H_
#define MAC_VIEW_H_

#include "mac_internals.h"
#include "mac_window.h"
#include "mac_pixels.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

typedef struct {
    Mac_FPoint init_pos;
    Mac_FPoint end_pos;
    float line_width;
    Mac_Color color;
} DrawingCommand;

@interface DrawableShape : NSObject
@property (nonatomic) CGPathRef path;
@property (nonatomic) Mac_Color color;
@property (nonatomic) float lineWidth;
@property (nonatomic) BOOL filled;
- (void)updateLineWithInitPos:(Mac_FPoint)init_pos endPos:(Mac_FPoint)end_pos;
@end

@interface Mac_NSView : NSView
@property (nonatomic, strong) NSMutableArray<DrawableShape*>* shapes;
@property (nonatomic, strong) NSMutableArray<NSValue*>* drawingCommands;
- (void)setLineWithInitPos:(Mac_FPoint)init_pos endPos:(Mac_FPoint)end_pos lineWidth:(float)line_width color:(Mac_Color)color;
@end
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Mac_View Mac_View;

struct Mac_View
{
    Mac_View *parent_view;
    Mac_Window *window_parent;
    int width, height;
    int x, y;
    Mac_Color background_color;
    bool is_root;
    bool is_metal_view;
    void* _this;
};

#define MAX_VIEWS 1000 // You can adjust this value based on your needs
extern Mac_View* g_views[MAX_VIEWS];
extern int g_viewCount;

Mac_View* addSubView(Mac_View* parent, int width, int height, int x, int y, Mac_Color background_color);
Mac_View* addContentView(Mac_Window* parent, Mac_Color background_color);
void updateView(Mac_View* view);
void destroyViews(Mac_View* views[], int count);
void destroyView(Mac_View* view);

#ifdef __cplusplus
}
#endif

#endif // MAC_VIEW_H_
