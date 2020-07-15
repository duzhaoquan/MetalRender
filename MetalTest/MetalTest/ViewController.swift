//
//  ViewController.swift
//  MetalTest
//
//  Created by dzq_mac on 2020/6/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

/*
 
 https://github.com/alexiscn/MetalFilters
 */
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addbutton()
    }

    @objc func buttonClick(btn:UIButton){
        if btn.tag == 101 {
            let videoVC = RenderColorViewController()
            self.navigationController?.pushViewController(videoVC, animated: true)
            
        }else if btn.tag == 102{
            let movieVC = ImageViewController()
            self.navigationController?.pushViewController(movieVC, animated: true)
            
        }else if btn.tag == 103{
            let movieVC = ImageViewController()
            movieVC.loadTga = true
            self.navigationController?.pushViewController(movieVC, animated: true)
            
        }else if btn.tag == 104{
            self.navigationController?.pushViewController(CubeViewController(), animated: true)
        }
    }

    func addbutton() {
        let buttonX = UIButton(frame: CGRect.zero)
        buttonX.tag = 101
        buttonX.setTitle("triangle", for: UIControl.State.normal)
        buttonX.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonX.backgroundColor = UIColor.gray
        let buttonY = UIButton(frame: CGRect.zero)
        
        buttonY.tag = 102
        buttonY.setTitle("image", for: UIControl.State.normal)
        buttonY.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonY.backgroundColor = UIColor.gray
        
        let buttonZ = UIButton(frame: CGRect.zero)
        buttonZ.tag = 103
        buttonZ.setTitle("tga", for: UIControl.State.normal)
        buttonZ.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonZ.backgroundColor = UIColor.gray
        
        let buttonW = UIButton(frame: CGRect.zero)
        buttonW.tag = 104
        buttonW.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonW.setTitle("cube", for: UIControl.State.normal)
        buttonW.backgroundColor = .gray
        
        
        view.addSubview(buttonW)
        view.addSubview(buttonX)
        view.addSubview(buttonY)
        view.addSubview(buttonZ)
        
        buttonX.translatesAutoresizingMaskIntoConstraints = false
        buttonY.translatesAutoresizingMaskIntoConstraints = false
        buttonZ.translatesAutoresizingMaskIntoConstraints = false
        buttonW.translatesAutoresizingMaskIntoConstraints = false
        
        buttonY.widthAnchor.constraint(equalTo: buttonX.widthAnchor).isActive = true
        buttonZ.widthAnchor.constraint(equalTo: buttonX.widthAnchor).isActive = true
        buttonW.widthAnchor.constraint(equalTo: buttonX.widthAnchor).isActive = true
        
        buttonX.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 20).isActive = true
        buttonX.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -340).isActive = true
        buttonX.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        buttonY.leftAnchor.constraint(equalTo: buttonX.rightAnchor,constant: 10).isActive = true
        buttonY.topAnchor.constraint(equalTo: buttonX.topAnchor).isActive = true
        buttonY.bottomAnchor.constraint(equalTo: buttonX.bottomAnchor).isActive = true
        
        buttonZ.leftAnchor.constraint(equalTo: buttonY.rightAnchor,constant: 10).isActive = true
        buttonZ.topAnchor.constraint(equalTo: buttonX.topAnchor).isActive = true
        buttonZ.bottomAnchor.constraint(equalTo: buttonX.bottomAnchor).isActive = true
        
        buttonW.leftAnchor.constraint(equalTo: buttonZ.rightAnchor,constant: 10).isActive = true
        buttonW.topAnchor.constraint(equalTo: buttonX.topAnchor).isActive = true
        buttonW.bottomAnchor.constraint(equalTo: buttonX.bottomAnchor).isActive = true
        
        buttonW.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -20).isActive = true
    }
}

