#ifndef _mcl_table_h_
#define _mcl_table_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"

#ifdef __cplusplus
extern "C" {
#endif

// Structure to represent a table column
typedef struct {
  const char *name;
} MCL_TableColumn;

// Structure to represent a table row
typedef struct {
  const char **values;
  int columnCount; // Add this line
} MCL_TableRow;

/*!
    * @brief creates a table view and adds it to the parent view
    * @param tableFrame the table view to create
    * @param columns the columns of the table view
    * @param columnCount the number of columns
    * @param x the x position of the table view
    * @param y the y position of the table view
    * @param w the width of the table view
    * @param h the height of the table view
*/
void MCL_AddTable(MCL_Frame *frame, MCL_Frame *tableFrame, MCL_TableColumn *columns, int columnCount, int x, int y, int width, int height);

/*!
    * @brief creates a table row
    * @param tableFrame the table view to create the row in
    * @param row the row to create
*/
void MCL_AddRow(MCL_Frame *tableFrame, MCL_TableRow *row);

/*!
    * @brief creates a table column
    * @param tableFrame the table view to create the column in
    * @param column the column to create
*/
void MCL_AddColumn(MCL_Frame *tableFrame, MCL_TableColumn *column);

/*!
    * @brief removes a row from the table
    * @param tableFrame the table view to remove the row from
    * @param row the row to remove
*/
void MCL_RemoveRow(MCL_Frame *tableFrame, MCL_TableRow *row);

/*!
    * @brief removes a column from the table
    * @param tableFrame the table view to remove the column from
    * @param column the column to remove
*/
void MCL_RemoveColumn(MCL_Frame *tableFrame, MCL_TableColumn *column);

/*!
    * @brief returns the data at a specific row and column
    * @param tableFrame the table view to get the data from
    * @param row the row to get the data from
    * @param column the column to get the data from
*/
const char* MCL_GetDataAtRowAndColumn(MCL_Frame *tableFrame, MCL_TableRow *row, MCL_TableColumn *column); // Changed return type to MData

/*!
    * @brief sets the data at a specific row and column
    * @param tableFrame the table view to set the data in
    * @param row the row to set the data in
    * @param column the column to set the data in
    * @param value the value to set the data to
*/
void MCL_SetDataAtRowAndColumn( MCL_Frame *tableFrame, MCL_TableRow *row, MCL_TableColumn *column, const char *value); // Changed parameter type to const char*

#ifdef __cplusplus
}
#endif

#endif // _mcl_table_h_