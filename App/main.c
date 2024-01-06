#include <MKL.h>

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
    printf("Hello World!\n");

    MKLWindow *window = MKLCreateWindow(800, 600, "MKL Window");

    if (window == NULL)
    {
        printf("Failed to create window!\n");
        return 1;
    }

    MKLShowWindow(window);

    MKLDestroyWindow(window);
    
    return 0;
}