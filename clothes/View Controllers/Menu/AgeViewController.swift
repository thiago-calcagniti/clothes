//
//  AgeViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 09/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol ChangeAge {
    func changeAge(_ newAge: Int)
}

class AgeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    var tenNumber: Int!
    var oneNumber: Int!
    var delegate: ChangeAge?
    var age: Int!
    
    
    // Initializers
    init(delegate: ChangeAge, age: Int) {
        self.delegate = delegate
        self.age = age
        super.init(nibName: "AgeViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func viewDidLoad() {
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        self.view.backgroundColor = AppCustomColor().darkGray
        
        
        let pickerContainer = UIView()
        pickerContainer.frame = CGRect(x: screenWidth*0.175, y: screenHeight*0.15, width: screenWidth*0.65, height: screenHeight*0.22)
        pickerContainer.layer.cornerRadius = CGFloat(7)
        pickerContainer.layer.masksToBounds = true
        
        
        let numberPicker = UIPickerView()
        numberPicker.frame = CGRect(x: 0,y: -screenHeight*0.16, width: screenWidth*0.65, height: screenHeight*0.5)
        numberPicker.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.3))
        numberPicker.delegate = self
        numberPicker.dataSource = self
        numberPicker.layer.masksToBounds = true
        
        
        pickerContainer.addSubview(numberPicker)
        self.view.addSubview(pickerContainer)
        
        // Let UIPicker to pre-select current age
        if (age != nil) {
        tenNumber = Int(age/10)
        oneNumber = age - tenNumber*10

        numberPicker.selectRow(tenNumber, inComponent: 0, animated: true)
        numberPicker.selectRow(oneNumber, inComponent: 1, animated: true)
        }
        

    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Minha Idade"
    }
    
    
    // MARK: PickerView DataSource and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let size = pickerView.bounds.height*0.34
        let numberLabel = UILabel()
        numberLabel.frame = CGRect(x: 0, y: 0, width: size,height: size)
        numberLabel.backgroundColor = UIColor.white
        numberLabel.layer.cornerRadius = CGFloat(7)
        numberLabel.layer.masksToBounds = true
        numberLabel.text = "\(row)"
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.textColor = AppCustomColor().pink
        numberLabel.font = UIFont(name: "Klavika", size: CGFloat(80))
        return numberLabel
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        // Get age before it changes
        let ageBeforeScroll = age
        
        // Identify which of picker components was scrolled
        if component == 0 {
        tenNumber = row
        } else if component == 1 {
            oneNumber = row
        }
        
        // Calculate new age
        age = (tenNumber*10) + oneNumber
        let ageAfterScroll = age
        

        // If age changed, save in Parse and update profile in App
        if ageBeforeScroll != ageAfterScroll {
            print(age)
            let user = PFUser.current()!
            user["age"] = age
            user.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.delegate?.changeAge(self.age)
                }
            })

        }
    }
    

    
    
    


}
