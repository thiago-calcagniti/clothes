//
//  EditClosetViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 08/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol EditCloset {
    func scrollToCloset(_ closetIndex: Int)
    func removeCloset(_ closetIndex: Int)
    func takePictureFromPhotoLibrary()
    func takeShot()
    func setTypeOfPictureBeingTaken(_ type: String)
}


class EditClosetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var closet: Closet!
    var closetIndex: Int!
    var typesOfClothesInCloset: Array<String> = []
    var blackCoverScreen : UIView!
    var saveButton: UIButton!
    var cancelButton: UIBarButtonItem!
    var changeNameLabel: UILabel!
    var changeNameTextField: UITextField!
    var newName: String! = ""
    var numberOfClosets: Int!
    var closetNameLabel: UILabel!
    var myToolBarItems = [UIBarButtonItem]()
    var delegate: EditCloset?
    
    let changeSpaceNumberPicker = UIPickerView()
    var closetRemainingSpaces = UILabel()
    var availableLabelValue = UILabel()
    var spot: Int = 0
    
    // Initializers
    init(delegate: EditCloset, closet: Closet, closetIndex: Int, numberOfClosets: Int) {
        self.closet = closet
        self.closetIndex = closetIndex
        self.numberOfClosets = numberOfClosets
        self.delegate = delegate
        super.init(nibName: "EditClosetViewController", bundle: nil)
        self.title = "Editar"
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let types = closet.getTypes()
        for type in types {
            typesOfClothesInCloset.append(type)
        }
        typesOfClothesInCloset.sort()
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let containerTitle = UIImageView()
        containerTitle.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*0.2)
        containerTitle.clipsToBounds = true
        containerTitle.image = closet.getImage()
        containerTitle.contentMode = .scaleAspectFill
        self.view.addSubview(containerTitle)

        
        let blackGradientLabel: CAGradientLayer = CAGradientLayer()
        blackGradientLabel.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*0.2)
        blackGradientLabel.colors = [UIColor.black.withAlphaComponent(CGFloat(0.7)).cgColor,
                                     UIColor.white.withAlphaComponent(CGFloat(0.7)).cgColor]
        blackGradientLabel.locations = [0.4, 1.0]
        blackGradientLabel.startPoint = CGPoint(x: 0.0, y: 1.0)
        blackGradientLabel.endPoint = CGPoint(x: 1.0, y: 1.0)
        containerTitle.layer.insertSublayer(blackGradientLabel, at: 0)
        
        
        closetNameLabel = UILabel()
        closetNameLabel.frame = CGRect(x: screenWidth*0.03, y: screenWidth*0.01, width: screenWidth*0.8, height: screenWidth*0.1)
        closetNameLabel.font = UIFont(name: "Klavika" , size: CGFloat(25))
        closetNameLabel.text = closet.getName()
        closetNameLabel.textColor = AppCustomColor().pink
        containerTitle.addSubview(closetNameLabel)
        
        closetRemainingSpaces.frame = CGRect(x: screenWidth*0.03, y: screenWidth*0.07, width: screenWidth*0.8, height: screenWidth*0.1)
        closetRemainingSpaces.text = "\(closet.getCapacity()-closet.getClothes().count) espaços disponíveis"
        closetRemainingSpaces.textColor = UIColor.white
        closetRemainingSpaces.font = UIFont(name: closetRemainingSpaces.font!.fontName , size: CGFloat(15))
        containerTitle.addSubview(closetRemainingSpaces)
        
        let availableSpaceLabel = UILabel()
        availableSpaceLabel.frame = CGRect(x: screenWidth*0.70, y: containerTitle.frame.height*0.1, width: containerTitle.frame.height*0.8, height: containerTitle.frame.height*0.8)
        availableSpaceLabel.font = UIFont(name: "Klavika" , size: CGFloat(50))
        availableSpaceLabel.textAlignment = NSTextAlignment.center
        availableSpaceLabel.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.4))
        availableSpaceLabel.textColor = AppCustomColor().pink
        availableSpaceLabel.layer.cornerRadius = CGFloat(availableSpaceLabel.frame.height/2)
        availableSpaceLabel.layer.borderWidth = CGFloat(1)
        availableSpaceLabel.layer.masksToBounds = true
        availableSpaceLabel.layer.borderColor = AppCustomColor().pink.cgColor
        availableSpaceLabel.text = "\(closet.getClothes().count)"
        containerTitle.addSubview(availableSpaceLabel)
        
        let changePictureButton = UIButton(type: UIButtonType.custom)
        let buttonImage = UIImage(named: "camera.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        changePictureButton.setImage( buttonImage, for: UIControlState())
        changePictureButton.frame = CGRect(x: screenWidth*0.03, y: screenHeight*0.092, width: screenWidth*0.09, height: screenWidth*0.08)
        changePictureButton.contentMode = .scaleAspectFit
        changePictureButton.tintColor = AppCustomColor().pink
        changePictureButton.addTarget(self, action: #selector(EditClosetViewController.changeClosetPicture(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(changePictureButton)

        let changeNameButton = UIButton(type: UIButtonType.custom)
        let buttonImage2 = UIImage(named: "editText.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        changeNameButton.setImage( buttonImage2, for: UIControlState())
        changeNameButton.frame = CGRect(x: screenWidth*0.15, y: screenHeight*0.09, width: screenWidth*0.1, height: screenWidth*0.1)
        changeNameButton.contentMode = .scaleAspectFill
        changeNameButton.tintColor = AppCustomColor().pink
        changeNameButton.addTarget(self, action: #selector(EditClosetViewController.pressChangeClosetNameButton(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(changeNameButton)
        
        
        createClosetTableView()
        
        
        // MARK: Control Area of Space of Closet
        
        spot = User().getSpot()
        
        let controlSpacesContainer = UIView()
        controlSpacesContainer.backgroundColor = AppCustomColor().lightGray
        controlSpacesContainer.frame = CGRect(x: 0, y: screenHeight*0.2, width: screenWidth, height: screenHeight*0.13)
        self.view.addSubview(controlSpacesContainer)
        
        let capacityLabelText = UILabel()
        capacityLabelText.frame = CGRect(x: screenWidth*0.02, y: controlSpacesContainer.frame.height*0.4, width: screenWidth/4, height: screenHeight*0.03)
        capacityLabelText.font = UIFont(name: "Klavika" , size: CGFloat(20))
        capacityLabelText.textColor = AppCustomColor().pink
        capacityLabelText.text = "Capacidade"
        controlSpacesContainer.addSubview(capacityLabelText)
        
        let availableLabelText = UILabel()
        availableLabelText.frame = CGRect(x: screenWidth*0.35, y: controlSpacesContainer.frame.height*0.03, width: screenWidth/4, height: screenHeight*0.06)
        availableLabelText.font = UIFont(name: "Klavika", size: CGFloat(15))
        availableLabelText.textColor = UIColor.white
        availableLabelText.text = "Pontos de Espaço"
        availableLabelText.textAlignment = NSTextAlignment.center
        availableLabelText.lineBreakMode = NSLineBreakMode.byWordWrapping
        availableLabelText.numberOfLines = 0
        controlSpacesContainer.addSubview(availableLabelText)
        
        availableLabelValue.frame = CGRect(x: screenWidth*0.35, y: controlSpacesContainer.frame.height*0.4, width: screenWidth/4, height: screenHeight*0.06)
        availableLabelValue.font = UIFont(name: "Klavika", size: CGFloat(35))
        availableLabelValue.textColor = AppCustomColor().pink
        availableLabelValue.text = "\(spot)"
        availableLabelValue.textAlignment = NSTextAlignment.center
        controlSpacesContainer.addSubview(availableLabelValue)
        
        changeSpaceNumberPicker.frame = CGRect(x: screenWidth*0.7, y: controlSpacesContainer.frame.height*0.14, width: screenWidth/4, height: screenHeight*0.13)
        changeSpaceNumberPicker.dataSource = self
        changeSpaceNumberPicker.delegate = self
        changeSpaceNumberPicker.selectRow(closet.getCapacity(), inComponent: 0, animated: true)
        controlSpacesContainer.addSubview(changeSpaceNumberPicker)
        
        
        let changeSpaceNumberInClosetText = UILabel()
        changeSpaceNumberInClosetText.frame = CGRect(x: screenWidth*0.70, y: controlSpacesContainer.frame.height*0.025, width: screenWidth/4, height: screenHeight*0.03)
        changeSpaceNumberInClosetText.font = UIFont(name: "Klavika", size: CGFloat(15))
        changeSpaceNumberInClosetText.textColor = UIColor.white
        changeSpaceNumberInClosetText.text = "Neste Armário"
        changeSpaceNumberInClosetText.textAlignment = NSTextAlignment.center
        changeSpaceNumberInClosetText.lineBreakMode = NSLineBreakMode.byWordWrapping
        changeSpaceNumberInClosetText.numberOfLines = 0
        controlSpacesContainer.addSubview(changeSpaceNumberInClosetText)
        
        
        setToolBarItemsWithSpace()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        setToolBarItemsWithSpace()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = true
        updateUserSpots()
    }
    
    
    // MARK: Setup View Content
    func createClosetTableView() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let tableView = UITableView(frame: CGRect(x: 0, y: screenHeight*0.29, width: screenWidth, height: screenHeight), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = AppCustomColor().darkGray
        self.view.addSubview(tableView)
    }
    
    
    
    // MARK: Change Closet Picture
    func changeClosetPicture(_ sender: UIButton) {
        let windowWidth = UIScreen.main.bounds.width*0.8
        let alert:SCLAlertView = SCLAlertView(newWindowWidth: windowWidth)
        alert.addButton("Album", target: self, selector: #selector(EditClosetViewController.takePictureFromPhotoLibrary))
//        alert.addButton("Camera", target: self, selector: Selector("takeAShot"))
        alert.showCustom(UIImage(named: "takeShotBig.png"), color: AppCustomColor().pink, title: "Foto do Armário", subTitle: "Escolha como deseja adicionar a foto do seu armário!", closeButtonTitle: "Cancelar", duration: 0.0)
    }
    func takePictureFromPhotoLibrary() {
        delegate?.setTypeOfPictureBeingTaken("closet")
        delegate?.takePictureFromPhotoLibrary()
        dismissViewControllerBackToClosets()
    }
    func takeAShot() {
        delegate?.setTypeOfPictureBeingTaken("closet")
        delegate?.takeShot()
        dismissViewControllerBackToClosets()
    }
    
    // MARK: Change Closet Name
    func pressChangeClosetNameButton(_ sender: UIButton) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        blackCoverScreen = UIView()
        blackCoverScreen.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.8))
        blackCoverScreen.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(blackCoverScreen)
        
        changeNameLabel = UILabel()
        changeNameLabel.text = "Mude aqui o nome do seu armário"
        changeNameLabel.textColor = AppCustomColor().pink
        changeNameLabel.frame = CGRect(x: 0, y: screenHeight*0.15, width: screenWidth, height: screenHeight*0.05)
        changeNameLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(changeNameLabel)
        
        changeNameTextField = UITextField()
        changeNameTextField.text = closet.getName()
        changeNameTextField.frame = CGRect(x: 10, y: screenHeight*0.2, width: screenWidth - 20, height: screenHeight*0.1)
        changeNameTextField.textAlignment = NSTextAlignment.center
        changeNameTextField.textColor = AppCustomColor().pink
        changeNameTextField.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.3))
        changeNameTextField.layer.cornerRadius = CGFloat(7)
        changeNameTextField.layer.masksToBounds = true
        changeNameTextField.font = UIFont(name: "Klavika", size: CGFloat(26))
        changeNameTextField.addTarget(self, action: #selector(EditClosetViewController.changeClosetName(_:)), for: UIControlEvents.editingDidEndOnExit)
        self.view.addSubview(changeNameTextField)
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(EditClosetViewController.dontChangeName))
        self.navigationItem.rightBarButtonItem = cancelButton
        
        
    }
    func changeClosetName(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        newName = changeNameTextField.text
        if closet.getName() != newName {
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            saveButton = UIButton(type: UIButtonType.custom)
            saveButton.setTitle("Save", for: UIControlState())
            saveButton.frame = CGRect(x: screenWidth*0.1, y: screenHeight*0.3, width: screenWidth*0.8, height: screenHeight*0.1)
            saveButton.setTitleColor(AppCustomColor().pink, for: UIControlState())
            saveButton.addTarget(self, action: #selector(EditClosetViewController.dismissChangeName(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(saveButton)
        }
        return true
    }
    func dismissChangeName(_ sender: UIButton) {
        if closet.getName() != newName {
            closet.setName(newName)
            closetNameLabel.text = newName
            
        }
        if blackCoverScreen != nil {
            blackCoverScreen.removeFromSuperview()
            changeNameLabel.removeFromSuperview()
            changeNameTextField.removeFromSuperview()
            saveButton.removeFromSuperview()
        }
    }
    func dontChangeName() {
        if blackCoverScreen != nil {
            blackCoverScreen.removeFromSuperview()
            changeNameLabel.removeFromSuperview()
            changeNameTextField.removeFromSuperview()
            if saveButton != nil {
            saveButton.removeFromSuperview()
            }
            cancelButton.isEnabled = false
            self.navigationItem.rightBarButtonItem = nil
            
        }
    }
    
    // MARK: Delete Closet
    func areYouSureToDelete() {
        
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(UIScreen.main.bounds.width*0.8))
        alert.showQuestion("Deletar Armário", subTitle: "Gostaria de deletar este armário?, as roupas dele deverão ser movidas posteriormente por você para outro armário se desejar e ficarão armazenadas no cesto.", closeButtonTitle: "Não foi sem querer!", duration: 0.0)
        let removeButton: SCLButton = alert.addButton("Sim eu quero remover...", target: self, selector: #selector(EditClosetViewController.deleteCloset))
        removeButton.backgroundColor = UIColor.gray
    }
    func deleteCloset() {
        let closetQuery = PFQuery(className: "Closet")
        closetQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        closetQuery.getObjectInBackground(withId: closet.getId()) { (object, error) -> Void in
            if error != nil {
                print(error)
            } else if let object = object {
                object.deleteInBackground(block: { (success, error) -> Void in
                    if success {
                        let index = self.closetIndex
                        let clothes = self.closet.getClothes()
                        let numberOfClothes = clothes.count
                        for cloth in clothes {
                            cloth.setClosetId("cesto")
                        }
                        self.dismissViewControllerBackToClosets()
                        let name = object["name"] as! String
                        self.delegate?.removeCloset(index!)
                        self.delegate?.scrollToCloset(0)
                        var message: String = ""
                        if numberOfClothes > 0 {
                            message = "O armário foi removido com sucesso, e \(numberOfClothes) roupas foram movidas para o cesto."
                        } else {
                            message = "O armário foi removido com sucesso, não haviam roupas nele!"
                        }
                        Alert(controller: self).message("Removido", message: message, confirmationTitle: "Entendido")
                        print("Nome do armario removido é: \(name) e sua posicao era \(self.closetIndex)")
                    
                        self.recoverUserSpotsWhenDeletingCloset(numberOfClothes)
                        
                    }
                })

            }
        }
        
    }

    
    // MARK: Setup ToolBar Items
    func createDeleteClothButton() -> UIBarButtonItem {
        let deleteClothButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(EditClosetViewController.areYouSureToDelete))
        return deleteClothButton
    }
    func createFlexibleItem() -> UIBarButtonItem {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        return flexibleItem
        
    }
    func setToolBarItemsWithSpace() {
        if numberOfClosets > 1 {
            myToolBarItems.removeAll()
            let deleteClothButton = createDeleteClothButton()
            let flexibleItem = createFlexibleItem()
            myToolBarItems.append(flexibleItem)
            myToolBarItems.append(deleteClothButton)
            myToolBarItems.append(flexibleItem)
            if let navigation = self.navigationController {
                navigation.toolbar.items = myToolBarItems
            }
        }
    }
    
    // MARK: Presenting or Dismissing
    func dismissViewControllerBackToClosets() {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func updateUserSpots() {
        if changeSpaceNumberPicker.selectedRow(inComponent: 0) != closet.getCapacity() {
            closet.setCapacity(changeSpaceNumberPicker.selectedRow(inComponent: 0))
            spot = Int(availableLabelValue.text!)!
            User().setSpot(spot)
        }
    }
    func recoverUserSpotsWhenDeletingCloset(_ numberOfClothes: Int) {
        let currentSpot = User().getSpot()
        User().setSpot(currentSpot + self.closet.getCapacity()-numberOfClothes)
    }
    
    
    
    // MARK: Picker View DataSource and Delegate\
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return closet.getCapacity() + spot + 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let height = pickerView.bounds.height
        return height*0.35
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let height = pickerView.bounds.height
        let width = pickerView.bounds.width
        let numberLabel = UILabel()
        numberLabel.frame = CGRect(x: 0, y: 0, width: width, height: height)
        numberLabel.text = "\(row)"
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.textColor = AppCustomColor().pink
        numberLabel.font = UIFont(name: "Klavika", size: CGFloat(35))
        return numberLabel
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let minimumNumberOfSpacesNeeded = closet.getClothes().count
        if row < minimumNumberOfSpacesNeeded {
            pickerView.selectRow(minimumNumberOfSpacesNeeded, inComponent: 0, animated: true)
            closetRemainingSpaces.text = "Mínimo de espaços para roupas"
            let amountChange = closet.getCapacity()-minimumNumberOfSpacesNeeded
            availableLabelValue.text = "\(spot+amountChange)"
        } else {
            closetRemainingSpaces.text = "\(row-closet.getClothes().count) espaços disponíveis"
            let amountChange = closet.getCapacity()-row
            availableLabelValue.text = "\(spot+amountChange)"
        }
    }
    
    
    
    // MARK: Table View DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typesOfClothesInCloset.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ClosetCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        let selectedCellView = UIView()
        selectedCellView.backgroundColor = AppCustomColor().lightGray
        cell.selectedBackgroundView = selectedCellView
        cell.backgroundColor = AppCustomColor().gray
        let type = typesOfClothesInCloset[indexPath.item]
        let image = UIImage(named: Enumerators().getImageForClothType(type))
        cell.clothTypeImage.image = image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.typeOfClothDescription.text =  typesOfClothesInCloset[(indexPath as NSIndexPath).item]
        cell.numberOfClothesOfType.text = "\(closet.getClothesOfType(type).count)"
        return cell
    }



}


