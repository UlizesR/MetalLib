#import "MACA/mac_tables.h"
#import "MACA/mac_view.h"


@implementation M_NSTableView
@end

@implementation M_TableViewDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        _rows = [NSMutableArray array];
    }
    return self;
}

- (void)addRow:(M_TableRow*)row {
    NSMutableArray *valuesArray = [NSMutableArray array];
    for (int i = 0; i < row->columnCount; i++) { // Use columnCount instead of NULL check
        [valuesArray addObject:[NSString stringWithUTF8String:row->values[i]]];
    }
    [self.rows addObject:valuesArray];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.rows.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *values = self.rows[row];
    NSInteger columnIndex = [[tableView tableColumns] indexOfObject:tableColumn];
    return values[columnIndex];
}

- (M_TableRow *)getRowAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.rows.count) {
        return NULL; // Return NULL if index is out of bounds
    }
    
    NSArray *valuesArray = self.rows[index];
    M_TableRow *row = malloc(sizeof(M_TableRow)); // Allocate memory for the row
    row->columnCount = (int)valuesArray.count; // Set the column count
    row->values = malloc(sizeof(char *) * row->columnCount); // Allocate memory for the values
    
    for (int i = 0; i < row->columnCount; i++) {
        NSString *value = valuesArray[i];
        row->values[i] = strdup([value UTF8String]); // Copy the value
    }
    
    return row; // Return the populated row
}


- (NSString*)getDataAtRow:(NSInteger)row column:(NSInteger)column {
    M_TableRow* tableRow = [self getRowAtIndex:row];
    if (tableRow && column < tableRow->columnCount) { // Now this line makes sense
        return [NSString stringWithUTF8String:tableRow->values[column]];
    }
    return nil;
}

- (void)setDataAtRow:(NSInteger)row column:(NSInteger)column value:(NSString*)value {
    M_TableRow* tableRow = [self getRowAtIndex:row];
    if (tableRow && column < tableRow->columnCount) { // And this line too
        free(tableRow->values[column]); // Free the old value
        tableRow->values[column] = strdup([value UTF8String]); // Set the new value
    }
}

@end

static NSTableView* getNSTableViewFromMacView(M_View* tableView) {
    if (tableView == NULL || tableView->type != M_VIEW_TYPE_TABLE) {
        NSLog(@"Error: Invalid table view");
        return NULL;
    }
    return (__bridge NSTableView *)(tableView->view.t_view._this);
}

void M_CreateTable(M_View* tableView, M_TableColumn* columns, int columnCount) {
    NSTableView* nsTableView = getNSTableViewFromMacView(tableView);
    if (nsTableView == NULL) return;

    // Calculate the width for each column
    float columnWidth = (float)tableView->view.t_view.size.width / columnCount;

    // Create columns
    for (int i = 0; i < columnCount; i++) {
        NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithUTF8String:columns[i].title]];
        [column setWidth:columnWidth]; // Set the calculated width
        [column.headerCell setStringValue:[NSString stringWithUTF8String:columns[i].title]];
        [nsTableView addTableColumn:column];
    }

    [nsTableView setWantsLayer:YES];
    // [nsTableView.layer setBackgroundColor:[NSColor darkGrayColor].CGColor];
    [nsTableView setNeedsDisplay:YES];

    // Set the data source and delegate
    M_TableViewDataSource *dataSource = [[M_TableViewDataSource alloc] init];
    [nsTableView setDataSource:dataSource];
    [nsTableView setDelegate:dataSource];
    

    [nsTableView setHeaderView:[[NSTableHeaderView alloc] initWithFrame:NSMakeRect(0, 0, tableView->view.t_view.size.width, 18)]];

    [nsTableView reloadData];
}

void M_AddRowToTable(M_View* tableView, M_TableRow* row) {
    NSTableView* nsTableView = getNSTableViewFromMacView(tableView);
    if (nsTableView == NULL) return;

    // Assuming the data source is set for the table view
    M_TableViewDataSource* dataSource = (M_TableViewDataSource*)[nsTableView dataSource];

    // Add the row data to the data source
    [dataSource addRow:row];

    // Reload the table view to reflect the changes
    [nsTableView reloadData];
}

MData M_GetDataAtRowAndColumn(M_View* tableView, int row, int column) {
    NSTableView* nsTableView = getNSTableViewFromMacView(tableView);
    if (nsTableView == NULL) return NULL;

    M_TableViewDataSource* dataSource = (M_TableViewDataSource*)[nsTableView dataSource];
    NSString* value = [dataSource getDataAtRow:row column:column];
    return [value UTF8String];
}

void M_SetDataAtRowAndColumn(M_View* tableView, int row, int column, MData value) {
    NSTableView* nsTableView = getNSTableViewFromMacView(tableView);
    if (nsTableView == NULL) return;

    M_TableViewDataSource* dataSource = (M_TableViewDataSource*)[nsTableView dataSource];
    NSString* newValue = [NSString stringWithUTF8String:value];
    [dataSource setDataAtRow:row column:column value:newValue];
}
