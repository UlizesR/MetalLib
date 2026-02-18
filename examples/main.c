/**
 * Guli example: create window, ESC to close.
 *
 * Build: cd build && cmake .. && make guli_test
 * Run: ./bin/guli_test
 */
#include <guli/guli.h>

int main(void)
{
    if (GuliInit(800, 600, "Guli Window - Press ESC to close") != GULI_ERROR_SUCCESS)
        return 1;

    while (!GuliWindowShouldClose())
    {
        GuliPollEvents();
        if (GuliGetKey(GULI_KEY_ESCAPE) == GULI_PRESS)
            GuliSetWindowShouldClose(1);

        GuliBeginDraw();
        GuliClearColor(GULI_COLOR_BLUE);
        GuliEndDraw();
    }

    GuliShutdown();
    if (G_State.error.result != GULI_ERROR_SUCCESS)
        GULI_PRINT_ERROR(G_State.error.result, G_State.error.message);
    return 0;
}
