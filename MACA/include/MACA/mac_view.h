#pragma once

#include "mac_defs.h"
#include "mac_colors.h"

#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>



@interface Mac_NSView_Normal: NSView;
@end

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

@interface Mac_NSView_Core_G: NSView;
@property (nonatomic, strong) NSMutableArray<DrawableShape*>* shapes;
@property (nonatomic, strong) NSMutableArray<NSValue*>* drawingCommands;
- (void)setLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos lineWidth:(float)line_width shapeID:(int)id color:(Mac_Color)color;
@end

@interface Mac_NSView_Metal: MTKView;
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    MAC_VIEW_TYPE_NORMAL    = 1,
    MAC_VIEW_TYPE_CORE_G    = 2,
    MAC_VIEW_TYPE_METAL     = 4,
} Mac_View_Type;

struct Mac_NView                    // Normal view for apps
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    Mac_Color background_color;     // The background color of the view
    MPoint position;                // The position of this view
    Mac_Window *window_parent;      // The parent window of this view
    bool is_content_view;           // Whether this view is the content view of the window or not
    void* _this;                    // The pointer to this view
};

struct Mac_RView                    // normal view to render core graphics
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    Mac_Color background_color;     // The background color of the view
    MPoint position;                // The position of this view
    Mac_Window *window_parent;      // The parent window of this view
    Mac_Renderer *renderer;         // The renderer that owns this view
    bool is_content_view;           // Whether this view is the content view of the window or not
    void* _this;                    // The pointer to this view
};

struct Mac_MView                    // metal view to render metal graphics
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    Mac_Color background_color;     // The background color of the view
    MPoint position;                // The position of this view
    Mac_Window *window_parent;      // The parent window of this view
    Mac_Renderer *renderer;         // The renderer that owns this view
    bool is_content_view;           // Whether this view is the content view of the window or not
    void* _this;                    // The pointer to this view
};

union UView                      // The union of all views
{
    Mac_NView n_view;
    Mac_RView r_view;
    Mac_MView m_view;
};

struct Mac_View
{
    Mac_View_Type type;             // The type of the view
    union UView view;               // The view
    float corner_radius;            // The corner radius of the view
}; // The view

/*!
    Creates a sub view with the given parameters.
    @param parent: the parent view of the view
    @param type: the type of the view
    @param width: the width of the view
    @param height: the height of the view
    @param x: the x position of the view
    @param y: the y position of the view
    @param corner_radius: the corner radius of the view
    @param background_color: the background color of the view
    @param renderer: the renderer that owns this view
    @return: the created sub view
*/
Mac_View* MAC_AddSubView(Mac_View* parent, UInt32 type, int width, int height, int x, int y, float corner_radius, Mac_Color background_color, Mac_Renderer* renderer);

/*!
    Creates a given window's content view with the given parameters.
    @param parent: the parent window of the view
    @param background_color: the background color of the view
    @param type: the type of the view
    @return: the created content view
*/
Mac_View* MAC_AddContentView(Mac_Window* parent, Mac_Color background_color, UInt32 type, Mac_Renderer* renderer);

/*!
    Changes the Color of the given view.
    @param view: the view to be changed
    @param color: the new color of the view
*/
void MAC_ChangeViewBGColor(Mac_View* view, Mac_Color color);

/*!
    Hides the given view.
    @param view: the view to be hidden
*/
void MAC_HideView(Mac_View* view);

/*!
    Shows the given view.
    @param view: the view to be shown
*/
void MAC_ShowView(Mac_View* view);

/*!
    Destroys the given view.
    @param view: the view to be destroyed
*/
void MAC_DestroyView(Mac_View* view);

/*!
    Destroys the given content view.
    @param contentView: the content view to be destroyed
*/
void MAC_DestroyContentView(Mac_View* contentView);


#ifdef __cplusplus
}
#endif
