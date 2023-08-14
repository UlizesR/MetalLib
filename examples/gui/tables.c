#include "MACA/mac_colors.h"
#include "MACA/mac_tables.h"
#include <MACA/maca.h>
#include <stdio.h>

int main(int argc, const char * argv[]) {
    // Initialize the application
    if(M_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }
    printf("MACA Initialized\n");
    M_Window* mainWindow = M_CreateWindow(800, 600, true, "Main Window", 0);
    printf("Window Created\n");
    M_View* contentView = M_AddContentView(mainWindow, M_COLOR_TRANSPARENT, M_VIEW_TYPE_TABLE, NULL);
    printf("content view Created\n");

    // Define columns (width will be calculated inside M_CreateTable)
    M_TableColumn columns[] = {
        {"Name"},
        {"Age"},
        {"Occupation"}
    };
    int columnCount = sizeof(columns) / sizeof(columns[0]);

    // Create the table with the defined columns
    M_CreateTable(contentView, columns, columnCount);
    printf("Columns Created\n");

    // Add some rows to the table
    M_TableRow row1 = { (char*[]){"Alice", "30", "Engineer", NULL}, 3 }; 
    M_TableRow row2 = { (char*[]){"Bob", "25", "Doctor", NULL}, 3 }; 
    M_TableRow row3 = { (char*[]){"Charlie", "20", "Student", NULL}, 3 };
    M_TableRow row4 = { (char*[]){"Diane", "35", "Lawyer", NULL}, 3 };
    M_TableRow row5 = { (char*[]){"Eve", "40", "Teacher", NULL}, 3 };
    M_TableRow row6 = { (char*[]){"Frank", "45", "Pilot", NULL}, 3 };
    M_AddRowToTable(contentView, &row1);
    M_AddRowToTable(contentView, &row2);
    M_AddRowToTable(contentView, &row3);
    M_AddRowToTable(contentView, &row4);
    M_AddRowToTable(contentView, &row5);
    M_AddRowToTable(contentView, &row6);
    printf("Rows Added\n");

    MData data = M_GetDataAtRowAndColumn(contentView, 1, 2);
    printf("Data at row 1, column 2: %s\n", (char*)data);

    bool running = true;
    M_Event event;
    while (running) {
        // causes window to remain open
        while (M_PollEvent(&event) != 0) { // Poll for events
            // do event handling
        }
        // Check if the window is still open
        if (!isWindowOpen(mainWindow)) { // Assuming you have this function defined
            running = false;
        }
    }

    // Clean up the table
    M_DestroyView(contentView);
    M_DestroyWindow(mainWindow);
    M_Quit();

    return 0;
}
