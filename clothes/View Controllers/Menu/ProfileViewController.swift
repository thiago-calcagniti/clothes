//
//  ProfileViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 08/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol ChangeProfilePicture {
    func changeProfilePicture(_ newProfileImage: UIImage)
}


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
ChangeAge, ChangeHomeplace, ChangeGender, ChangeHeight, ChangeWeight, ChangeAppearance, ChangeAccount {
    
    // Profile Values
    var arrayOfParameters = Array<String>()
    var parametersValues = Array<String>()
    var arrayOfIcons = Array<String>()
    
    var profileFrame = UIImageView()
    let profileName = UILabel()
    var tableView: UITableView!
    var profilePicture: UIImage?
    var delegate: ChangeProfilePicture?
    
    var newNameUser: SCLTextView!
    
    
    // User Parameters
    var latitude: Double!
    var longitude: Double!
    
    
    
    // Initializers
    init(delegate: ChangeProfilePicture, profilePicture: UIImage) {
        self.delegate = delegate
        self.profilePicture = profilePicture
        super.init(nibName: "ProfileViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        arrayOfParameters = ["Residência","Idade","Sexo","Altura (cm)","Peso (kg)","Aparência", "Informações da Conta"]
        parametersValues = ["","","","","","",""]
        arrayOfIcons = ["residencia.png","age.png","gender.png","height.png","weight.png","shape.png", "account.png"]
        
        self.view.backgroundColor = AppCustomColor().darkGray
        createMenuButton()
        self.edgesForExtendedLayout = UIRectEdge()
        
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*1.2), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = AppCustomColor().darkGray
        tableView.separatorColor = AppCustomColor().lightGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        
        // Retrieve Information from Parse
        getHomeplace()
        getAge()
        getGender()
        getHeight()
        getWeight()
        getAppearance()
        getEmail()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Meu Perfil"
        
    }

    
    
    // MARK: Setup Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfParameters.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ProfileCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
       
        let selectedCellView = UIView()
        selectedCellView.backgroundColor = AppCustomColor().lightGray
        cell.selectedBackgroundView = selectedCellView
        
        
        cell.menuImage.image = UIImage(named: arrayOfIcons[(indexPath as NSIndexPath).row])?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.menuName.text = arrayOfParameters[(indexPath as NSIndexPath).row]
        cell.menuValue.text = parametersValues[(indexPath as NSIndexPath).row]
        
        
        cell.backgroundColor = AppCustomColor().darkGray
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth*0.12
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight*0.5
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let viewHeader = UIView()
        viewHeader.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*0.50)
        viewHeader.layer.masksToBounds = true
        
        profileFrame.frame = CGRect(x: 0, y: 0, width: screenWidth, height: viewHeader.frame.height)
        profileFrame.image = profilePicture
        profileFrame.contentMode = .scaleAspectFill
        profileFrame.layer.masksToBounds = true
        profileFrame.isUserInteractionEnabled = true
        let tapGesturePicture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.changePicture(_:)))
        tapGesturePicture.numberOfTapsRequired = 1
        profileFrame.addGestureRecognizer(tapGesturePicture)
        

        profileName.frame = CGRect(x: 0, y: screenHeight*0.43, width: screenWidth, height: screenHeight*0.07)
        profileName.text = ""
        profileName.font = UIFont(name: "Klavika", size: CGFloat(17))
        profileName.textColor = UIColor.white
        profileName.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.4))
        profileName.isUserInteractionEnabled = true
        let tapGestureName = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.changeName(_:)))
        tapGestureName.numberOfTapsRequired = 1
        profileName.addGestureRecognizer(tapGestureName)
        
        viewHeader.addSubview(profileFrame)
        viewHeader.addSubview(profileName)

        updateProfileTitle()
        
        return viewHeader
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = ProfileCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        let destinationController = goToEditController((indexPath as NSIndexPath).row)
        if let navigation = navigationController {
            navigation.pushViewController(destinationController, animated: true)
        }
    }
    
    
    // MARK: Load Menu Pages
    func goToEditController(_ index: Int) -> UIViewController {
        let homeplaceController = HomeplaceViewController(delegate: self, latitude: latitude, longitude: longitude)
        let ageController = AgeViewController(delegate: self, age: Int(parametersValues[1])!)
        let genderController = GenderViewController(delegate: self, gender: parametersValues[2])
        let heightController = HeightViewController(delegate: self, height: Int(parametersValues[3])!)
        let weightController = WeightViewController(delegate: self, weight: Int(parametersValues[4])!)
        let shapeController = AppearanceViewController(delegate: self, appearance: parametersValues[5], gender: parametersValues[2])
        let accountController = AccountViewController(delegate: self, email: parametersValues[6])
        
        let arrayOfControllers: Array<UIViewController> = [homeplaceController,
                                  ageController,
                                  genderController,
                                  heightController,
                                  weightController,
                                  shapeController,
                                  accountController]
        
        let destinationController = arrayOfControllers[index]
        return destinationController
    }

    
    
    
    
    // MARK: Setup Navigation Items
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
    }
    func menuShow() {
        Window().showMenu()
    }
    
    
    
    
    // MARK: Gather User Parameters
    func getHomeplace(){
        let user = PFUser.current()!
        if let userHomeplace = user["homeplace"] as? PFGeoPoint {
            latitude = userHomeplace.latitude
            longitude = userHomeplace.longitude


            let location = CLLocation(latitude: latitude, longitude: longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarkers, error) -> Void in
                if (error == nil) {
                    if let place = placemarkers?[0] {
                        if let city = place.addressDictionary!["City"] as? NSString {
                            self.parametersValues[0] = city as String
                            if let _ = self.tableView {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            })
        } else {
            self.latitude = 0
            self.longitude = 0
            self.parametersValues[0] = ""
        }
    }
    func getAge(){
        let user = PFUser.current()!
        if let userAge = user["age"] as? Int {
                self.parametersValues[1] = "\(userAge)" as String
            if let _ = self.tableView {
                self.tableView.reloadData()
            }
        } else {
            self.parametersValues[1] = "0"
        }
    }
    func getGender(){
        let user = PFUser.current()!
        if let userGender = user["gender"] as? String {
            self.parametersValues[2] = "\(userGender)" as String
            if let _ = self.tableView {
                self.tableView.reloadData()
            }
        } else {
            self.parametersValues[2] = "Feminino"
        }
    }
    func getHeight(){
        let user = PFUser.current()!
        if let userHeight = user["height"] as? Int {
            self.parametersValues[3] = "\(userHeight)" as String
            if let _ = self.tableView {
                self.tableView.reloadData()
            }
        } else {
            self.parametersValues[3] = "0"
        }
    }
    func getWeight(){
        let user = PFUser.current()!
        if let userWeight = user["weight"] as? Int {
            self.parametersValues[4] = "\(userWeight)" as String
            if let _ = self.tableView {
                self.tableView.reloadData()
            }
        } else {
            self.parametersValues[4] = "0"
        }
    }
    func getAppearance(){
        let user = PFUser.current()!
        if let userAppearance = user["appearance"] as? NSString {
            self.parametersValues[5] = "\(userAppearance)" as String
            if let _ = self.tableView {
                self.tableView.reloadData()
            }
        } else {
            self.parametersValues[5] = "Indefinido"
        }
    }
    func getEmail() {
        let user = PFUser.current()!
        if let userEmail = user.email {
            print(userEmail)
            self.parametersValues[6] = "\(userEmail)" as String
            if let _ = self.tableView {
                self.tableView.reloadData()
            }
            else {
                self.parametersValues[6] = ""
            }
        }
    }
    func updateProfileTitle() {
        let user = PFUser.current()!
        if let userNickname = user["nickname"] as? String {
            print(userNickname)
            profileName.text = "  \(userNickname)"
        } else {
            profileName.text = "  Altere seu apelido clicando aqui"
        }
    }
    
    
    
    
    // MARK: Delegate Functions
    func changeHomeplace(_ newPlace: String, newLatitude: Double, newLongitude: Double) {
        parametersValues[0] = newPlace
        latitude = newLatitude
        longitude = newLongitude
        tableView.reloadData()
    }
    func changeAge(_ newAge: Int) {
        parametersValues[1] = "\(newAge)"
        tableView.reloadData()
    }
    func changeGender(_ newGender: String) {
        parametersValues[2] = "\(newGender)"
        tableView.reloadData()
    }
    func changeHeight(_ newHeight: Int) {
        parametersValues[3] = "\(newHeight)"
        tableView.reloadData()
    }
    func changeWeight(_ newWeight: Int) {
        parametersValues[4] = "\(newWeight)"
        tableView.reloadData()
    }
    func changeAppearance(_ newAppearance: String) {
        parametersValues[5] = "\(newAppearance)"
        tableView.reloadData()
    }
    func changeEmail(_ newEmail: String) {
        parametersValues[6] = "\(newEmail)"
        tableView.reloadData()
    }


    
    // MARK: Get Profile Picture
    func changePicture(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Adicionar Foto de Perfil",
            message: "",
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let album = UIAlertAction(title: "Escolher do Album",
            style: UIAlertActionStyle.default,
            handler: { (getFromPhotoLibraryAction) -> Void in
                self.takePictureFromPhotoLibrary()
        })
        let cancel = UIAlertAction(title: "Cancelar",
            style: UIAlertActionStyle.cancel,
            handler: { (cancelAction) -> Void in
        })
        
        album.setValue(UIImage(named: "getAlbum.png"), forKey: "image")
        
        alert.addAction(album)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    func takePictureFromPhotoLibrary() {
        let photoLibraryImage = UIImagePickerController()
        photoLibraryImage.sourceType = UIImagePickerControllerSourceType.photoLibrary
        photoLibraryImage.delegate = self
        photoLibraryImage.allowsEditing = true
        self.present(photoLibraryImage, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        
        let user = PFUser.current()!
        let imageData = UIImagePNGRepresentation(image)
        let imageFile = PFFile(name: "userProfilePicture.png", data: imageData!)
        user["profilePicture"] = imageFile
        user.saveInBackground { (success, error) -> Void in
            if success {
                self.profileFrame.image = image
                self.delegate?.changeProfilePicture(image)
            }
        }
    }
    
    // MARK: Change User NickName
    func changeName(_ gesture: UITapGestureRecognizer) {
        let screenWidth = UIScreen.main.bounds.width
        
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(screenWidth*0.7))
        newNameUser = alert.addTextField("Digite novo apelido")
        newNameUser.textAlignment = NSTextAlignment.center
        newNameUser.addTarget(self, action: #selector(ProfileViewController.prepareNewName(_:)), for: UIControlEvents.editingDidEndOnExit)
        let confirmButton: SCLButton = alert.addButton("Alterar Apelido", target: self, selector: #selector(ProfileViewController.changeNicknameByNewOne))
        alert.showCustom(UIImage(named: "name.png"), color: AppCustomColor().pink, title: "Alterar Apelido", subTitle: "Qual apelido gostaria de ter?", closeButtonTitle: "Cancelar", duration: 0.0)
    }
    func prepareNewName(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func changeNicknameByNewOne() {
        if let newNickname = newNameUser.text {
            let user = PFUser.current()!
            user["nickname"] = newNickname
            user.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.profileName.text = "  \(newNickname)"
                }
            })
        }
    }
    
    
    

}



// MARK: Custom Menu Cell
class ProfileCell: UITableViewCell {
    
    var menuImage: UIImageView!
    var menuName: UILabel!
    var menuValue: UILabel!
    var menuArrow: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = self.frame.width
        let cellHeight = CGFloat(screenWidth*0.15)
        
        menuImage = UIImageView()
        menuImage.frame = CGRect(x: cellWidth*0.04, y: cellHeight*0.2, width: cellHeight*0.5, height: cellHeight*0.5)
        menuImage.layer.masksToBounds = true
        menuImage.contentMode = .scaleAspectFit
        menuImage.tintColor = AppCustomColor().pink
        self.contentView.addSubview(menuImage)
        
        menuName = UILabel()
        menuName.frame = CGRect(x: menuImage.frame.origin.x + menuImage.frame.width + cellWidth*0.03, y: cellHeight*0.1, width: cellWidth*0.8, height: cellHeight*0.3)
        menuName.textColor = AppCustomColor().twiceLightGray
        menuName.font = UIFont(name: (menuName.font?.fontName)!, size: CGFloat(11))
        self.contentView.addSubview(menuName)
        
        menuValue = UILabel()
        menuValue.frame = CGRect(x: menuImage.frame.origin.x + menuImage.frame.width + cellWidth*0.03, y: cellHeight*0.36, width: cellWidth*0.8, height: cellHeight*0.4)
        menuValue.textColor = AppCustomColor().twiceLightGray
        menuValue.font = UIFont(name: (menuValue.font?.fontName)!, size: CGFloat(15))
        self.contentView.addSubview(menuValue)
        
        menuArrow = UIImageView()
        menuArrow.frame = CGRect(x: cellWidth*0.85, y: cellHeight*0.28, width: cellHeight*0.28, height: cellHeight*0.3)
        menuArrow.image = UIImage(named: "menuArrow.png")
        menuArrow.contentMode = .scaleAspectFill
        menuArrow.tintColor = AppCustomColor().twiceLightGray
        self.contentView.addSubview(menuArrow)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}

