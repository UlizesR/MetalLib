#import "MKLTypes.h"

@implementation MklDefs

+ (MKLVertex *)cubeVertices {
    static MKLVertex cubeVertices[] = {
        {.position = {-1.0f, -1.0f,  1.0f, 1.0f}},
        {.position = { 1.0f, -1.0f,  1.0f, 1.0f}},
        {.position = { 1.0f,  1.0f,  1.0f, 1.0f}},
        {.position = {-1.0f,  1.0f,  1.0f, 1.0f}},
        {.position = {-1.0f,  1.0f, -1.0f, 1.0f}},
        {.position = {-1.0f, -1.0f, -1.0f, 1.0f}},
        {.position = { 1.0f, -1.0f, -1.0f, 1.0f}},
        {.position = { 1.0f,  1.0f, -1.0f,  1.0f}}
    };
    return cubeVertices;
}

+ (ushort *)cubeIndices
{
    static ushort cubeIndices[] = {
        0, 2, 3,0, 1, 2,
        1, 7, 2, 1, 6, 7,
        6, 5, 4, 4, 7, 6,
        3, 4, 5, 3, 5, 0,
        3, 7, 4, 3, 2, 7,
        0, 6, 1, 0, 5, 6
    };
    return cubeIndices;
}

@end