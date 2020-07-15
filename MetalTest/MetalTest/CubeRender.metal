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
    float4 position;
    float4 textureCoord;
    float4 color;
}VertexIn;
typedef struct {
    
    float4 clipSpacePosition [[position]];
    float2 textureCoord;
    float4 color;
    
}VertexOut;

typedef struct {
    float4x4 persMatrix;
    float4x4 mvMatrix;
    
}MvpMatrix;

vertex VertexOut cubeVertexShader(uint vertexIndex [[vertex_id]], constant VertexIn *ver [[buffer(0)]],constant MvpMatrix *matrixs [[buffer(1)]]){
    
    VertexOut out;
    out.textureCoord = ver[vertexIndex].textureCoord.xy;
    out.clipSpacePosition = ver[vertexIndex].position;

    out.clipSpacePosition =  matrixs->persMatrix * matrixs->mvMatrix * out.clipSpacePosition;
    
    out.color = ver[vertexIndex].color;
    
    return out;
}

fragment float4 cubeFragmentShader(VertexOut in [[stage_in]],texture2d<float> texture [[texture(0)]]){
    
    
    constexpr sampler cubeSampler(mag_filter::linear,min_filter::linear);
    return  texture.sample(cubeSampler, in.textureCoord);
//    return float4(0,1,0,1);
//    return in.color;
    
}
