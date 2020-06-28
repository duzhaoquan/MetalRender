//
//  DzqRender.swift
//  MetalTest
//
//  Created by dzq_mac on 2020/6/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import MetalKit

struct Color {
    var red   :Double = 0
    var green :Double = 0
    var blue  :Double = 0
    var alpha :Double = 0
    
}
class DzqRender: NSObject {
    var view : MTKView
    var commandQueue : MTLCommandQueue
    var device :MTLDevice
    
    
    init(view:MTKView) {
        self.view = view
        self.device = view.device!
        self.commandQueue = device.makeCommandQueue()!
        super.init()
        
        view.preferredFramesPerSecond = 60
    }
    //1. 增加颜色/减小颜色的 标记
     var growing = true;
    //2.颜色通道值(0~3)
     var primaryChannel = 0;
    //3.颜色通道数组colorChannels(颜色值)
     var colorChannels = [1.0, 0.0, 0.0, 1.0]
    //设置颜色
    //4.颜色调整步长
    let  DynamicColorRate = 0.015;
    func makeFancyColor() -> Color
    {
        //5.判断
        if(growing)
        {
            //动态信道索引 (1,2,3,0)通道间切换
            let  dynamicChannelIndex = (primaryChannel+1)%3;
            
            //修改对应通道的颜色值 调整0.015
            colorChannels[dynamicChannelIndex] += DynamicColorRate;
            
            //当颜色通道对应的颜色值 = 1.0
            if(colorChannels[dynamicChannelIndex] >= 1.0)
            {
                //设置为NO
                growing = false;
                
                //将颜色通道修改为动态颜色通道
                primaryChannel = dynamicChannelIndex;
            }
        }
        else
        {
            //获取动态颜色通道
            let  dynamicChannelIndex = (primaryChannel+2)%3;
            
            //将当前颜色的值 减去0.015
            colorChannels[dynamicChannelIndex] -= DynamicColorRate;
            
            //当颜色值小于等于0.0
            if(colorChannels[dynamicChannelIndex] <= 0.0)
            {
                //又调整为颜色增加
                growing = true;
            }
        }
        
        //创建颜色
        var color = Color()
        
        //修改颜色的RGBA的值
        color.red   = colorChannels[0]
        color.green = colorChannels[1]
        color.blue  = colorChannels[2]
        color.alpha = colorChannels[3]
        
        //返回颜色
        return color;
    }
}
extension DzqRender : MTKViewDelegate{
    // 当MTKView视图发生大小改变时调用
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        
    }
    //每当视图需要渲染时调用
    func draw(in view: MTKView) {
        let color = makeFancyColor()
        view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha)
        //为当前渲染的每个渲染传递创建一个新的命令缓冲区
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "buffer"
        //5.判断renderPassDescriptor 渲染描述符是否创建成功,否则则跳过任何渲染.
        if let passDescriptor = view.currentRenderPassDescriptor {
            let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor)
            //7.我们可以使用MTLRenderCommandEncoder 来绘制对象,但是这个demo我们仅仅创建编码器就可以了,我们并没有让Metal去执行我们绘制的东西,这个时候表示我们的任务已经完成.
            //即可结束MTLRenderCommandEncoder 工作
            renderEncoder?.endEncoding()
            /*
             当编码器结束之后,命令缓存区就会接受到2个命令.
             1) present
             2) commit
             因为GPU是不会直接绘制到屏幕上,因此你不给出去指令.是不会有任何内容渲染到屏幕上.
            */
            //8.添加一个最后的命令来显示清除的可绘制的屏幕
            commandBuffer?.present(view.currentDrawable!)
        }
        //9.在这里完成渲染并将命令缓冲区提交给GPU
        commandBuffer?.commit()
        
    }
    
    
}
