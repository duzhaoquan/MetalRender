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
    
    var imageRender :ImageRender?
    var loadTga:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "metal加载图片"
        view.backgroundColor = .gray
        metalView = MTKView(frame: self.view.bounds)
        metalView.backgroundColor = .green
        view.addSubview(metalView)
        metalView.device = MTLCreateSystemDefaultDevice()
        
        if metalView.device == nil {
            print("metal is not supported on this device!")
            return
        }
        imageRender = ImageRender(view: metalView,loadTga: loadTga)
        metalView.delegate = imageRender
    }

}