// MARK: Custom Menu Cell
class ClosetCell: UITableViewCell {
    
    var clothTypeImage: UIImageView!
    var numberOfClothesOfType: UILabel!
    var typeOfClothDescription: UILabel!
    var menuArrow: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = self.frame.width
        let cellHeight = CGFloat(screenWidth*0.12)
        
        clothTypeImage = UIImageView()
        clothTypeImage.frame = CGRect(x: cellWidth*0.04, y: cellHeight*0.25, width: cellHeight*0.5, height: cellHeight*0.5)
        clothTypeImage.layer.masksToBounds = true
        clothTypeImage.contentMode = .scaleAspectFit
        clothTypeImage.tintColor = AppCustomColor().pink
        self.contentView.addSubview(clothTypeImage)
        
        typeOfClothDescription = UILabel()
        typeOfClothDescription.frame = CGRect(x: clothTypeImage.frame.origin.x + clothTypeImage.frame.width + cellWidth*0.03, y: cellHeight*0.3, width: cellWidth*0.5, height: cellHeight*0.3)
        typeOfClothDescription.textColor = AppCustomColor().pink
        self.contentView.addSubview(typeOfClothDescription)
        
        numberOfClothesOfType = UILabel()
        numberOfClothesOfType.frame = CGRect(x: clothTypeImage.frame.origin.x + clothTypeImage.frame.width + typeOfClothDescription.frame.width + cellWidth*0.03, y: cellHeight*0.3, width: cellWidth*0.8, height: cellHeight*0.3)
        numberOfClothesOfType.textColor = AppCustomColor().twiceLightGray
        self.contentView.addSubview(numberOfClothesOfType)
        
        menuArrow = UIImageView()
        menuArrow.frame = CGRect(x: screenWidth*0.9, y: cellHeight*0.35, width: cellHeight*0.3, height: cellHeight*0.3)
        menuArrow.image = UIImage(named: "menuArrow.png")
        menuArrow.contentMode = .scaleAspectFill
        menuArrow.tintColor = AppCustomColor().twiceLightGray
        self.contentView.addSubview(menuArrow)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}
