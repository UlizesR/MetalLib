#include <MACA/maca.h>
#include <stdio.h>

// Create a struct to hold the text control data
typedef struct {
    M_Text* text;
    int count;
    M_Button* buttonPlus;
    M_Button* buttonMinus;
} TextControl;

// Function that increments the count and updates the text
void button_click(M_Button* button, void* user_data)
{
    // Get the user data
    TextControl* control = (TextControl*)user_data;
    // Increment the count
    control->count++;
    // Convert the count to a string
    char newText[50];
    snprintf(newText, sizeof(newText), "Count: %d", control->count);
    // Update the text object with the new count
    M_UpdateText(control->text, newText); 
}

// Function that decrements the count and updates the text
void button_click2(M_Button* button, void* user_data)
{
    // Get the user data
    TextControl* control = (TextControl*)user_data;
    // Decrement the count
    control->count--;
    // Convert the count to a string
    char newText[50];
    snprintf(newText, sizeof(newText), "Count: %d", control->count);
    // Update the text object with the new count
    M_UpdateText(control->text, newText); 
}

int main(int argc, const char * argv[])
{
    // Initialize the application
    if(M_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }
    // Create a window and content view
    M_Window* mainWindow = M_CreateWindow(200, 200, true, "Main Window", 0);
    M_View* contentView = M_AddContentView(mainWindow, M_COLOR_BLACK, M_VIEW_TYPE_NORMAL, NULL);
    // Create a text control struct
    TextControl textControl;
    textControl.count = 0;
    char initialText[50];
    snprintf(initialText, sizeof(initialText), "Count: %d", textControl.count);
    // Create a text object
    M_Text* text = M_AddText(contentView, (MPoint){50, 140},(MSize){100,25}, M_COLOR_CYAN, initialText, 20);
    textControl.text = text;
    // Create two buttons
    M_Button* button = M_ButtonRS((MSize){100, 25}, (MPoint){50, 55}, "", "count +", M_BUTTON_TYPE_MOMENTARY_PUSH_IN, 20, true, false, contentView, button_click, &textControl);
    textControl.buttonPlus = button;
    M_Button* button2 = M_ButtonRS((MSize){100, 25}, (MPoint){50, 25}, "", "count -", M_BUTTON_TYPE_MOMENTARY_PUSH_IN, 20, true, false, contentView, button_click2, &textControl);
    textControl.buttonMinus = button2;

    // Main loop
    bool running = true;
    M_Event event;
    while (running) {
        // causes window to remain open
        while (M_PollEvent(&event) != 0) { // Poll for events
            // do event handling
        }
        // Check if the window is still open
        if (!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    // Clean up
    M_DestroyView(contentView);
    M_DestroyWindow(mainWindow);
    M_Quit();
    return 0;
}