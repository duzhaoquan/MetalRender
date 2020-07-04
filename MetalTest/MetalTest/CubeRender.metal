//
//  cubeRender.metal
//  MetalTest
//
//  Created by dzq_mac on 2020/7/2.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct{
    float3 position;
    float2 textureCoord;
}VertexIn;
typedef struct {
    
    float4 clipSpacePosition [[position]];
    
    float2 color;
    
}VertexOut;


vertex VertexOut cubeVertexShader(uint vertexIndex [[vertex_id]], constant VertexIn *ver [[buffer(0)]],constant float4x4 *matrixs [[buffer(1)]]){
    
    VertexOut out;
    out.clipSpacePosition = vector_float4(0.0,0.0,0.0,1);
    out.clipSpacePosition.xyz = ver[vertexIndex].position;
//    out.clipSpacePosition =  matrixs[0] * matrixs[1] * out.clipSpacePosition;
    out.color = ver[vertexIndex].textureCoord;
    
    return out;
}

fragment float4 cubeFragmentShader(VertexOut in [[stage_in]],texture2d<float> texture [[texture(0)]]){
    
    
    constexpr sampler cubeSampler(mag_filter::linear,min_filter::linear);
//    return  texture.sample(cubeSampler, in.color);
    return float4(0,1,0,1);
    
}
