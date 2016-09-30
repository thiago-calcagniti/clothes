//
//  HeightViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 19/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol ChangeHeight {
    func changeHeight(_ newHeight: Int)
}


class HeightViewController: UIViewController {
    
    let showHeightLabel = UILabel()
    let heightSlider = UISlider()
    var height: Int!
    var delegate : ChangeHeight?
    
    
    // Initializers
    init(delegate: ChangeHeight, height: Int) {
        self.delegate = delegate
        self.height = height
        super.init(nibName: "HeightViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.backgroundColor = AppCustomColor().darkGray
        
        let increaseArrow = UIImageView()
        increaseArrow.frame = CGRect(x: screenWidth*0.125, y: screenHeight*0.15, width: screenWidth*0.15, height: screenWidth*0.15)
        increaseArrow.contentMode = .scaleAspectFit
        increaseArrow.image = UIImage(named: "upperArrow.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        increaseArrow.tintColor = AppCustomColor().pink
        increaseArrow.isUserInteractionEnabled = true
        self.view.addSubview(increaseArrow)
        let increaseTap = UITapGestureRecognizer(target: self, action: #selector(HeightViewController.increaseTap(_:)))
        increaseTap.numberOfTapsRequired = 1
        increaseArrow.addGestureRecognizer(increaseTap)
        
        
        heightSlider.frame = CGRect(x: -screenWidth*0.15, y: screenHeight*0.4, width: screenWidth*0.7, height: screenHeight*0.1)
        heightSlider.minimumValue = 0
        heightSlider.maximumValue = 300
        heightSlider.isContinuous = true
        heightSlider.tintColor = AppCustomColor().pink
        heightSlider.value = 100
        heightSlider.transform = heightSlider.transform.rotated(by: CGFloat(270.0/180*M_PI))
        heightSlider.addTarget(self, action: #selector(HeightViewController.heightUpdate(_:)), for: .touchUpInside)
        heightSlider.addTarget(self, action: #selector(HeightViewController.heightChanged(_:)), for: .valueChanged)
        
        if (height != nil || height != 0) {
            heightSlider.value = Float(height)
        }
        
        self.view.addSubview(heightSlider)
        
        
        let decreaseArrow = UIImageView()
        decreaseArrow.frame = CGRect(x: screenWidth*0.125, y: screenHeight*0.665, width: screenWidth*0.15, height: screenWidth*0.15)
        decreaseArrow.contentMode = .scaleAspectFit
        decreaseArrow.image = UIImage(named: "upperArrow.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        decreaseArrow.tintColor = AppCustomColor().pink
        decreaseArrow.isUserInteractionEnabled = true
        decreaseArrow.transform = decreaseArrow.transform.rotated(by: CGFloat(180.0/180*M_PI))
        self.view.addSubview(decreaseArrow)
        let decreaseTap = UITapGestureRecognizer(target: self, action: #selector(HeightViewController.decreaseTap(_:)))
        decreaseTap.numberOfTapsRequired = 1
        decreaseArrow.addGestureRecognizer(decreaseTap)
        
        
        
        showHeightLabel.frame = CGRect(x: screenWidth*0.3, y: screenHeight*0.3, width: screenWidth*0.65, height: screenHeight*0.2)
        showHeightLabel.textAlignment = NSTextAlignment.center
        showHeightLabel.font = UIFont(name: "Klavika", size: CGFloat(120))
        showHeightLabel.text = "\(Int(heightSlider.value))"
        showHeightLabel.textColor = AppCustomColor().pink
        self.view.addSubview(showHeightLabel)
        
        
        let cmLabel = UILabel()
        cmLabel.frame = CGRect(x: screenWidth*0.4, y: screenHeight*0.45, width: screenWidth*0.6, height: screenHeight*0.15)
        cmLabel.textAlignment = NSTextAlignment.center
        cmLabel.font = UIFont(name: "Klavika", size: CGFloat(90))
        cmLabel.text = "cm"
        cmLabel.textColor = AppCustomColor().pink
        self.view.addSubview(cmLabel)
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Minha Altura"
    }
    
    
    //MARK: Tap Functions
    func increaseTap(_ gesture: UITapGestureRecognizer) {
        heightSlider.value = heightSlider.value + 1
        heightUpdate(heightSlider)
        heightChanged(heightSlider)
    }
    func decreaseTap(_ gesture: UITapGestureRecognizer) {
        heightSlider.value = heightSlider.value - 1
        heightUpdate(heightSlider)
        heightChanged(heightSlider)
    }
    
    
    //MARK: Slider Functions
    func heightUpdate(_ slider: UISlider) {
        let user = PFUser.current()!
        user["height"] = Int(slider.value)
        user.saveInBackground(block: { (success, error) -> Void in
            if success {
                self.delegate?.changeHeight(Int(slider.value))
            }
        })
    }
    func heightChanged(_ slider: UISlider) {
        showHeightLabel.text = "\(Int(slider.value))"
    }

}
