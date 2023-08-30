#include "maths.h"

void AddVector2(Vector2 *v1, Vector2 *v2, Vector2 *result)
{
    result->x = v1->x + v2->x;
    result->y = v1->y + v2->y;
}

void AddVector3(Vector3 *v1, Vector3 *v2, Vector3 *result)
{
    result->x = v1->x + v2->x;
    result->y = v1->y + v2->y;
    result->z = v1->z + v2->z;
}

void AddVector4(Vector4 *v1, Vector4 *v2, Vector4 *result)
{
    result->x = v1->x + v2->x;
    result->y = v1->y + v2->y;
    result->z = v1->z + v2->z;
    result->w = v1->w + v2->w;
}


void SubtractVector2(Vector2 *v1, Vector2 *v2, Vector2 *result)
{
    result->x = v1->x - v2->x;
    result->y = v1->y - v2->y;
}

void SubtractVector3(Vector3 *v1, Vector3 *v2, Vector3 *result)
{
    result->x = v1->x - v2->x;
    result->y = v1->y - v2->y;
    result->z = v1->z - v2->z;
}

void SubtractVector4(Vector4 *v1, Vector4 *v2, Vector4 *result)
{
    result->x = v1->x - v2->x;
    result->y = v1->y - v2->y;
    result->z = v1->z - v2->z;
    result->w = v1->w - v2->w;
}   

void DotProductVector2(Vector2 *v1, Vector2 *v2, float result)
{
    result = (v1->x * v2->x) + (v1->y * v2->y);
}

void DotProductVector3(Vector3 *v1, Vector3 *v2, float result)
{
    result = (v1->x * v2->x) + (v1->y * v2->y) + (v1->z * v2->z);
}

void DotProductVector4(Vector4 *v1, Vector4 *v2, float result)
{
    result = (v1->x * v2->x) + (v1->y * v2->y) + (v1->z * v2->z) + (v1->w * v2->w);
}


void CrossProductVector3(Vector3 *v1, Vector3 *v2, Vector3 *result)
{
    result->x = (v1->y * v2->z) - (v1->z * v2->y);
    result->y = (v1->z * v2->x) - (v1->x * v2->z);
    result->z = (v1->x * v2->y) - (v1->y * v2->x);
}


void MultiplyVector2(Vector2 *v1, float scalar, Vector2 *result)
{
    result->x = v1->x * scalar;
    result->y = v1->y * scalar;
}

void MultiplyVector3(Vector3 *v1, float scalar, Vector3 *result)
{
    result->x = v1->x * scalar;
    result->y = v1->y * scalar;
    result->z = v1->z * scalar;
}   

void MultiplyVector4(Vector4 *v1, float scalar, Vector4 *result)
{
    result->x = v1->x * scalar;
    result->y = v1->y * scalar;
    result->z = v1->z * scalar;
    result->w = v1->w * scalar;
}


void MultiplyMatrix2x1(Matrix2x1 *m1, float scalar, Matrix2x1 *result)
{
    MultiplyVector2(&m1->v, scalar, &result->v);
}

void MultiplyMatrix2x2(Matrix2x2 *m1, float scalar, Matrix2x2 *result)
{
    MultiplyVector2(&m1->v1, scalar, &result->v1);
    MultiplyVector2(&m1->v2, scalar, &result->v2);
}

void MultiplyMatrix2x3(Matrix2x3 *m1, float scalar, Matrix2x3 *result)
{
    MultiplyVector3(&m1->v1, scalar, &result->v1);
    MultiplyVector3(&m1->v2, scalar, &result->v2);
    
}

void MultiplyMatrix3x1(Matrix3x1 *m1, float scalar, Matrix3x1 *result)
{

}

void MultiplyMatrix3x2(Matrix3x2 *m1, float scalar, Matrix3x2 *result)
{

}

void MultiplyMatrix3x3(Matrix3x3 *m1, float scalar, Matrix3x3 *result)
{

}


void MultiplyMatrix4x1(Matrix4x1 *m1, float scalar, Matrix4x1 *result)
{

}

void MultiplyMatrix4x4(Matrix4x4 *m1, float scalar, Matrix4x4 *result)
{

}


void MultiplyMatrix2x1Vector2(Matrix2x1 *m1, Vector2 *v1, Vector2 *result)
{

}

void MultiplyMatrix2x2Vector2(Matrix2x2 *m1, Vector2 *v1, Vector2 *result)
{

}

void MultiplyMatrix2x3Vector3(Matrix2x3 *m1, Vector3 *v1, Vector3 *result)
{

}


void MultiplyMatrix3x1Vector3(Matrix3x1 *m1, Vector3 *v1, Vector3 *result)
{

}

void MultiplyMatrix3x2Vector3(Matrix3x2 *m1, Vector3 *v1, Vector3 *result)
{

}

void MultiplyMatrix3x3Vector3(Matrix3x3 *m1, Vector3 *v1, Vector3 *result)
{

}


void MultiplyMatrix4x1Vector4(Matrix4x1 *m1, Vector4 *v1, Vector4 *result)
{

}

void MultiplyMatrix4x4Vector4(Matrix4x4 *m1, Vector4 *v1, Vector4 *result)
{

}
