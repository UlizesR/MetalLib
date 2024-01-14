#ifndef _MKL_LIBRARIES_H_
#define _MKL_LIBRARIES_H_

#include "MKLRenderer.h"

void MKLShaderLib(MKLRenderer *renderer, const char *shaderPath);

void MKLRenderPipelineLib(MKLRenderer *renderer);

void MKLVertexDescriptorLib(MKLRenderer *renderer);

void MKLDepetStencilStateLib(MKLRenderer *renderer);

#endif // _MKL_LIBRARIES_H_