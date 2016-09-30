//
//  AppearanceViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 20/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol ChangeAppearance {
    func changeAppearance(_ newApperance: String)
}

class AppearanceViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    
    var pickerDataSource = Array<String>()
    var appearancePicker = UIPickerView()
    var appearance: String!
    var gender: String!
    var delegate: ChangeAppearance?
    
    // Initializers
    init(delegate: ChangeAppearance, appearance: String, gender: String) {
        self.delegate = delegate
        self.appearance = appearance
        self.gender = gender
        super.init(nibName: "AppearanceViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.backgroundColor = AppCustomColor().darkGray
        
        pickerDataSource = Enumerators().getBodyShapes(gender)
        
        appearancePicker.frame = CGRect(x: screenWidth*0.1, y: screenHeight*0.3, width: screenWidth*0.8, height: screenHeight*0.5)
        appearancePicker.dataSource = self
        appearancePicker.delegate = self
        self.view.addSubview(appearancePicker)
        

        
        // Let UIPicker to pre-select appearance
        if let index: Int = pickerDataSource.index(of: appearance) {
            self.appearancePicker.selectRow(index, inComponent: 0, animated: true)
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Minha Aparência"
    }
    
    
    
    // MARK: PickerView DataSource and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        appearance = pickerDataSource[row]
        let user = PFUser.current()!
        user["appearance"] = appearance
        user.saveInBackground(block: { (success, error) -> Void in
            if success {
                self.delegate?.changeAppearance(self.appearance)
            }
        })
        
        
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: pickerDataSource[row], attributes: [NSForegroundColorAttributeName : AppCustomColor().pink])
        return attributedString
    }

}
