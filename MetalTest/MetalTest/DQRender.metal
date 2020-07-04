//
//  DQRender.metal
//  MetalTest
//
//  Created by dzq_mac on 2020/7/1.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

#include <metal_stdlib>
//#include "DQRenderType.swift"
using namespace metal;

typedef struct
{
    float2 position;
    float4 color;
} VertexIn;

typedef struct {
    
    float4 clipSpacePosition [[position]];
    
    float4 color;
    
} RasterizerData;


vertex RasterizerData vertexShader(uint vertexid [[vertex_id]],constant VertexIn *vertexColor [[buffer(0)]]){
    RasterizerData out;
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);
    
    out.clipSpacePosition.xy = vertexColor[vertexid].position;
//    out.clipSpacePosition.y = vertexColor[vertexid + 1];
    out.color = vertexColor[vertexid].color;
//    out.color.r = vertexColor[vertexid + 2];
//    out.color.g = vertexColor[vertexid + 3];
//    out.color.b = vertexColor[vertexid + 4];
//    out.color.a = vertexColor[vertexid + 5];
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]]){
    return in.color;
}
