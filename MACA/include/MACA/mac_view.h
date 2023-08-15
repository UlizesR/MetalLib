#pragma once

#include "mac_defs.h"
#include "mac_colors.h"
// include the different view types
#include "mac_tables.h"
#include "mac_metal.h"

#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

NSView* getViewFromMacView(M_View* parent_view);

@interface M_NSView_Normal: NSView;
@end

typedef struct {
    MFPoint init_pos;
    MFPoint end_pos;
    float line_width;
    M_Color color;
} DrawingCommand;

@interface DrawableShape : NSObject
@property (nonatomic) CGPathRef path;
@property (nonatomic) M_Color color;
@property (nonatomic) float lineWidth;
@property (nonatomic) BOOL filled;
@property (nonatomic) int id;
- (void)updateLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos;
@end

@interface M_NSView_Core_G: NSView;
@property (nonatomic, strong) NSMutableArray<DrawableShape*>* shapes;
@property (nonatomic, strong) NSMutableArray<NSValue*>* drawingCommands;
- (void)setLineWithInitPos:(MFPoint)init_pos endPos:(MFPoint)end_pos lineWidth:(float)line_width shapeID:(int)id color:(M_Color)color;
@end


#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    M_VIEW_TYPE_NORMAL    = 1,
    M_VIEW_TYPE_CORE_G    = 2,
    M_VIEW_TYPE_METAL     = 4,
    M_VIEW_TYPE_TABLE     = 8,
} M_View_Type;

struct M_NView                    // Normal view for apps
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    M_Color background_color;     // The background color of the view
    MPoint position;                // The position of this view
    M_Window *window_parent;      // The parent window of this view
    bool is_content_view;           // Whether this view is the content view of the window or not
    void* _this;                    // The pointer to this view
};

struct M_RView                    // normal view to render core graphics
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    M_Color background_color;     // The background color of the view
    MPoint position;                // The position of this view
    M_Window *window_parent;      // The parent window of this view
    M_Renderer *renderer;         // The renderer that owns this view
    bool is_content_view;           // Whether this view is the content view of the window or not
    void* _this;                    // The pointer to this view
};


union UView                      // The union of all views
{
    M_NView n_view;
    M_RView r_view;
    M_MView m_view;
    M_TView t_view;
};

struct M_View
{
    M_View_Type type;             // The type of the view
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
M_View* M_AddSubView(M_View* parent, UInt32 type, int width, int height, int x, int y, float corner_radius, M_Color background_color, M_Renderer* renderer);

/*!
    Creates a given window's content view with the given parameters.
    @param parent: the parent window of the view
    @param background_color: the background color of the view
    @param type: the type of the view
    @return: the created content view
*/
M_View* M_AddContentView(M_Window* parent, M_Color background_color, UInt32 type, M_Renderer* renderer);

/*!
    Changes the Color of the given view.
    @param view: the view to be changed
    @param color: the new color of the view
*/
void M_ChangeViewBGColor(M_View* view, M_Color color);

/*!
    Hides the given view.
    @param view: the view to be hidden
*/
void M_HideView(M_View* view);

/*!
    Shows the given view.
    @param view: the view to be shown
*/
void M_ShowView(M_View* view);

/*!
    Destroys the given view.
    @param view: the view to be destroyed
*/
void M_DestroyView(M_View* view);

/*!
    Destroys the given content view.
    @param contentView: the content view to be destroyed
*/
void M_DestroyContentView(M_View* contentView);


#ifdef __cplusplus
}
#endif
