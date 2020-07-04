//
//  CubeRender.swift
//  MetalTest
//
//  Created by dzq_mac on 2020/7/2.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import MetalKit
import GLKit
struct CubeVertexTexture {
    var vex:vector_float3
    var tex:vector_float2
}
class CubeRender: NSObject {
    var view : MTKView
    var commandQueue : MTLCommandQueue?
    var device :MTLDevice
    var pipelineState:MTLRenderPipelineState?
    var viewSize :CGSize = CGSize.zero
    
    var vertexBuffer :MTLBuffer?
    var vertexIndex:MTLBuffer?
    var texture:MTLTexture?
    var indexCount :Int = 0
    
    var switchX,switchY,switchZ :UISwitch
    
    
    
    init(view:MTKView) {
        self.view = view
        self.device = view.device!
        self.commandQueue = device.makeCommandQueue()!
        switchX = UISwitch(frame: CGRect(x: 10 , y: view.frame.size.height - 100, width: 100, height: 60))
        switchY = UISwitch(frame: CGRect(x: 10 , y: view.frame.size.height - 100, width: 100, height: 60))
        switchY.center.x = view.center.x
        switchZ = UISwitch(frame: CGRect(x: view.frame.size.width - 110 , y: view.frame.size.height - 100, width: 100, height: 60))
        view.addSubview(switchX)
        view.addSubview(switchY)
        view.addSubview(switchZ)
        super.init()
        view.preferredFramesPerSecond = 60
        viewSize = view.drawableSize
        
        switchX.backgroundColor = .gray
        switchY.backgroundColor = .gray
        switchZ.backgroundColor = .gray
        setUpPipeLineState()
        
        setUpVertex()
        
        setUpImageTexture()
        
    }
    
    func setUpPipeLineState() {
        var library = try? device.makeDefaultLibrary()
        if let url = Bundle.main.url(forResource: "CubeRender", withExtension: "metal"){
            library = try? device.makeLibrary(URL: url)
        }
        
        let vfunc:MTLFunction? = library?.makeFunction(name: "cubeVertexShader")
        let fFunc:MTLFunction? = library?.makeFunction(name: "cubeFragmentShader")
        
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
        
        let vertexs:[Float] = [
            -0.5, 0.5, 0,  0, 1,
             0.5, 0.5, 0,  1, 1,
            -0.5,-0.5, 0,  0, 0,
             0.5,-0.5, 0,  1, 0
//             0,    0,  1,0.5,0.5
            
        ]
        /*
         0.0,1,
         0.0,1,
         0.0,1,
         0.0,1,
         */
        var vertexs1:[Float] = [
            1,-1,  0.0,  1,0,
            -1,-1, 0.0,  0,0,
            -1,1,  0.0,  0,1,
            -1,1,  0.0,  0,1,
            1,-1,  0.0,  1,0,
            1,1,   0.0,  1,1
        ]
        let  vertexs2 : [CubeVertexTexture] = [
        CubeVertexTexture(vex: vector_float3(1, -1,0), tex: vector_float2(1, 0)),
        CubeVertexTexture(vex: vector_float3(-1,-1,0), tex: vector_float2(0, 0)),
        CubeVertexTexture(vex: vector_float3(-1,1,0), tex: vector_float2(0, 1)),
        CubeVertexTexture(vex: vector_float3(1,1,0), tex: vector_float2(1, 1)),
        ]
        vertexBuffer = device.makeBuffer(bytes: vertexs1, length: MemoryLayout<Float>.size * vertexs1.count, options: MTLResourceOptions.storageModeShared)
        
        
        //索引
        let index:[Int32] = [
//            0, 3, 2,
//            0, 1, 3,
            0,1,2,
            0,2,3,
            
            
//            0, 2, 4,
//            0, 4, 1,
//            2, 3, 4,
//            1, 4, 3,
        ]
        self.indexCount = index.count
        vertexIndex = device.makeBuffer(bytes: index, length: MemoryLayout<Int32>.size * index.count, options: .storageModeShared)
        
        
    }
    func setUpImageTexture() {
        
        guard let image = UIImage(named: imageName)?.cgImage else {
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
    
    var x:Float = 0.0
    var y:Float = 0.0
    var z:Float = 0
    
    
    
    func setMatrix(encode:MTLRenderCommandEncoder) {
        let size = self.view.bounds.size
        let perspectM = GLKMatrix4MakePerspective(Float.pi / 2, Float(size.width/size.height), 0.1, 10)
        var modelViewM = GLKMatrix4MakeTranslation(0, 0, -2)
        if switchX.isOn {
            x += 1/180 * Float.pi
        }
        if switchY.isOn {
            y += 1/180 * Float.pi
        }
        
        if switchZ.isOn {
            z += 1/180 * Float.pi
        }
        
        modelViewM = GLKMatrix4RotateX(modelViewM, x)
        modelViewM = GLKMatrix4RotateY(modelViewM, y)
        modelViewM = GLKMatrix4RotateZ(modelViewM, z)
        
        let matrix = [perspectM,modelViewM]
        
        encode.setVertexBytes(matrix, length: MemoryLayout<GLKMatrix4>.size * 2, index: 1)
        
    }
    
}
extension GLKMatrix4{
    func toArray(){
       
    }
}
extension CubeRender :MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let queue = commandQueue,
            let buffer = queue.makeCommandBuffer(),
            let renderPassDiscriptor = view.currentRenderPassDescriptor,

            let pipeState = pipelineState
            
            else {
                return
        }
        renderPassDiscriptor.colorAttachments[0].loadAction = .clear
        guard
            let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDiscriptor)
            else {
                return
        }
        
        
        encoder.label = "renderEncoder"
        encoder.setRenderPipelineState(pipeState)
        
        encoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewSize.width), height: Double(viewSize.height), znear: -1, zfar: 1))
        
//        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        var vertexs1:[Float] = [
            1,-1,  0.0,  1,0,
            -1,-1, 0.0,  0,0,
            -1,1,  0.0,  0,1,
            1,-1,  0.0,  0,1,
            -1,1,  0.0,  1,0,
            1,1,   0.0,  1,1
        ]
        encoder.setVertexBytes(vertexs1, length: MemoryLayout<Float>.size * vertexs1.count, index: 0)
        self.setMatrix(encode: encoder)
        encoder.setFragmentTexture(texture, index: 0)
        
        encoder.setFrontFacing(MTLWinding.counterClockwise)
        encoder.setCullMode(MTLCullMode.back)
        
        encoder.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 6)
        
//        encoder.drawIndexedPrimitives(type: .triangleStrip, indexCount: self.indexCount, indexType: .uint32, indexBuffer: vertexIndex!, indexBufferOffset: 0)//使用索引绘图绘制
        
        encoder.endEncoding()
        
        buffer.present(view.currentDrawable!)
        
        buffer.commit()
        
    }
}
