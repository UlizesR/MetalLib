#ifndef mac_view_h_
#define mac_view_h_

#include "mac_internals.h"
#include "mac_pixels.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

typedef struct {
    MFPoint init_pos;
    MFPoint end_pos;
    float line_width;
    Mac_Color color;
} DrawingCommand;

@interface DrawableShape : NSObject
@property (nonatomic) CGPathRef path;
@property (nonatomic) Mac_Color color;
@property (nonatomic) float lineWidth;
@property (nonatomic) BOOL filled;
@property (nonatomic) int id;
- (void)updateLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos;
@end

@interface Mac_NSView : NSView
@property (nonatomic, strong) NSMutableArray<DrawableShape*>* shapes;
@property (nonatomic, strong) NSMutableArray<NSValue*>* drawingCommands;
- (void)setLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos lineWidth:(float)line_width shapeID:(int)id color:(Mac_Color)color;
@end
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct Mac_View
{
    Mac_View *parent_view;
    Mac_Window *window_parent;
    MSize size;
    MPoint position;
    Mac_Color background_color;
    bool is_root;
    bool is_metal_view;
    void* _this;
};

#define MAX_VIEWS 1000 // You can adjust this value based on your needs
extern Mac_View* g_views[MAX_VIEWS];
extern int g_viewCount;

/*!
    Creates a sub view with the given parameters.
    @param parent: the parent view
    @param width: the width of the view
    @param height: the height of the view
    @param x: the x position of the view
    @param y: the y position of the view
    @param background_color: the background color of the view
    @return: the created view
*/
Mac_View* addSubView(Mac_View* parent, int width, int height, int x, int y, Mac_Color background_color);

/*!
    Creates a given window's content view with the given parameters.
    @param parent: the parent window of the view
    @param background_color: the background color of the view
    @return: the created view
*/
Mac_View* addContentView(Mac_Window* parent, Mac_Color background_color);

/*!
    Updates the view with the given parameters.
    @param view: the view to update
    @param shape_id: the id of the shape to update
*/
void updateView(Mac_View* view, int shape_id);

/*! 
    Destroys the given views.
    @param views: the views to be destroyed
    @param count: the number of views
*/
void destroyViews(Mac_View* views[], int count);

/*!
    Destroys the given view.
    @param view: the view to be destroyed
*/
void destroyView(Mac_View* view);

#ifdef __cplusplus
}
#endif

#endif // mac_view_h_
