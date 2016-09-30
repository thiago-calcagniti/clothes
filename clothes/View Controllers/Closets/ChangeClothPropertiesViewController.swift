//
//  ChangeClothPropertiesViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 08/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol ChangeClothesProperties {
    func updateClothBadge()
}

class ChangeClothPropertiesViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    var cloth: Cloth!
    var clothTypePicker: UIPickerView!
    var pickerDataSource: Array<String>!
    var typeChoosen: String!
    var clothNameTextField: UITextField!
    var myToolBarItems = [UIBarButtonItem]()
    var delegate: ChangeClothesProperties?
    
    
    
    // Initialiers
    init(delegate: ChangeClothesProperties, cloth: Cloth) {
        self.delegate = delegate
        self.cloth = cloth
        super.init(nibName: "ChangeClothPropertiesViewController", bundle: nil)
        self.title = "Editar Roupa"
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        
        // Insert Background Image as Cloth Image
        let backgroundImage = UIImageView()
        backgroundImage.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        backgroundImage.image = cloth.getImage()
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.layer.masksToBounds = true
        
        // Insert Background Blur Effect
        let blurBackgroundImage = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
        blurBackgroundImage.frame = backgroundImage.frame
        blurBackgroundImage.alpha = CGFloat(0.7)
        backgroundImage.addSubview(blurBackgroundImage)
        self.view.addSubview(backgroundImage)
        
        // Get all types of Clothes
        pickerDataSource = Enumerators().getClothTypes()
        
        // Set Picker for type
        clothTypePicker = UIPickerView()
        clothTypePicker.frame = CGRect(x: 0, y: screenHeight*0.4, width: screenWidth, height: screenHeight*0.4)
        clothTypePicker.dataSource = self
        clothTypePicker.delegate = self
        clothTypePicker.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.6))
        self.view.addSubview(clothTypePicker)
        
        // Create Frame Label to bound cloth type of UIPicker
        let frameLabel = UILabel()
        frameLabel.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.49, width: screenWidth*0.9, height: screenHeight*0.15)
        frameLabel.layer.cornerRadius = CGFloat(7)
        frameLabel.layer.borderColor = UIColor.white.cgColor
        frameLabel.layer.borderWidth = CGFloat(1)
        frameLabel.layer.masksToBounds = true
        self.view.addSubview(frameLabel)
        
        // Add a text Label to inform user should pick a option
        let selectCategoryLabel = UILabel()
        selectCategoryLabel.frame = CGRect(x: 0, y: 0, width: frameLabel.frame.width, height: frameLabel.frame.height/2)
        selectCategoryLabel.text = "Troque aqui o tipo da Peça"
        selectCategoryLabel.textAlignment = NSTextAlignment.center
        selectCategoryLabel.textColor = AppCustomColor().darkGray
        selectCategoryLabel.layer.masksToBounds = true
        selectCategoryLabel.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.6))
        selectCategoryLabel.font = UIFont(name: "Klavika" , size: CGFloat(19))
        frameLabel.addSubview(selectCategoryLabel)
        
        // Create a TextField to change Cloth Name
        clothNameTextField = UITextField()
        clothNameTextField.frame = CGRect(x: -1, y: screenHeight*0.3, width: screenWidth + 2, height: screenHeight*0.1)
        clothNameTextField.textColor = AppCustomColor().pink
        clothNameTextField.textAlignment = NSTextAlignment.center
        clothNameTextField.font = UIFont(name: "Klavika", size: CGFloat(25))
        clothNameTextField.layer.borderWidth = CGFloat(1)
        clothNameTextField.layer.borderColor = AppCustomColor().pink.cgColor
        clothNameTextField.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.3))
        clothNameTextField.text = cloth.getName()
        clothNameTextField.addTarget(nil, action: #selector(ChangeClothPropertiesViewController.clothNameChanged(_:)), for: UIControlEvents.editingDidEndOnExit)
        self.view.addSubview(clothNameTextField)
        
        // Let UIPicker to pre-select current cloth Type
        typeChoosen = cloth.getType()
        if let index: Int = pickerDataSource.index(of: typeChoosen) {
            self.clothTypePicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isToolbarHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        setToolBarItemsWithSpace()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.isToolbarHidden = true
    }
    
    
    
    
    
    
    
    // MARK: PickerView DataSource and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerDataSource[row])"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeChoosen = pickerDataSource[row]
    }
    
    
    
    // MARK: Setup ToolBar Items
    func createSaveChangeButton() -> UIBarButtonItem {
        let saveClothButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(ChangeClothPropertiesViewController.saveChanges))
        return saveClothButton
    }
    func createFlexibleItem() -> UIBarButtonItem {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        return flexibleItem
    }
    func setToolBarItemsWithSpace() {
        myToolBarItems.removeAll()
        let deleteClothButton = createSaveChangeButton()
        let flexibleItem = createFlexibleItem()
        myToolBarItems.append(flexibleItem)
        myToolBarItems.append(deleteClothButton)
        myToolBarItems.append(flexibleItem)
        if let navigation = self.navigationController {
            navigation.toolbar.items = myToolBarItems
        }
    }
    func saveChanges() {
        print("Saving changes...")
        cloth.setName(self.clothNameTextField.text!)
        cloth.setType(typeChoosen)
        self.delegate!.updateClothBadge()
        dismissController()
        
    }
    
    
    // MARK: Other Functions
    func clothNameChanged(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func dismissController() {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }



    
    
}




