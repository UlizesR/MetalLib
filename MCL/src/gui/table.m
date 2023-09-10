#import "MCL/gui/table.h"
#include <AppKit/AppKit.h>
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

@interface MCL_TableDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, strong) NSMutableArray *rows;
@property(nonatomic, strong) NSColor *textColor; // Add this line to store the text color

@end

@implementation MCL_TableDataSource

- (instancetype)init {
    self = [super init];
    if (!self) 
    {
        printf("Failed to create Table View data Source\n");
        return nil;
    }
    self.rows = [NSMutableArray array];
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.rows.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *values = self.rows[row];
    NSInteger columnIndex = [[tableView tableColumns] indexOfObject:tableColumn];
    return values[columnIndex];
}

- (void)addRow:(MCL_TableRow *)row {
    NSMutableArray *valuesArray = [NSMutableArray array];
    for (int i = 0; i < row->columnCount; i++) 
    { // Use columnCount instead of NULL check
        [valuesArray addObject:[NSString stringWithUTF8String:&row->values[i]]];
    }
    [self.rows addObject:valuesArray];
}
@end

void MCL_AddTable(MCL_Frame *frame, MCL_Frame *tableFrame, MCL_TableColumn *columns, int columnCount, int x, int y, int width, int height)
{
    // Check if the frame is valid
    if (!frame)
    {
        printf("Failed to create table, parent frame is null\n");
        return;
    }
    // Create the table view
    NSTableView *tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    if (!tableView)
    {
        printf("Failed to create table view\n");
        return;
    }
    // set the column width
    float columnWidth = (float)width / columnCount;
    // create the columns
    for (int i = 0; i < columnCount; i++)
    {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithUTF8String:columns[i].name]];
        [column setWidth:columnWidth];
        [column setEditable:YES];
        [column.headerCell setStringValue:[NSString stringWithUTF8String:columns[i].name]];
        [tableView addTableColumn:column];
    }
    printf("Column count: %d\n", (int)[[tableView tableColumns] count]);
    // Create the data source
    MCL_TableDataSource *dataSource = [[MCL_TableDataSource alloc] init];
    if (!dataSource)
    {
        printf("Failed to create table data source\n");
        return;
    }
    // Set the data source and delegate
    [tableView setDataSource:dataSource];
    [tableView setDelegate:dataSource];
    // set the header view
    [tableView setHeaderView:[[NSTableHeaderView alloc] initWithFrame:NSMakeRect(0, 0, width, 18)]];
    // set the selection type
    // [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [tableView reloadData];
    [tableView setNeedsDisplay:YES];

    // Set the table's frame properties
    tableFrame->x = x;
    tableFrame->y = y;
    tableFrame->width = width;
    tableFrame->height = height;
    tableFrame->corner_radius = 0;
    tableFrame->bg_color = frame->bg_color;
    tableFrame->_this = (__bridge void *)(tableView);

    // Add the table view to the frame
    NSView *view = (NSView *)frame->_this;
    [view addSubview:tableView];
}

void MCL_AddRow(MCL_Frame *tableFrame, MCL_TableRow *row) {
    NSTableView *nsTableView = (__bridge NSTableView *)(tableFrame->_this);
    if (!nsTableView)
    {
        printf("Failed to add row to table, table view is null\n");
        return;
    }
    // Assuming the data source is set for the table view
    MCL_TableDataSource *dataSource = (MCL_TableDataSource *)[nsTableView dataSource];
    // Add the row data to the data source
    [dataSource addRow:row];
    // Reload the table view to reflect the changes
    [nsTableView reloadData];
}