#include <MACA/maca.h>
#include <stdio.h>

// Create a struct to hold the text control data
typedef struct {
    Mac_Text* text;
    int count;
    Mac_Button* buttonPlus;
    Mac_Button* buttonMinus;
} TextControl;

// Function that increments the count and updates the text
void button_click(Mac_Button* button, void* user_data)
{
    // Get the user data
    TextControl* control = (TextControl*)user_data;
    // Increment the count
    control->count++;
    // Convert the count to a string
    char newText[50];
    snprintf(newText, sizeof(newText), "Count: %d", control->count);
    // Update the text object with the new count
    MAC_UpdateText(control->text, newText); 
}

// Function that decrements the count and updates the text
void button_click2(Mac_Button* button, void* user_data)
{
    // Get the user data
    TextControl* control = (TextControl*)user_data;
    // Decrement the count
    control->count--;
    // Convert the count to a string
    char newText[50];
    snprintf(newText, sizeof(newText), "Count: %d", control->count);
    // Update the text object with the new count
    MAC_UpdateText(control->text, newText); 
}

int main(int argc, const char * argv[])
{
    // Initialize the application
    if(MAC_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }
    // Create a window and content view
    Mac_Window* mainWindow = MAC_CreateWindow(200, 200, true, "Main Window", 0);
    Mac_View* contentView = MAC_AddContentView(mainWindow, MAC_COLOR_BLACK, MAC_VIEW_TYPE_NORMAL, NULL);
    // Create a text control struct
    TextControl textControl;
    textControl.count = 0;
    char initialText[50];
    snprintf(initialText, sizeof(initialText), "Count: %d", textControl.count);
    // Create a text object
    Mac_Text* text = MAC_AddText(contentView, (MPoint){50, 140},(MSize){100,25}, MAC_COLOR_CYAN, initialText, 20);
    textControl.text = text;
    // Create two buttons
    Mac_Button* button = MAC_ButtonRS((MSize){100, 25}, (MPoint){50, 55}, "", "count +", MAC_BUTTON_TYPE_MOMENTARY_PUSH_IN, 20, true, false, contentView, button_click, &textControl);
    textControl.buttonPlus = button;
    Mac_Button* button2 = MAC_ButtonRS((MSize){100, 25}, (MPoint){50, 25}, "", "count -", MAC_BUTTON_TYPE_MOMENTARY_PUSH_IN, 20, true, false, contentView, button_click2, &textControl);
    textControl.buttonMinus = button2;

    // Main loop
    bool running = true;
    MAC_Event event;
    while (running) {
        // causes window to remain open
        while (MAC_PollEvent(&event) != 0) { // Poll for events
            // do event handling
        }
        // Check if the window is still open
        if (!isWindowOpen(mainWindow)) {
            running = false;
        }
    }

    // Clean up
    MAC_DestroyView(contentView);
    MAC_DestroyWindow(mainWindow);
    MAC_Quit();
    return 0;
}