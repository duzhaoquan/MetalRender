//
//  CubeRender.swift
//  MetalTest
//
//  Created by dzq_mac on 2020/7/2.
//  Copyright © 2020 dzq_mac. All rights reserved.

import UIKit
import MetalKit
import GLKit
struct CubeVertexTexture {
    var vex:vector_float4
    var tex:vector_float4
    var color:vector_float4
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
    var button : UIButton!
    var switchX,switchY,switchZ :UISwitch
    
    init(view:MTKView) {
        self.view = view
        self.device = view.device!
        self.commandQueue = device.makeCommandQueue()!
        switchX = UISwitch(frame: CGRect(x: 20 , y: view.frame.size.height - 100, width: 100, height: 60))
        
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
        
        button = UIButton(frame: CGRect(x: 0, y: view.frame.size.height - 160, width: 100, height: 50))
        button.setTitle("旋转", for: UIControl.State.normal)
        button.center.x = view.center.x
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(rotate(btn:)), for: .touchUpInside)
        view.addSubview(button)
        
        setUpPipeLineState()
        
        setUpVertex()
        
        setUpImageTexture()
        
    }
    @objc func rotate(btn:UIButton){
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            btn.setTitle("停止", for: .normal)
        }else {
            btn.setTitle("旋转", for: .normal)
        }
        
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
        
        let vertexs1:[Float] = [
          
            -0.5, 0.5, 0, 1.0,
             0.5, 0.5, 0, 1.0,
            -0.5,-0.5, 0, 1.0,
             0.5,-0.5, 0, 1.0,
             0.0, 0.0, 0.5, 1
            
        ]
        let vertexs3:[Float] = [

           -0.5, 0.5, 0, 1.0,0, 1,
            0.5, 0.5, 0, 1.0,1, 1,
           -0.5,-0.5, 0, 1.0,0, 0,
            0.5,-0.5, 0, 1.0,1, 0,
            0.0, 0.0, 1, 1,0.5,0.5

        ]
        
        let  vertexs2 : [CubeVertexTexture] = [
            CubeVertexTexture(vex: vector_float4(-0.5, 0.5, 0, 1.0), tex: vector_float4(0, 1, 0, 0), color: vector_float4(1, 0,0,1)),//左上
            CubeVertexTexture(vex: vector_float4( 0.5, 0.5, 0, 1.0), tex: vector_float4(1, 1, 0, 0), color: vector_float4(0, 1,0,1)),//右上
            CubeVertexTexture(vex: vector_float4(-0.5,-0.5, 0, 1.0), tex: vector_float4(0, 0, 0, 0), color: vector_float4(0, 0,1,1)),//左下
            CubeVertexTexture(vex: vector_float4( 0.5,-0.5, 0, 1.0), tex: vector_float4(1, 0, 0, 0), color: vector_float4(0, 1,1,1)),//右下
            CubeVertexTexture(vex: vector_float4( 0.0, 0.0, 0.5, 1.0), tex: vector_float4(0.5,0.5,0,0), color: vector_float4(1, 1,0,1))
        ]
        //坑：顶点坐标值的个数必须是4的倍数，vertexs1可以，vertexs3不行，vertexs2可以
        vertexBuffer = device.makeBuffer(bytes: vertexs2, length: MemoryLayout<CubeVertexTexture>.size * (vertexs2.count), options: .storageModeShared)
        
        //索引
        let index:[uint] = [
            0, 3, 2,
            0, 1, 3,
            0, 2, 4,
            0, 4, 1,
            2, 3, 4,
            1, 4, 3
        ]
        self.indexCount = index.count
        vertexIndex = device.makeBuffer(bytes: index, length: MemoryLayout<uint>.size * index.count, options: .storageModeShared)
        
        
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
    var z:Float = 0.0
    
    
    //设置矩阵变换
    func setMatrix(encode:MTLRenderCommandEncoder) {
        let size = self.view.bounds.size
        let perspectM = GLKMatrix4MakePerspective(Float.pi/2, Float(size.width/size.height), 0.1, 50.0)
        var modelViewM = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2)
        if button.isSelected {
            if switchX.isOn {
                x += 1/180 * Float.pi
            }
            if switchY.isOn {
                y += 1/180 * Float.pi
            }
            
            if switchZ.isOn {
                z += 1/180 * Float.pi
            }
        }
        
        modelViewM = GLKMatrix4RotateX(modelViewM, x)
        modelViewM = GLKMatrix4RotateY(modelViewM, y)
        modelViewM = GLKMatrix4RotateZ(modelViewM, z)
        
        var matrix = DqMatrix(pMatix: perspectM.toMatrix_float4x4(), mvMatrix: modelViewM.toMatrix_float4x4())
        
        encode.setVertexBytes(&matrix, length: MemoryLayout<DqMatrix>.size, index: 1)
        
    }
    
}
struct DqMatrix {
    var pMatix : matrix_float4x4
    var mvMatrix :matrix_float4x4
    
}
extension GLKMatrix4{
    func toMatrix_float4x4() -> matrix_float4x4{
        let matrix = self
        return matrix_float4x4(
            simd_make_float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
            simd_make_float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
            simd_make_float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
            simd_make_float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33)
        )
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
        renderPassDiscriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.6, green: 0.2, blue: 0.5, alpha: 1)
        guard
            let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDiscriptor)
            else {
                return
        }
        
        
        encoder.label = "renderEncoder"
        encoder.setRenderPipelineState(pipeState)
        
        encoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewSize.width), height: Double(viewSize.height), znear: -1, zfar: 1))
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
       
//        encoder.setVertexBytes(vertexs1, length: MemoryLayout<Float>.size * vertexs1.count, index: 0)
        self.setMatrix(encode: encoder)
        encoder.setFragmentTexture(texture, index: 0)

        encoder.setFrontFacing(MTLWinding.counterClockwise)
        encoder.setCullMode(MTLCullMode.back)
        
//        encoder.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 5)
        
        encoder.drawIndexedPrimitives(type: .triangle, indexCount: self.indexCount, indexType: .uint32, indexBuffer: vertexIndex!, indexBufferOffset: 0)//使用索引绘图绘制
        
        encoder.endEncoding()
        view
        
        buffer.present(view.currentDrawable!)
        
        buffer.commit()
        
    }
}
