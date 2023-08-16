#pragma once

#include "defs.h"
#include "colors.h"

#include <stdbool.h>

struct M_TView
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    MPoint position;                // The position of this view
    M_Color background_color;       // The background color of the view
    M_Window *window_parent;        // The parent window of this view
    void* scroll_view; // Add this line
    bool is_content_view;           // Whether this view is the content view of the window or not
    void* _this;                    // The pointer to this view
};

// Structure to represent a table column
typedef struct {
    char* title;
} M_TableColumn;

// Structure to represent a table row
typedef struct {
    char** values;
    int columnCount; // Add this line
} M_TableRow;

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface M_NSTableView : NSTableView
@end

@interface M_TableViewDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSMutableArray* rows;
@property (nonatomic, strong) NSColor* textColor; // Add this line to store the text color

- (void)addRow:(M_TableRow*)row;
- (M_TableRow*)getRowAtIndex:(NSInteger)index;
- (NSString*)getDataAtRow:(NSInteger)row column:(NSInteger)column;
- (void)setDataAtRow:(NSInteger)row column:(NSInteger)column value:(NSString*)value;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

// Function to create a table in the given table view
void M_CreateTable(M_View* tableView, M_TableColumn* columns, int columnCount);

// Function to add a row to the table
void M_AddRowToTable(M_View* tableView, M_TableRow* row);

// Function to get data at a specific row and column
MData M_GetDataAtRowAndColumn(M_View* tableView, int row, int column); // Changed return type to MData

// Function to change data at a specific row and column
void M_SetDataAtRowAndColumn(M_View* tableView, int row, int column, const char* value); // Changed parameter type to const char*

#ifdef __cplusplus
}
#endif
