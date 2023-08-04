// mac_view.h
#ifndef MAC_VIEW_H_
#define MAC_VIEW_H_

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import "mac_window.h"
#import "mac_pixels.h"

@interface Mac_NSView : NSView
@end
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Mac_View Mac_View;

struct Mac_View
{
    Mac_View *parent_view;
    MAC_Window *window_parent;
    int width, height;
    int x, y;
    MAC_Color background_color;
    bool is_root;
    bool is_metal_view;
};

#define MAX_VIEWS 1000 // You can adjust this value based on your needs
extern Mac_View* g_views[MAX_VIEWS];
extern int g_viewCount;


Mac_View* addSubView(Mac_View* parent, int width, int height, int x, int y, MAC_Color background_color);
Mac_View* addContentView(MAC_Window* parent, MAC_Color background_color);
void destroyViews(Mac_View* views[], int count);
void destroyView(Mac_View* view);

#ifdef __cplusplus
}
#endif

#endif // MAC_VIEW_H_
