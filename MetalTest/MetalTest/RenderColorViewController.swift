//
//  RenderColorViewController.swift
//  MetalTest
//
//  Created by dzq_mac on 2020/7/2.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import MetalKit

class RenderColorViewController: UIViewController {

    var metalView : MTKView!
    var render : DzqRender?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        metalView = MTKView(frame: self.view.bounds)
        metalView.backgroundColor = .green
        view.addSubview(metalView)
        metalView.device = MTLCreateSystemDefaultDevice()
        
        if metalView.device == nil {
            print("metal is not supported on this device!")
            return
        }
        render = DzqRender(view: metalView)
        metalView.delegate = render
    }


}
