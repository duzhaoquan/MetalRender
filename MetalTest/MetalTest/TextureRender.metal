//
//  TextureRender
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
    float2 color;
} VertexIn;

typedef struct {
    
    float4 clipSpacePosition [[position]];
    
    float2 color;
    
} RasterizerData;


vertex RasterizerData vertexShader1(uint vertexid [[vertex_id]],constant VertexIn *vertexColor [[buffer(0)]]){
    RasterizerData out;
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);
    
    out.clipSpacePosition.xy = vertexColor[vertexid].position;

    out.color = vertexColor[vertexid].color;

    
    return out;
}

fragment float4 fragmentShader1(RasterizerData in [[stage_in]],texture2d<float> texture [[texture(0)]]){
    
    constexpr sampler textureSampler234(mag_filter::linear,min_filter::linear);
    float4 color = texture.sample(textureSampler234, in.color) * 0.7 + float4(1,0,0,1) * 0.3;
    return color;
}
