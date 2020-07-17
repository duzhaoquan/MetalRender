//
//  ImageViewController.swift
//  MetalTest
//
//  Created by dzq_mac on 2020/7/2.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import MetalKit

class ImageViewController: UIViewController {

    var metalView : MTKView!
    
    var imageRender :ImageRender!
    var loadTga:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "metal加载图片"
        view.backgroundColor = .gray
        metalView = MTKView(frame: self.view.bounds)
        metalView.backgroundColor = .green
        view.addSubview(metalView)
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.framebufferOnly = false
        if metalView.device == nil {
            print("metal is not supported on this device!")
            return
        }
        imageRender = ImageRender(view: metalView,loadTga: loadTga)
        metalView.delegate = imageRender
        
        let btn = UIButton(frame: CGRect(x: 0, y: view.bounds.size.height - 100, width: 100, height: 40))
        btn.setTitle("image", for: .normal)
        btn.backgroundColor = .gray
        btn.center.x = view.center.x
        btn.addTarget(self, action: #selector(getMetalImage(btn:)), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    /*
     MTLTexture转成UIimage
     使用Metal处理完图像想要获取成UIimage，然后保存，Metal处理完的图片大小特别大，需要缩小之后再保存，如果MTLTexture是metalView.currentDrawable?.texture 获取的，需要将metalView.framebufferOnly 设置为false
     */
    //点击事件保存图片
    @objc func getMetalImage(btn:UIButton){
        if let texture = metalView.currentDrawable?.texture {
            metalView.removeFromSuperview()
            let imageview1 = UIImageView(frame: CGRect(x: 0, y: 100, width: 414, height: 500))
            imageview1.image = mtlTextureToUIImage(texture: texture, wScale: imageRender.imageScale.0, hScale: imageRender.imageScale.1)
            imageview1.backgroundColor = .green
            imageview1.contentMode = .scaleAspectFit
            view.addSubview(imageview1)
        }
        
    }
    
    ///MTLTexture转成UIimage，
    /// - Parameters:
    ///   - texture: texture ，传入的值如果是metalView.currentDrawable?.texture，需设置metalView.framebufferOnly = false
    ///   - wScale: 宽度方向的有效图像比例，用于剪切图像
    ///   - hScale: 高度方向的有效图像比例
    /// - Returns: 返回UIimage
    func mtlTextureToUIImage(texture:MTLTexture,wScale:CGFloat,hScale:CGFloat) -> UIImage? {
        let ciimage = CIImage(mtlTexture: texture, options: nil)
        //            let image = UIImage(ciImage: ciimage!)//直接获取图片太大且有空白
        //剪切图片
        let croppedCiImage = ciimage?.cropped(to: CGRect(x: CGFloat(texture.width)/2 * (1 - wScale), y: CGFloat(texture.height)/2 * (1 - hScale), width: CGFloat(texture.width) * wScale, height: CGFloat(texture.height) * hScale))
        metalView.removeFromSuperview()
        
        var uiimage12 = UIImage(ciImage: croppedCiImage!)
        let home = NSHomeDirectory() + "/Documents/image121.png"
        //存取一下，否则uiimage12.cgImage为nil
        try? uiimage12.pngData()?.write(to: URL(fileURLWithPath: home))
        uiimage12 = UIImage(contentsOfFile: home)!
        
        //图像宽高比
        let aspectRatio = uiimage12.size.width/uiimage12.size.height
        //给定一个合适的大小尺寸，我取得是iPhone8Plus宽414
        let size = CGSize(width: 414, height: 414 / aspectRatio)
        
        try? FileManager().removeItem(at: URL(string: home)!)
        
        //绘制图片，因为图片太大重新绘制（缩小）
        UIGraphicsBeginImageContext(size)
        //获取context
        let context = UIGraphicsGetCurrentContext()!
        ///绘制
        context.draw(uiimage12.cgImage!, in: CGRect(x:0 , y: 0, width: size.width, height: size.height))
        //翻转
        context.translateBy(x: 0, y: -size.height)
        context.scaleBy(x: 1, y: -1)
        //获取绘制的图像
        let image1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image1
    }
}
