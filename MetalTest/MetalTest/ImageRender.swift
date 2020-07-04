//
//  ImageRender.swift
//  MetalTest
//
//  Created by dzq_mac on 2020/7/1.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import MetalKit


let imageName:String = "hulu.jpg"
struct VertexTexture {
    var vex:vector_float2
    var tex:vector_float2
}
class ImageRender: NSObject {
    var view : MTKView
    var commandQueue : MTLCommandQueue?
    var device :MTLDevice
    var pipelineState:MTLRenderPipelineState?
    var viewSize :CGSize = CGSize.zero
    
    var vertexBuffer :MTLBuffer?
    var vertexIndex:MTLBuffer?
    var texture:MTLTexture?
    var loadtga:Bool = false
    init(view:MTKView,loadTga:Bool = false) {
        self.view = view
        self.device = view.device!
        self.commandQueue = device.makeCommandQueue()!
        super.init()
        view.preferredFramesPerSecond = 60
        viewSize = view.drawableSize
        
        setUpPipeLineState()
       
        setUpVertex()
        
        setUpImageTexture(loadTga:loadTga)
        
    }

    func setUpPipeLineState() {
        var library = try? device.makeDefaultLibrary()
        if let url = Bundle.main.url(forResource: "TextureRender", withExtension: "metal"){
            library = try? device.makeLibrary(URL: url)
        }
        
        let vfunc:MTLFunction? = library?.makeFunction(name: "vertexShader1")
        let fFunc:MTLFunction? = library?.makeFunction(name: "fragmentShader1")
        
        let description = MTLRenderPipelineDescriptor()
        description.vertexFunction = vfunc
        description.fragmentFunction = fFunc
        description.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: description)
        } catch let error {
            print(error.localizedDescription)
            
        }
        
        commandQueue = device.makeCommandQueue()
    }
    
    func setUpVertex() {
        let vertexTex:[VertexTexture] = [
            VertexTexture(vex: vector_float2(1, -1), tex: vector_float2(1, 0)),
            VertexTexture(vex: vector_float2(-1, -1), tex: vector_float2(0, 0)),
            VertexTexture(vex: vector_float2(-1, 1), tex: vector_float2(0, 1)),
            
//            VertexTexture(vex: vector_float2(1, -1), tex: vector_float2(1, 0)),
//            VertexTexture(vex: vector_float2(-1, 1), tex: vector_float2(0, 1)),
            VertexTexture(vex: vector_float2(1, 1), tex: vector_float2(1, 1)),
        ]
        vertexBuffer = device.makeBuffer(bytes: vertexTex, length: MemoryLayout<VertexTexture>.size * vertexTex.count, options: MTLResourceOptions.storageModeShared)
        
        func scaleShowImage(){
            var vertexs:[Float] = [
                1,-1,  1,0,
                -1,-1, 0,0,
                -1,1,  0,1,
                1,1,   1,1
            ]
            var imageScale:(CGFloat,CGFloat) = (1,1)
            if let image = UIImage(named: imageName)?.cgImage {
                let width = image.width
                let height = image.height
                       
                let scaleF = CGFloat(view.frame.height)/CGFloat(view.frame.width)
                let scaleI = CGFloat(height)/CGFloat(width)
                       
                imageScale = scaleF>scaleI ? (1,scaleI/scaleF) : (scaleI/scaleF,1)
            }
            for (i,v) in vertexs.enumerated(){
                if i % 4 == 0 {
                    vertexs[i] = v * Float(imageScale.0)
                }
                if i % 4 == 1{
                    vertexs[i] = v * Float(imageScale.1)
                }

            }
            vertexBuffer = device.makeBuffer(bytes: vertexs, length: MemoryLayout<Float>.size * vertexs.count, options: MTLResourceOptions.storageModeShared)
        }
        //按图片比例显示
        scaleShowImage()
        
        //索引绘图
        let index:[Int32] = [
            0,1,2,
            0,2,3
        ]
        vertexIndex = device.makeBuffer(bytes: index, length: MemoryLayout<Int32>.size * 6, options: .storageModeShared)
        
        
    }
    func setUpImageTexture(loadTga:Bool = false) {
        var imageSoruce = UIImage(named: imageName)
        if loadTga {
            let url = Bundle.main.url(forResource: "Image", withExtension: "tga")
            imageSoruce = self.tgaTOImage(url: url!)
        }
        
        guard let image = imageSoruce?.cgImage else {
            return
        }
        
        let width = image.width
        let height = image.height
        
        //开辟内存，绘制到这个内存上去
        let spriteData: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        //获取context
        let spriteContext = CGContext(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
        spriteContext?.translateBy(x:0 , y: CGFloat(height))
        spriteContext?.scaleBy(x: 1, y: -1)
        spriteContext?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        UIGraphicsEndImageContext()
        
//        spriteData
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm //MTLPixelFormatRGBA8Unorm defoat
        textureDescriptor.width = image.width
        textureDescriptor.height = image.height
        texture = device.makeTexture(descriptor: textureDescriptor)
        
        texture?.replace(region: MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: image.width, height: image.height, depth: 1)), mipmapLevel: 0, withBytes: spriteData, bytesPerRow: 4 * image.width)
        
        free(spriteData)
    }
    
    
    func tgaTOImage(url:URL) -> UIImage? {
        if url.pathExtension.caseInsensitiveCompare("tga") != .orderedSame {
            return nil
        }
        guard let fileData = try? Data.init(contentsOf: url) else {
            print("打开tga文件失败！")
            return nil
        }
        let image = UIImage(data: fileData)
        return image
    }
    
}
extension ImageRender:MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let queue = commandQueue,
            let buffer = queue.makeCommandBuffer(),
            let renderPassDiscriptor = view.currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDiscriptor),
            let pipeState = pipelineState
            
            else {
                return
        }
        
        
        encoder.label = "renderEncoder"
        encoder.setRenderPipelineState(pipeState)
        
        encoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewSize.width), height: Double(viewSize.height), znear: -1, zfar: 1))
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        encoder.setFragmentTexture(texture, index: 0)
        
//        encoder.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 6)//不实用索引绘图绘制
        encoder.drawIndexedPrimitives(type: .triangleStrip, indexCount: 6, indexType: .uint32, indexBuffer: vertexIndex!, indexBufferOffset: 0)//使用索引绘图绘制
        
        encoder.endEncoding()
        
        buffer.present(view.currentDrawable!)
        
        buffer.commit()
        
    }
    
    
}
