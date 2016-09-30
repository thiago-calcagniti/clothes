//
//  MyLooks.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 24/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import UIKit
import Parse

class MyLooks: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UpdateLooksCollection {

    // Transition to Menu
    
    var looks = Array<Look>()
    var looksCollectionView: UICollectionView!
    var lookSelected: Look!
    var newNameLook: SCLTextView!
    

    
    override func viewDidLoad() {
        
        
        print("\n\n\nLOOKS VIEW CONTROLLER IS BEING LOADED...")
        createBackground()
        createMenuButton()
        createAddLookButton()
        downloadLooksFromServer()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Meus Looks"
        if looksCollectionView != nil {
            looksCollectionView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.title = "Back"
    }
    
    
    //MARK: Setup Things
    func createBackground() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let background = UIImageView()
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.image = UIImage(named: "looksBackground.png")
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        
        self.edgesForExtendedLayout = UIRectEdge()
        print("Created Background.")
    }
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MyLooks.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
        print("Created Menu Button.")
    }
    func createAddLookButton() {
        let addLookButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(MyLooks.addNewLook))
        self.navigationItem.rightBarButtonItem = addLookButton
        print("Created Add New Look Button.")
    }
    func addNewLook() {
        let destinationController = CreateLookViewController(delegate: self)
        if let navigation = navigationController {
            navigation.pushViewController(destinationController, animated: true)
        }
        print("New look started to be created by user.")
    }
    func menuShow() {
        let destinationController = MenuViewController()
        Window().showMenuWithCustomTransition(sender: self)
    }
    
    
    //MARK: Download from Server
    func downloadLooksFromServer() {
        print("Downloadling looks from Server...")
        let looksQuery = PFQuery(className: "Looks")
        looksQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        looksQuery.findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    let id = object.objectId! 
                    let name = object["name"] as! String
                    let ownerId = object["ownerId"] as! String
                    let clothesId = object["clothes"] as! [String]
                    let clothesCoordinates = object["clothesCoordinates"] as! [[String]]
                    let coverImage:PFFile?
                    if let parseLookImage = object["coverImage"] as? PFFile {
                        coverImage = parseLookImage
                    } else {
                        coverImage = PFFile(data: UIImagePNGRepresentation(UIImage(named: "menuLooks.png")!)!)
                    }
                    let look = Look(id: "\(id)", name: name, ownerId: ownerId, clothesId: clothesId, parseFile: coverImage!)
                    look.setClothesCoordinates(clothesCoordinates)
                    
                    self.looks.append(look)
                    print("\nDownloading Look \(look.getName())...")
                }
                
                if objects.count > 0 {
                    
                    for look in self.looks {
                        if look.getClothesId().count > 0 {
                            for clothId in look.getClothesId() {
                                let clothQuery = PFQuery(className: "Clothes")
                                clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
                                clothQuery.getObjectInBackground(withId: clothId, block: { (object, error) -> Void in
                                    if error != nil {
                                        print(error)
                                    } else if let object = object {
                                        let id = object.objectId!
                                        let name = object["name"] as! String
                                        let type = object["type"] as! String
                                        let ownerId = object["ownerId"] as! String
                                        let image = object["image"] as! PFFile
                                        let cloth = Cloth(id: id, name: name, type: type, ownerId: ownerId, parseFile: image)
                                        look.addCloth(cloth)
                                        cloth.getImageWithPFFile()
                                        print("Downloaded cloth \(cloth.getName()).")
                                        
                                    }
                                })
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
            self.createLooksCollectionView()
        }

    }
    
    
    // MARK: Manage Looks Collection View
    func createLooksCollectionView() {
        
        let screenHeigth = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth*0.45, height: screenWidth*0.60)
        let leftOrRigthInset = (screenWidth - (layout.itemSize.width * 2))/3
        layout.sectionInset = UIEdgeInsets(top: 3, left: leftOrRigthInset, bottom: 1, right: leftOrRigthInset)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = CGFloat(0)
        layout.minimumLineSpacing = CGFloat(leftOrRigthInset)
        
        let frame = CGRect(x: screenWidth*0.0, y: screenWidth*0.01, width: screenWidth, height: screenHeigth*0.95 - 49)
        
        
        looksCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        looksCollectionView.layer.cornerRadius = CGFloat(7)
        looksCollectionView.dataSource = self
        looksCollectionView.delegate = self
        looksCollectionView.showsVerticalScrollIndicator = false
        looksCollectionView.register(LookCell.self, forCellWithReuseIdentifier: "Cell")
        looksCollectionView.backgroundColor = nil
        self.view.addSubview(looksCollectionView)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return looks.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LookCell
        let look = looks[(indexPath as NSIndexPath).item]
        cell.lookNameLabel.text = look.getName()
        
        if look.getDownloaded() {
            cell.lookImage.image = look.getThumbnail()
        } else {
            look.getImageWithPFFile({ (success) -> Void in
                if success {
                    cell.lookImage.image = look.getThumbnail()
                }
            })
        }

        
        cell.layer.cornerRadius = CGFloat(7)
        cell.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.7))
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LookCell
        let look = looks[(indexPath as NSIndexPath).item]
        lookSelected = look
        let lookName = look.getName()

        
        print("\nLook \(look.getName()) has been clicked by user.")
        let windowWidth = UIScreen.main.bounds.width*0.8
        let alert = SCLAlertView(newWindowWidth: windowWidth)
        
        alert?.showAnimationType = .SlideInFromBottom
        alert?.hideAnimationType = .SlideOutToBottom
        alert?.backgroundType = .Shadow
        alert?.shouldDismissOnTapOutside = true
        
        let changeLookName: SCLButton = alert!.addButton("Mudar Nome") {() -> Void in
            let screenWidth = UIScreen.main.bounds.width
            
            let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(screenWidth*0.7))
            self.newNameLook = alert.addTextField("Digite novo Nome")
            self.newNameLook.textAlignment = NSTextAlignment.center
            self.newNameLook.addTarget(self, action: #selector(MyLooks.prepareNewName(_:)), for: UIControlEvents.editingDidEndOnExit)
            let confirmButton: SCLButton = alert.addButton("Alterar Nome do Look", target: self, selector: #selector(MyLooks.changeLookNameByNewOne))
            alert.showCustom(UIImage(named: "name.png"), color: AppCustomColor().pink, title: "Alterar Nome", subTitle: "Qual nome gostaria fosse?", closeButtonTitle: "Cancelar", duration: 0.0)

        }

        let editLookButton: SCLButton = alert!.addButton("Editar Roupas") { () -> Void in
            let destinationController = CreateLookViewController(delegate: self, look: look)
            if let navigation = self.navigationController {
                navigation.pushViewController(destinationController, animated: true)
            }
        }
        let editImageButton: SCLButton = alert!.addButton("Alterar Capa") { () -> Void in
            
            
            let alert = UIAlertController(title: "Adicionar Capa do Look",
                message: "Gostaria de escolher uma capa?",
                preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let album = UIAlertAction(title: "Escolher do Album",
                style: UIAlertActionStyle.default,
                handler: { (getFromPhotoLibraryAction) -> Void in
                    self.takePictureFromPhotoLibrary()
            })
            let camera = UIAlertAction(title: "Tirar Foto",
                style: UIAlertActionStyle.default,
                handler: { (getFromPhotoLibraryAction) -> Void in
                    self.takeShot()
            })
            
            let cancel = UIAlertAction(title: "Cancelar",
                style: UIAlertActionStyle.cancel,
                handler: { (cancelAction) -> Void in
            })
            
            album.setValue(UIImage(named: "getAlbum.png"), forKey: "image")
            camera.setValue(UIImage(named: "takeShot.png"), forKey: "image")
            
            alert.addAction(album)
            alert.addAction(camera)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        
        }
        let deleteLookButton: SCLButton = alert!.addButton("Deletar") { () -> Void in
            let windowWidth = UIScreen.main.bounds.width*0.8
            let alert = SCLAlertView(newWindowWidth: windowWidth)
            let look = self.looks[(indexPath as NSIndexPath).item]
            let lookName = look.getName()
            alert?.showQuestion("Deletar \(lookName)", subTitle: "Tem deseja que deseja deletar este look?", closeButtonTitle: "Não foi sem querer!", duration: 0.0)
            let removeButton: SCLButton = alert!.addButton("Sim eu quero remover"){ () -> Void in
                let looksQuery = PFQuery(className: "Looks")
                looksQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
                looksQuery.getObjectInBackground(withId: look.getId(), block: { (object, error) -> Void in
                    if error != nil {
                    } else {
                        if let object = object {
                            object.deleteInBackground(block: { (success, error) -> Void in
                                if success {
                                    var index = 0
                                    for lookToBeDeleted in self.looks {
                                        if lookToBeDeleted.getId() == look.getId() {
                                            self.looks.remove(at: index)
                                            self.looksCollectionView.reloadData()
                                        } else {
                                            index = index + 1
                                        }
                                    }
                                }
                            })
                        }
                    }
                })
            }
            removeButton.backgroundColor = UIColor.gray
        }

        
        alert?.showCustom(look.getThumbnail(), color: AppCustomColor().pink, title: "Look \(lookName).", subTitle: "O que gostaria de fazer ?", closeButtonTitle: nil, duration: 0.0)
        print("Showing Menu...")
    }
    

    // MARK: Change Look Name Functions
    func prepareNewName(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func changeLookNameByNewOne() {
        if let newLookName = newNameLook.text {
            let looksQuery = PFQuery(className: "Looks")
            looksQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
            looksQuery.getObjectInBackground(withId: lookSelected.getId(), block: { (object, error) -> Void in
                if let object = object {
                    object["name"] = newLookName
                    object.saveInBackground(block: { (success, error) -> Void in
                        if success {
                            self.lookSelected.setName(newLookName)
                            self.looksCollectionView.reloadData()
                        }
                    })
                }
            })
        }
    }
    
    // MARK: Take or Get Pictures
    func takePictureFromPhotoLibrary() {
        let photoLibraryImage = UIImagePickerController()
        photoLibraryImage.sourceType = UIImagePickerControllerSourceType.photoLibrary
        photoLibraryImage.delegate = self
        photoLibraryImage.allowsEditing = true
        self.present(photoLibraryImage, animated: true, completion: nil)
        
    }
    func takeShot() {
        let cameraImage = UIImagePickerController()
        cameraImage.sourceType = UIImagePickerControllerSourceType.camera
        cameraImage.delegate = self
        cameraImage.allowsEditing = true
        cameraImage.showsCameraControls = true
        self.present(cameraImage, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let lookQuery = PFQuery(className: "Looks")
        self.lookSelected.setImage(image)
        lookQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        lookQuery.getObjectInBackground(withId: lookSelected.getId()) { (object, error) -> Void in
            if let object = object {
                let imageData = UIImagePNGRepresentation(image)
                let imageFile = PFFile(name: "\(self.lookSelected.getId()).png", data: imageData!)
                object["coverImage"] = imageFile
                object.saveInBackground(block: { (success, error) -> Void in
                    print("Imagem foi salva")

                })
            }
        }
        self.looksCollectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Update Looks Collection View
    func updateLooksCollectionViewAfterNewLookAdded(_ newLook: Look) {
        looks.append(newLook)
        var lookIds = [String]()
        for look in looks {
            lookIds.append(look.getId())
        }
        let lookQuery = PFQuery(className: "Looks")
        lookQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        lookQuery.findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    let id = object.objectId!
                    if !lookIds.contains(id) {
                        newLook.setId(id)
                    }
                    
                }
            }
        }
        print("Voltei \(looks.count)")
        looksCollectionView.reloadData()
    }

    
    deinit {
        print("MyLooksViewController has been deinitialized.")
    }

    

    
    
}






// MARK: Class to Create Custom Clothes UICollectionViewCell
class LookCell: UICollectionViewCell {
    var lookImage: UIImageView!
    var lookNameLabel: UILabel!
    override init(frame: CGRect) {
        lookImage = UIImageView(frame: CGRect(x: frame.size.width*0.025, y: frame.size.width*0.025, width: frame.size.width*0.95, height: frame.size.height*0.81))
        lookNameLabel = UILabel(frame: CGRect(x: 0, y: frame.size.height*0.85, width: frame.size.width, height: frame.size.height*0.15))
        super.init(frame: frame)
        lookImage.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.6))
        lookImage.layer.cornerRadius = CGFloat(4)
        lookImage.contentMode = UIViewContentMode.scaleAspectFit
        lookImage.clipsToBounds = true
        lookImage.backgroundColor = nil
        contentView.addSubview(lookImage)
        
        
        lookNameLabel.textAlignment = NSTextAlignment.center
        lookNameLabel.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.8))
        lookNameLabel.font = UIFont(name: "Klavika", size: CGFloat(16))
        lookNameLabel.textColor = AppCustomColor().darkGray
        contentView.addSubview(lookNameLabel)
        
        self.clipsToBounds = true
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

