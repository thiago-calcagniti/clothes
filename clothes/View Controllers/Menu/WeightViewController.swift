//
//  WeightViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 20/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol ChangeWeight {
    func changeWeight(_ newWeight: Int)
}

class WeightViewController: UIViewController {

    let weightSlider = UISlider()
    let weightLabel = UILabel()
    var delegate : ChangeWeight?
    var weight: Int!
    
    // Initializers
    init(delegate: ChangeWeight, weight: Int) {
        self.delegate = delegate
        self.weight = weight
        super.init(nibName: "WeightViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.backgroundColor = AppCustomColor().darkGray
        
        weightLabel.frame = CGRect(x: screenWidth*0.2, y: screenHeight*0.2, width: screenWidth*0.6, height: screenHeight*0.18)
        weightLabel.font = UIFont(name: "Klavika", size: CGFloat(120))
        weightLabel.textColor = AppCustomColor().pink
        weightLabel.textAlignment = NSTextAlignment.center
        weightLabel.text = "\(weight)"
        self.view.addSubview(weightLabel)
        
        let kgLabel = UILabel()
        kgLabel.frame = CGRect(x: screenWidth*0.75, y: screenHeight*0.2, width: screenWidth*0.2, height: screenHeight*0.1)
        kgLabel.textColor = AppCustomColor().pink
        kgLabel.textAlignment = NSTextAlignment.center
        kgLabel.text = "kg"
        kgLabel.font = UIFont(name: "Klavika", size: CGFloat(50))
        self.view.addSubview(kgLabel)
        
        
        let weightLoader = UIImageView()
        weightLoader.frame = CGRect(x: screenWidth*0.2, y: screenHeight*0.4, width: screenWidth*0.6, height: screenWidth*0.6)
        weightLoader.image = UIImage(named: "weightLoad.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        weightLoader.tintColor = AppCustomColor().pink
        self.view.addSubview(weightLoader)
        
        
        let increaseArrow = UIImageView()
        increaseArrow.frame = CGRect(x: screenWidth*0.82, y: screenHeight*0.81, width: screenWidth*0.15, height: screenWidth*0.15)
        increaseArrow.contentMode = .scaleAspectFit
        increaseArrow.image = UIImage(named: "upperArrow.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        increaseArrow.tintColor = AppCustomColor().pink
        increaseArrow.isUserInteractionEnabled = true
        increaseArrow.transform = increaseArrow.transform.rotated(by: CGFloat(90.0/180*M_PI))
        self.view.addSubview(increaseArrow)
        let increaseWeight = UITapGestureRecognizer(target: self, action: #selector(WeightViewController.increaseWeight(_:)))
        increaseWeight.numberOfTapsRequired = 1
        increaseArrow.addGestureRecognizer(increaseWeight)
        
        
        weightSlider.frame = CGRect(x: screenWidth*0.2, y: screenHeight*0.8, width: screenWidth*0.6, height: screenHeight*0.1)
        weightSlider.minimumValue = 0
        weightSlider.maximumValue = 200
        weightSlider.isContinuous = true
        weightSlider.tintColor = AppCustomColor().pink
        weightSlider.value = 100
        weightSlider.addTarget(self, action: #selector(WeightViewController.weightUpdate(_:)), for: .touchUpInside)
        weightSlider.addTarget(self, action: #selector(WeightViewController.weightChanged(_:)), for: .valueChanged)
        self.view.addSubview(weightSlider)
        
        
        if weight != nil {
            weightSlider.value = Float(weight)
        }
        
        let decreaseArrow = UIImageView()
        decreaseArrow.frame = CGRect(x: screenWidth*0.03, y: screenHeight*0.81, width: screenWidth*0.15, height: screenWidth*0.15)
        decreaseArrow.contentMode = .scaleAspectFit
        decreaseArrow.image = UIImage(named: "upperArrow.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        decreaseArrow.tintColor = AppCustomColor().pink
        decreaseArrow.isUserInteractionEnabled = true
        decreaseArrow.transform = decreaseArrow.transform.rotated(by: CGFloat(270.0/180*M_PI))
        self.view.addSubview(decreaseArrow)
        let decreaseWeight = UITapGestureRecognizer(target: self, action: #selector(WeightViewController.decreaseWeight(_:)))
        decreaseWeight.numberOfTapsRequired = 1
        decreaseArrow.addGestureRecognizer(decreaseWeight)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Meu Peso"
    }
    
    
    // MARK: Tap Functions
    func increaseWeight(_ gesture: UITapGestureRecognizer) {
        weightSlider.value = weightSlider.value + 1
        weightUpdate(weightSlider)
        weightChanged(weightSlider)
    }
    func decreaseWeight(_ gesture: UITapGestureRecognizer) {
        weightSlider.value = weightSlider.value - 1
        weightUpdate(weightSlider)
        weightChanged(weightSlider)
    }
    
    
    // MARK: Slider Functions
    func weightUpdate(_ slider: UISlider) {
        let user = PFUser.current()!
        user["weight"] = Int(slider.value)
        user.saveInBackground(block: { (success, error) -> Void in
            if success {
                self.delegate?.changeWeight(Int(slider.value))
            }
        })
    }
    func weightChanged(_ slider: UISlider) {
        weightLabel.text = "\(Int(slider.value))"
    }
    
    
    
    
    
}
