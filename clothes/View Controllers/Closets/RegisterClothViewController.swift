//
//  RegisterClothViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 04/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol RegisterClothesDelegate {
    func getCurrentCloset() -> Closet
    func updateClothesThatWillBeShown() -> Int
    func informNewClothWasAdded(_ type: String)
    func loadIcons()
    func appendImagePFFileToCurrentClothesImagesFiles(_ image: PFFile) -> Int
    func downloadClothesFromClosets(_ closet: Closet)
    func downloadAddedClothToCurrentCloset(_ object: PFObject)
}

class RegisterClothViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var heightOffset: CGFloat!
    var delegate: RegisterClothesDelegate?
    var clothImage: UIImage!
    var myToolBarItems = [UIBarButtonItem]()
    var clothTypePicker: UIPickerView!
    var pickerDataSource: Array<String>!
    var choosenClothType: String! = "Indefinido"
    var clothNameTextField: UITextField!
    var nameCreated: String = "Nome da Roupa"
    
    
    init(delegate: RegisterClothesDelegate, clothImage: UIImage) {
        self.delegate = delegate
        self.clothImage = clothImage
        super.init(nibName: "RegisterClothViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        heightOffset = UIScreen.main.bounds.height*0.04
        
        pickerDataSource = Enumerators().getClothTypes()
        
        let imageChosenByUser = UIImageView()
        imageChosenByUser.image = clothImage
        imageChosenByUser.contentMode = .scaleAspectFill
        imageChosenByUser.clipsToBounds = true
        imageChosenByUser.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: screenWidth, height: screenHeight*0.9)
        self.view.addSubview(imageChosenByUser)
        
        clothTypePicker = UIPickerView()
        clothTypePicker.frame = CGRect(x: 0, y: screenHeight*0.4, width: screenWidth, height: screenHeight*0.4)
        clothTypePicker.dataSource = self
        clothTypePicker.delegate = self
        clothTypePicker.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.6))
        self.view.addSubview(clothTypePicker)
        
        let frameLabel = UILabel()
        frameLabel.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.49, width: screenWidth*0.9, height: screenHeight*0.15)
        frameLabel.layer.cornerRadius = CGFloat(7)
        frameLabel.layer.borderColor = UIColor.white.cgColor
        frameLabel.layer.borderWidth = CGFloat(1)
        frameLabel.layer.masksToBounds = true
        self.view.addSubview(frameLabel)
        
        let selectCategoryLabel = UILabel()
        selectCategoryLabel.frame = CGRect(x: 0, y: 0, width: frameLabel.frame.width, height: frameLabel.frame.height/2)
        selectCategoryLabel.text = "Selecione um tipo de Roupa"
        selectCategoryLabel.textAlignment = NSTextAlignment.center
        selectCategoryLabel.textColor = AppCustomColor().darkGray
        selectCategoryLabel.layer.masksToBounds = true
        selectCategoryLabel.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.6))
        selectCategoryLabel.font = UIFont(name: "Klavika" , size: CGFloat(19))
        frameLabel.addSubview(selectCategoryLabel)
        
        clothNameTextField = UITextField()
        clothNameTextField.frame = CGRect(x: -1, y: screenHeight*0.3, width: screenWidth + 2, height: screenHeight*0.1)
        clothNameTextField.textColor = AppCustomColor().pink
        clothNameTextField.textAlignment = NSTextAlignment.center
        clothNameTextField.font = UIFont(name: "Klavika", size: CGFloat(25))
        clothNameTextField.layer.borderWidth = CGFloat(1)
        clothNameTextField.layer.borderColor = AppCustomColor().pink.cgColor
        clothNameTextField.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.3))
        clothNameTextField.text = "Escolha um Nome"
        clothNameTextField.addTarget(nil, action: #selector(RegisterClothViewController.defineClothName(_:)), for: UIControlEvents.editingDidEndOnExit)
        self.view.addSubview(clothNameTextField)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigation = self.navigationController {
            navigation.isNavigationBarHidden = false
            navigation.isToolbarHidden = false
            self.title = "Nova Roupa"
        }
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
        let typeChoosen = pickerDataSource[row]
        updateChoosenClothType(typeChoosen)
    }
    
    
    // MARK: Setup ToolBar Items
    func createAddClothButton() -> UIBarButtonItem {
        let addClothButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(RegisterClothViewController.addClothToCloset))
        return addClothButton
    }
    func createFlexibleItem() -> UIBarButtonItem {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        return flexibleItem
        
    }
    func setToolBarItemsWithSpace() {
        myToolBarItems.removeAll()
        let addClothButton = createAddClothButton()
        let flexibleItem = createFlexibleItem()
        myToolBarItems.append(flexibleItem)
        myToolBarItems.append(addClothButton)
        myToolBarItems.append(flexibleItem)
        if let navigation = self.navigationController {
        navigation.isToolbarHidden = false
        navigation.toolbar.items = myToolBarItems
        }
    }
    

    // MARK: Manage Adding Cloth
    func updateChoosenClothType(_ typeChoosen: String) {
        self.choosenClothType = typeChoosen
    }
    func addClothToCloset() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let cloth = Cloth(name: nameCreated, type: choosenClothType, image: clothImage)
        let closet = delegate?.getCurrentCloset()
        let closetId = closet!.getId()
        let PFCloth = PFObject(className: "Clothes")
        PFCloth["parentCloset"] = closetId
        PFCloth["type"] = "\(choosenClothType)"
        PFCloth["name"] = nameCreated
        PFCloth["ownerId"] = (PFUser.current()?.objectId)!
        PFCloth["occasions"] = []
        let imageData = UIImageJPEGRepresentation(clothImage, CGFloat(0.5))
        let imageFile = PFFile(name: nameCreated, data: imageData!)
        PFCloth["image"] = imageFile
        PFCloth.saveInBackground { (sucess, error) -> Void in
            if sucess {
                self.delegate!.downloadAddedClothToCurrentCloset(PFCloth)
                self.delegate?.informNewClothWasAdded(self.choosenClothType)
                self.dismissViewControllerBackToClosets()
                UIApplication.shared.endIgnoringInteractionEvents()

            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    // MARK: Other Functions
    func defineClothName(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        nameCreated = clothNameTextField.text!
        return true
    }
    
    
    
    func dismissViewControllerBackToClosets() {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }

}
