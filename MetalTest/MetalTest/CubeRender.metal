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
    float2 textureCoord;
//    float4 color;
}VertexIn;
typedef struct {
    
    float4 clipSpacePosition [[position]];
    float2 textureCoord;
//    float4 color;
    
}VertexOut;

typedef struct {
    float4x4 persMatrix;
    float4x4 mvMatrix;
    
}MvpMatrix;


vertex VertexOut cubeVertexShader(uint vertexIndex [[vertex_id]], constant VertexIn *ver [[buffer(0)]],constant MvpMatrix *matrixs [[buffer(1)]]){
    
    VertexOut out;
//    out.clipSpacePosition = vector_float4(0.0,0.0,0.0,1);
    out.textureCoord = ver[vertexIndex].textureCoord;
    out.clipSpacePosition = ver[vertexIndex].position;
    if (vertexIndex == 4){
        out.clipSpacePosition = float4(0,0,0.8,1);
        out.textureCoord = float2(0.5,0.5);

    }
    if(vertexIndex == 3){
        out.clipSpacePosition = float4(0.5,-0.5,0,1);
        out.textureCoord = float2(1,0);
    }
    out.clipSpacePosition =  matrixs->persMatrix * matrixs->mvMatrix * out.clipSpacePosition;
    
//    out.color = ver[vertexIndex].color;
    
    return out;
}

fragment float4 cubeFragmentShader(VertexOut in [[stage_in]],texture2d<float> texture [[texture(0)]]){
    
    
    constexpr sampler cubeSampler(mag_filter::linear,min_filter::linear);
    return  texture.sample(cubeSampler, in.textureCoord);
//    return float4(0,1,0,1);
    
}
