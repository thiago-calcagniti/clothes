//
//  EditLookViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 16/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol UpdateLooksCollection {
    func updateLooksCollectionViewAfterNewLookAdded(_ newLook: Look)
}


class CreateLookViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


    
    var clothesOptionCollectionView: UICollectionView!
    var showSelectorButton: UIImageView!
    var allClothes: Array<Cloth> = Array<Cloth>()
    var clothes: Array<Cloth> = Array<Cloth>()
    var allClothesImages = Array<PFFile>()
    var clothesImages = Array<PFFile>()
    var typesOfClothes = Array<String>()
    var typesOfOccasions = Array<String>()
    var selectedTypes = Array<Bool>()
    var indexesOfSelectedTypes = Array<Int>()
    var selectedOccasions = Array<Bool>()
    var indexesOfSelectedOccasions = Array<Int>()
    var sizeOfCloth: CGFloat!

    
    // For Filters
    var typeFilter: UIButton!
    var occasionFilter: UIButton!
    var typeFilterIsPressed: Bool = false
    var occasionFilterIsPressed: Bool = false
    
    
    // Managing Views Data
    var arrayOfClothesInLook = Array<Cloth>()
    var arrayOfImagesInLook = Array<UIImageView>()
    var arrayOfAddedClothes = Array<Cloth>()
    var arrayOfRemovedClothes = Array<Cloth>()
    
    
    // For look available
    var look: Look?
    var delegate: UpdateLooksCollection?
    var newLook: Look?
    
    
    // Initializers
    init(delegate: UpdateLooksCollection, look: Look) {
        self.delegate = delegate
        self.look = look
        super.init(nibName: "CreateLookViewController", bundle: nil)
    }
    init(delegate: UpdateLooksCollection) {
        self.delegate = delegate
        super.init(nibName: "CreateLookViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        
        print("\n\n\nEDIT LOOK VIEW CONTROLLER IS BEING LOADED.")
        let screenHeigth = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        createBackground()
        downloadClothesToScrollView()
        createSelectorClothesCollectionView()
        createTypeFilterButton()
        createOccasionFilterButton()
        createSaveLookButton()
        loadLook()
    }


    // MARK: Setup Scene
    func createBackground() {
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
    
        sizeOfCloth = screenWidth/3
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        let background = UIImageView()
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.image = UIImage(named: "looksBackground.png")
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        
        let board = UIView()
        board.frame = CGRect(x: screenWidth*0.015, y: screenWidth*0.015, width: screenWidth*0.97, height: screenHeight*0.95 - 48)
        board.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.4))
        board.layer.cornerRadius = CGFloat(7)
        self.view.addSubview(board)
        
        print("Background Created.")
        
        if let look = look {
            self.title = "\(look.getName())"
            print("Editing Session opened for \(look.getName()).")
        } else {
            self.title = "Criar Look"
            print("Creating Session created for new Look.")
        }
        
    }
    func createTypeFilterButton() {
        let screenHeigth = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let imageOfButton = UIImage(named: "typeFilterVector.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        typeFilter = UIButton()
        typeFilter.frame = CGRect(x: screenWidth*0.56, y: screenHeigth*0.43, width: screenWidth*0.18, height: screenWidth*0.18)
        typeFilter.setImage(imageOfButton, for: UIControlState())
        typeFilter.tintColor = AppCustomColor().lightGray
        typeFilter.contentMode = .scaleAspectFit
        typeFilter.addTarget(self, action: #selector(CreateLookViewController.filterClothByType), for: UIControlEvents.touchUpInside)
        typeFilter.backgroundColor = UIColor.white
        typeFilter.layer.cornerRadius = typeFilter.frame.width/2
        typeFilter.layer.borderWidth = 3
        typeFilter.layer.borderColor = UIColor.white.cgColor
        self.view.addSubview(typeFilter)
        print("Create button to filter clothes by Type.")
    }
    func createOccasionFilterButton() {
        let screenHeigth = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let imageOfButton = UIImage(named: "occasionFilterVector.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        occasionFilter = UIButton()
        occasionFilter.frame = CGRect(x: screenWidth*0.56, y: screenHeigth*0.32, width: screenWidth*0.18, height: screenWidth*0.18)
        occasionFilter.setImage(imageOfButton, for: UIControlState())
        occasionFilter.tintColor = AppCustomColor().lightGray
        occasionFilter.contentMode = .scaleAspectFit
        occasionFilter.addTarget(self, action: #selector(CreateLookViewController.filterClothByOccasion), for: UIControlEvents.touchUpInside)
        occasionFilter.backgroundColor = UIColor.white
        occasionFilter.layer.cornerRadius = typeFilter.frame.width/2
        occasionFilter.layer.borderWidth = 3
        occasionFilter.layer.borderColor = UIColor.white.cgColor
        self.view.addSubview(occasionFilter)
        print("Create button to filter clothes by Occasion.")
    }
    func createSaveLookButton() {
        let saveLookButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(CreateLookViewController.saveLook))
        self.navigationItem.rightBarButtonItem = saveLookButton
        print("Created Button to save the look.")
    }
    func saveLook() {
        let screenWidth = UIScreen.main.bounds.width
        
        if let look = look {
            print("look ja existente")
            let lookQuery = PFQuery(className: "Looks")
            lookQuery.whereKey("ownerId", equalTo: look.getOwnerId())
            lookQuery.getObjectInBackground(withId: look.getId(), block: { (object, error) -> Void in
                if error != nil {
                    print(error)
                } else if let object = object {
                    var lookClothes = [String]()
                    var lookCoordinates = [[String]]()
                    for cloth in self.arrayOfClothesInLook {
                        lookClothes.append(cloth.getId())
                        lookCoordinates.append(cloth.getLookString())
                    }
                    object["clothes"] = lookClothes
                    object["clothesCoordinates"] = lookCoordinates
                    object.saveInBackground(block: { (success, error) -> Void in
                        if success {
                            let alert = SCLAlertView(newWindowWidth: screenWidth*0.7)
                            print("\(lookCoordinates)")
                            alert?.showSuccess("Sucesso!", subTitle: "Seu look foi alterado com sucesso!", closeButtonTitle: "Adorei!", duration: 2.0)
                            for cloth in self.arrayOfAddedClothes {
                                look.addCloth(cloth)
                            }
                            for cloth in self.arrayOfRemovedClothes {
                                look.removeCloth(cloth)
                            }
                            look.setClothesCoordinates(lookCoordinates)
                            self.dismissViewControllerBackToLooks()
                        }
                    })
                }
            })
            
        } else {
            
            
            let alert = SCLAlertView(newWindowWidth: CGFloat(screenWidth*0.7))
            let lookNameTextField = alert?.addTextField("Qual é o nome do Look?")
            lookNameTextField?.textAlignment = NSTextAlignment.center
            lookNameTextField?.addTarget(self, action: #selector(CreateLookViewController.dismissKeyboard(_:)), for: UIControlEvents.editingDidEndOnExit)
            let occasionNameTextField = alert?.addTextField("Qual Ocasião?")
            occasionNameTextField?.textAlignment = NSTextAlignment.center
            occasionNameTextField?.addTarget(self, action: #selector(CreateLookViewController.dismissKeyboard(_:)), for: UIControlEvents.editingDidEndOnExit)
            alert?.addButton("Criar", actionBlock: {
                lookNameTextField?.resignFirstResponder()
                occasionNameTextField?.resignFirstResponder()
                let look = PFObject(className: "Looks")
                look["name"] = lookNameTextField?.text
                look["ownerId"] = (PFUser.current()?.objectId)!
                var lookClothes = [String]()
                var lookCoordinates = [[String]]()
                for cloth in self.arrayOfClothesInLook {
                    lookClothes.append(cloth.getId())
                    lookCoordinates.append(cloth.getLookString())
                }
                look["clothes"] = lookClothes
                look["clothesCoordinates"] = lookCoordinates
                look["occasion"] = occasionNameTextField?.text
                look.saveInBackground { (success, error) -> Void in
                    if success {
                        let alert = SCLAlertView(newWindowWidth: screenWidth*0.7)
                        alert?.showSuccess("Sucesso!", subTitle: "Novo look criado com sucesso!", closeButtonTitle: "Demais", duration: 2.0)
                        self.newLook = Look(id: "Novo", name: (lookNameTextField?.text!)!, ownerId: (PFUser.current()?.objectId)!, clothesId: lookClothes)
                        for cloth in self.arrayOfClothesInLook {
                            self.newLook!.addCloth(cloth)
                        }
                        
                        self.delegate?.updateLooksCollectionViewAfterNewLookAdded(self.newLook!)
                        self.dismissViewControllerBackToLooks()
                        
                    }
                }
            })
            alert?.showCustom(UIImage(named: "menuLooks.png"), color: AppCustomColor().pink, title: "Criar Novo Look", subTitle: "Que legal, vamos salvar este novo look!!", closeButtonTitle: "Cancelar", duration: 0.0)
        }
    }
    func dismissKeyboard(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func dismissViewControllerBackToLooks() {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
   
    // MARK: Download from Server
    func loadLook(){
        if let look = look {
            print("Loading look \(look.getName())...")
            hideClothesSelector()
            arrayOfClothesInLook = look.getClothes()
            var index = 0
            for cloth in arrayOfClothesInLook {
                if !cloth.getDownloaded() {
                    cloth.getImageWithPFFile()
                    print("Downloading image from \(cloth.getName())...")
                }
                cloth.getCoordinatesStringFromLook(look.getClothesCoordinates(index))
                index = index + 1
                let imageToBeAdded = self.addClothToView(cloth)
                imageToBeAdded.tag = self.arrayOfImagesInLook.count
                self.view.addSubview(imageToBeAdded)
                self.arrayOfImagesInLook.append(imageToBeAdded)
            }
        }
    }
    func downloadClothesToScrollView() {
        print("Downloading clothes from Server to scrollview...")
        let clothesQuery = PFQuery(className: "Clothes")
        clothesQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothesQuery.findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    let id = object.objectId! 
                    let name = object["name"] as! String
                    let type = object["type"] as! String
                    let ownerId = object["ownerId"] as! String
                    let image = object["image"] as! PFFile
                    let occasions = object["occasions"] as! [String]
                    let cloth = Cloth(id: id, name: name, type: type, ownerId: ownerId)
                    self.clothes.append(cloth)
                    self.clothesImages.append(image)
                    self.clothesOptionCollectionView.reloadData()
                    
                    self.allClothes.append(cloth)
                    self.allClothesImages.append(image)
                    
                    self.typesOfClothes.append(type)
                    if occasions != [] {
                        for occasion in occasions {
                            self.typesOfOccasions.append(occasion)
                        }
                    }
                    
                }
                self.typesOfOccasions = Array(Set(self.typesOfOccasions))
                self.typesOfOccasions.sort()
                for occasion in self.typesOfOccasions {
                    self.selectedOccasions.append(false)
                }
                
                self.typesOfClothes = Array(Set(self.typesOfClothes))
                self.typesOfClothes.sort()
                for type in self.typesOfClothes {
                    self.selectedTypes.append(false)
                }
                
                
                
            }
        }
    }
    

    // MARK: Create Selector CollectionView
    func createSelectorClothesCollectionView() {
        let screenHeigth = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth*0.3, height: screenWidth*0.3)
        let space = screenWidth*0.02
        layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = CGFloat(0)
        layout.minimumLineSpacing = CGFloat(space)
        
        let frame = CGRect(x: screenWidth*0.65, y: screenHeigth*0.01, width: screenWidth*0.34, height: screenHeigth*0.95 - 49)
        
        clothesOptionCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        clothesOptionCollectionView.layer.cornerRadius = CGFloat(7)
        clothesOptionCollectionView.dataSource = self
        clothesOptionCollectionView.delegate = self
        clothesOptionCollectionView.showsVerticalScrollIndicator = false
        clothesOptionCollectionView.register(OptionCell.self, forCellWithReuseIdentifier: "Cell")
        clothesOptionCollectionView.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(1))
        self.view.addSubview(clothesOptionCollectionView)
        
        let swipeHideGesture = UISwipeGestureRecognizer(target: self, action: #selector(CreateLookViewController.hideClothesSelectorOnGesture(_:)))
        swipeHideGesture.direction = .right
        clothesOptionCollectionView.addGestureRecognizer(swipeHideGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CreateLookViewController.handleLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.3
        clothesOptionCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    
    
    // MARK: Selector of Clothes
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if typeFilterIsPressed {
            return typesOfClothes.count
        } else if occasionFilterIsPressed {
            return typesOfOccasions.count
        } else {
        return clothes.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! OptionCell
        
        if typeFilterIsPressed {
            let typeImage = "l\(Enumerators().getImageForClothType(typesOfClothes[(indexPath as NSIndexPath).item]))"
            cell.optionImage.image  = UIImage(named: typeImage)?.withRenderingMode(.alwaysTemplate)
            cell.optionImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            cell.optionImage.tintColor = AppCustomColor().lightGray
            cell.backgroundColor = nil
            if selectedTypes[(indexPath as NSIndexPath).item] {
                cell.optionImage.tintColor = AppCustomColor().pink
            }
            
            
            
        } else if occasionFilterIsPressed {
            let occasionImage = Enumerators().getImageForOccasionTypes(typesOfOccasions[(indexPath as NSIndexPath).item])
            cell.optionImage.image = UIImage(named: occasionImage)?.withRenderingMode(.alwaysTemplate)
            cell.optionImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            cell.optionImage.tintColor = AppCustomColor().lightGray
            cell.backgroundColor = nil
            if selectedOccasions[(indexPath as NSIndexPath).item] {
                cell.optionImage.tintColor = AppCustomColor().pink
            }
            
        } else {
            let cloth = self.clothes[(indexPath as NSIndexPath).item]
            cell.optionImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            cell.optionLabel.text = ""
            cell.backgroundColor = nil
            if cloth.getDownloaded() {
                cell.optionImage.image = cloth.getThumbnail()
            } else {
                clothesImages[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
                    if let downloadedImage = UIImage(data: data!) {
                        cell.optionImage.image = downloadedImage
                        cloth.setImage(downloadedImage)
                        cloth.setDownloaded(true)
                        
                    }
                }
            }
        }
        
        cell.layer.cornerRadius = CGFloat(7)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if typeFilterIsPressed {
            let atIndex = (indexPath as NSIndexPath).item
            updateSelectedType(atIndex)
            
            indexesOfSelectedTypes = []
            
            for selection in 0...(selectedTypes.count - 1) {
                if selectedTypes[selection] {
                        let type = typesOfClothes[selection]
                        let allTheClothes = allClothes
                        for cloth in allTheClothes {
                            if cloth.getType() == type {
                                if let index = allTheClothes.index(where: { (Cloth) -> Bool in
                                    return Cloth.getId() == cloth.getId()
                                }) {
                                    indexesOfSelectedTypes.append(index)
                                }
                            }
                        }
                }
            }
            
            indexesOfSelectedTypes = Array(Set(indexesOfSelectedTypes)).sorted()
            print("Numero de tipos: \(indexesOfSelectedTypes.count)")
            var allIndexes:Array = Array(Set(indexesOfSelectedTypes).intersection(Set(indexesOfSelectedOccasions)))
            if indexesOfSelectedOccasions.count == 0 {
                allIndexes = indexesOfSelectedTypes
                print("Sem ocasioes o valor dos tipos é = \(indexesOfSelectedTypes.count)")
            } else if indexesOfSelectedTypes.count == 0 {
                allIndexes = indexesOfSelectedOccasions
            }
            
            clothes = []
            clothesImages = []
            for index in allIndexes {
                clothes.append(allClothes[index])
                clothesImages.append(allClothesImages[index])
            }
            
            
            if allIndexes.count == 0 {
                clothes = allClothes
                clothesImages = allClothesImages
            }
            
            clothesOptionCollectionView.reloadData()
            
            
  

            
            
            

            print("choosed type is \(typesOfClothes[(indexPath as NSIndexPath).item])")
        } else if occasionFilterIsPressed {
            let atIndex = (indexPath as NSIndexPath).item
            updateSelectedOccasion(atIndex)
            
            indexesOfSelectedOccasions = []
            
            for selection in 0...(selectedOccasions.count - 1) {
                if selectedOccasions[selection] {
                    let occasion = typesOfOccasions[selection]
                    let allTheClothes = allClothes
                    for cloth in allTheClothes {
                        if cloth.hasOccasion(occasion) == occasion {
                            if let index = allTheClothes.index(where: { (Cloth) -> Bool in
                                return Cloth.getId() == cloth.getId()
                            }) {
                                indexesOfSelectedOccasions.append(index)
                            }
                        }
                    }
                }
            }
            
            indexesOfSelectedOccasions = Array(Set(indexesOfSelectedOccasions)).sorted()
            print("Numero de ocasioes: \(indexesOfSelectedOccasions.count)")
            var allIndexes:Array = Array(Set(indexesOfSelectedOccasions).intersection(Set(indexesOfSelectedTypes)))
            if indexesOfSelectedTypes.count == 0 {
                allIndexes = indexesOfSelectedOccasions
            } else if indexesOfSelectedOccasions.count == 0 {
                allIndexes = indexesOfSelectedTypes
            }
            
            
            clothes = []
            clothesImages = []
            for index in allIndexes {
                clothes.append(allClothes[index])
                clothesImages.append(allClothesImages[index])
            }
            
            
            if allIndexes.count == 0 {
                clothes = allClothes
                clothesImages = allClothesImages
            }
            
            clothesOptionCollectionView.reloadData()
            
            
            
            
            
            
            
            
            print("choosed occasion is \(typesOfOccasions[(indexPath as NSIndexPath).item])")
        }else {
          print(clothes[(indexPath as NSIndexPath).item].getName())
        }
    }
    func updateSelectedType(_ atIndex: Int) {
        selectedTypes[atIndex] = !selectedTypes[atIndex]
        print(selectedTypes)
    }
    func updateSelectedOccasion(_ atIndex: Int) {
        selectedOccasions[atIndex] = !selectedOccasions[atIndex]
        print(selectedOccasions)
    }
    
    
    
    // MARK: Drag a View from Clothes Option Collection VIew + Gestures
    func addClothToView(_ cloth: Cloth) -> UIImageView {
        
        let image = cloth.getImage()
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: cloth.getWidth(), height: cloth.getHeight())
        imageView.center = CGPoint(x: cloth.getCenterInX(), y: cloth.getCenterInY())
        imageView.transform = imageView.transform.rotated(by: cloth.getRotation())
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = CGFloat(7)
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.tag = arrayOfClothesInLook.count
        
        print("Adding \(cloth.getName()) to view with coordinates. \n  width: \(cloth.getWidth())\n  height: \(cloth.getHeight())\n  centerX: \(cloth.getCenterInX())\n  centerY: \(cloth.getCenterInY())\n  rotation: \(cloth.getRotation())\n")
        

        
        
        // Add Pan Gesture to the Cloth
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CreateLookViewController.moveCloth(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        // Add Tap Gesture to the Cloth
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateLookViewController.bringToFront(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(tapGesture)
        
        // Add Scale Gesture to the Cloth
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CreateLookViewController.scaleCloth(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        // Add Rotation Gesture to the Cloth
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(CreateLookViewController.rotateCloth(_:)))
        imageView.addGestureRecognizer(rotationGesture)
        
        // Add Delete Gesture
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateLookViewController.deleteCloth(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(doubleTapGesture)
        
        return imageView
    }
    func addViewToLook(_ image: UIImage = UIImage()) -> UIImageView {
        

        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: sizeOfCloth, height: sizeOfCloth)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = CGFloat(7)
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.tag = arrayOfClothesInLook.count
        
        
        
        // Add Pan Gesture to the Cloth
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CreateLookViewController.moveCloth(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        // Add Tap Gesture to the Cloth
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateLookViewController.bringToFront(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(tapGesture)
        
        // Add Scale Gesture to the Cloth
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CreateLookViewController.scaleCloth(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        // Add Rotation Gesture to the Cloth
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(CreateLookViewController.rotateCloth(_:)))
        imageView.addGestureRecognizer(rotationGesture)
        
        // Add Delete Gesture
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateLookViewController.deleteCloth(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(doubleTapGesture)
        
        return imageView
    }
    func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        var clothIndexPath = Int()
        switch (gesture.state) {
        case .began:
            guard let selectedIndexPath = clothesOptionCollectionView.indexPathForItem(at: gesture.location(in: clothesOptionCollectionView))
                else {break}
            clothIndexPath = (selectedIndexPath as NSIndexPath).item
            let cloth = clothes[clothIndexPath]
            print("\(clothes[clothIndexPath].getName())")
            
            let fingerPosition = gesture.location(in: self.view)
            
            let imageView = addViewToLook(cloth.getImage())
            imageView.center = CGPoint(x: fingerPosition.x - 50, y: fingerPosition.y)
            self.view.addSubview(imageView)
            arrayOfImagesInLook.append(imageView)
            arrayOfClothesInLook.append(cloth)
            arrayOfAddedClothes.append(cloth)
            

            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                let screenWidth = UIScreen.main.bounds.width
                imageView.frame = CGRect(origin: CGPoint(x: screenWidth*0.2, y: imageView.frame.origin.y), size: CGSize(width: imageView.frame.width, height: imageView.frame.height))
                }, completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {
                        imageView.transform = imageView.transform.scaledBy(x: 2.0, y: 2.0)
                        }, completion: { finished in
                            UIView.animate(withDuration: 0.1, animations: {
                                imageView.transform = CGAffineTransform.identity
                                }, completion: { finished in
                                    // Add More Cloth Parameters
                                    cloth.setWidth(imageView.frame.width)
                                    cloth.setHeight(imageView.frame.height)
                                    cloth.setCenterInX(imageView.frame.origin.x)
                                    cloth.setCenterInY(imageView.frame.origin.y)
                            })

                    })
                    
            })
            

        case .changed:
            
                break
        case .ended:
            hideClothesSelector()
                break
        default : break
        }
    }
    func deleteCloth(_ gesture: UISwipeGestureRecognizer) {
        if let viewToBeDeleted = gesture.view {
            let displayIndex = viewToBeDeleted.tag
            let cloth = arrayOfClothesInLook[displayIndex]
            
            let screenWidth = UIScreen.main.bounds.width
            let alert = SCLAlertView(newWindowWidth: screenWidth*0.8)
            alert?.iconTintColor = UIColor.white
            alert?.addButton("Remover", actionBlock: {
                if let thisView = gesture.view {
                    let index = thisView.tag
                    print("Tag \(index)")
                    
                    self.arrayOfClothesInLook.remove(at: index)
                    self.arrayOfImagesInLook.remove(at: index)
                    self.arrayOfRemovedClothes.append(cloth)
                    
                    var newIndex = 0
                    for view in self.arrayOfImagesInLook {
                        view.tag = newIndex
                        newIndex = newIndex + 1
                    }
                    
                    print("Deleted \(cloth.getName())")
                    print("Number of clothes: \(self.arrayOfClothesInLook.count)")
                    print("Number of images: \(self.arrayOfImagesInLook.count)")
                    
                    thisView.removeFromSuperview()
                }

            })
            alert?.showCustom(UIImage(named: Enumerators().getImageForClothType(cloth.getType())), color: UIColor.purple, title: "Remover do Look", subTitle: "Tem certeza que deseja remover \(cloth.getName()) do look?", closeButtonTitle: "Cancelar", duration: 0.0)
        
        
        }
        
    }
    func moveCloth(_ gesture: UIPanGestureRecognizer){
        
        let fingerPosition = gesture.translation(in: self.view)
        if let thisView = gesture.view {
            self.view.bringSubview(toFront: thisView)
            let index = thisView.tag
            let cloth = arrayOfClothesInLook[index]
            
            switch(gesture.state) {
            case .began:
                break
            case .changed:
                thisView.center = CGPoint(x: thisView.center.x + fingerPosition.x , y: thisView.center.y + fingerPosition.y)
                gesture.setTranslation(CGPoint.zero, in: self.view)
                break
            case .ended:
                
                cloth.setCenterInX(thisView.center.x)
                cloth.setCenterInY(thisView.center.y)
                
                print("\nCloth \(cloth.getName()) moved to:\n  centerInX: \(cloth.getCenterInX())\n  centerInY: \(cloth.getCenterInY())\n  Tag: \(thisView.tag)\n  Name: \(cloth.getName())")

                break
            default:break
            }
        }
    }
    func bringToFront(_ gesture: UITapGestureRecognizer) {
        if let thisView = gesture.view {
            self.view.bringSubview(toFront: thisView)
            let index = thisView.tag
            let cloth = arrayOfClothesInLook[index]
            print("Pars W: \(cloth.getWidth()), H: \(cloth.getHeight()), X: \(cloth.getCenterInX()), Y: \(cloth.getCenterInY()), R: \(cloth.getRotation())")
            print("View W: \(thisView.frame.width), H: \(thisView.frame.height) ")
        }
    }
    func scaleCloth(_ gesture: UIPinchGestureRecognizer) {
        print("Pinch for Scale \(gesture.scale)")
        let screenWidth = UIScreen.main.bounds.width
        if let thisView = gesture.view {
            let index = thisView.tag
            let cloth = arrayOfClothesInLook[index]

            switch(gesture.state) {
            case .began:
                
                break
            case .changed:
                thisView.transform = thisView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
                gesture.scale = 1.0
                break
            case .ended:

                if thisView.frame.width < 100 {
                    UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: {
                        let scale = 100 / thisView.frame.width
                        thisView.transform = thisView.transform.scaledBy(x: scale, y: scale)
                        }, completion: { finished in
                            cloth.setWidth(100)
                            cloth.setHeight(100)
                            print("Width: \(cloth.getWidth()) Heigth: \(cloth.getHeight())")
                    })
                    
                } else if thisView.frame.width > screenWidth*0.8 {
                
                    UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: {
                        let scale = screenWidth*0.8 / thisView.frame.width
                        thisView.transform = thisView.transform.scaledBy(x: scale, y: scale)
                        }, completion: { finished in
                            cloth.setWidth(screenWidth*0.8)
                            cloth.setHeight(screenWidth*0.8)
                            print("Width: \(cloth.getWidth()) Heigth: \(cloth.getHeight())")
                    })
                } else {
                
                    cloth.setWidth(thisView.frame.width)
                    cloth.setHeight(thisView.frame.height)
                    print("Width: \(cloth.getWidth()) Heigth: \(cloth.getHeight())")
                
                }
    
                
                break
            default:break
            }
            
        }
    }
    func rotateCloth(_ gesture: UIRotationGestureRecognizer) {
        if let thisView = gesture.view {
            let index = thisView.tag
            let cloth = arrayOfClothesInLook[index]
        
            switch(gesture.state) {
            case .began:
                
                break
            case .changed:
                thisView.transform = thisView.transform.rotated(by: CGFloat(gesture.rotation))
                gesture.rotation = 0.0
                
                break
            case .ended:
                let zKeyPath = "layer.presentationLayer.transform.rotation.z"
                let imageRotation = (thisView.value(forKeyPath: zKeyPath) as? NSNumber)?.floatValue ?? 0.0
                print(imageRotation)
                cloth.setRotation(CGFloat(imageRotation))
             
                break
            default:break
            }
            
        }
    }



    // MARK: Animate Clothes Selector
    func hideClothesSelector() {
        let screenWidth = UIScreen.main.bounds.width
        let displacement = screenWidth*0.1
        let duration = 0.3
        let delay = 0.0
        let options = UIViewAnimationOptions.curveLinear
        
        let scale = CGFloat(0.5)
        
        self.createShowSelectorButton()
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.clothesOptionCollectionView.frame = CGRect(x: self.clothesOptionCollectionView.frame.origin.x + displacement,
                y: self.clothesOptionCollectionView.frame.origin.y,
                width: self.clothesOptionCollectionView.frame.width,
                height: self.clothesOptionCollectionView.frame.height)
            
            self.clothesOptionCollectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.clothesOptionCollectionView.alpha = CGFloat(0.4)
            self.typeFilter.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.occasionFilter.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            
            if let button = self.showSelectorButton {
                self.showSelectorButton.frame = CGRect(x: screenWidth*0.83,
                    y: self.showSelectorButton.frame.origin.y,
                    width: self.showSelectorButton.frame.width,
                    height: self.showSelectorButton.frame.height)
            }
            
            }, completion: { finished in
        })
    }
    func hideClothesSelectorOnGesture(_ gesture: UISwipeGestureRecognizer) {
        hideClothesSelector()
        
    }
    func createShowSelectorButton() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        showSelectorButton = UIImageView()
        showSelectorButton.frame = CGRect(x: screenWidth, y: screenHeight*0.225, width: screenWidth*0.18, height: screenHeight*0.46)
        showSelectorButton.layer.cornerRadius = CGFloat(7)
        showSelectorButton.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0))
        showSelectorButton.isUserInteractionEnabled = true
        self.view.addSubview(showSelectorButton)
        
        let swipeShowGesture = UISwipeGestureRecognizer(target: self, action: #selector(CreateLookViewController.showClothesSelector(_:)))
        swipeShowGesture.direction = .left
        self.showSelectorButton.addGestureRecognizer(swipeShowGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateLookViewController.showClothesSelector(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.showSelectorButton.addGestureRecognizer(tapGesture)
    
    }
    func showClothesSelector(_ gesture: UISwipeGestureRecognizer) {
        print("Swiped")
        
        let screenWidth = UIScreen.main.bounds.width
        let displacement = screenWidth*0.1
        let duration = 0.2
        let delay = 0.0
        let options = UIViewAnimationOptions()
        let damping = CGFloat(0.3)
        let scale = CGFloat(1.0)

        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: options, animations: {
            self.clothesOptionCollectionView.frame = CGRect(x: self.clothesOptionCollectionView.frame.origin.x - displacement,
                y: self.clothesOptionCollectionView.frame.origin.y,
                width: self.clothesOptionCollectionView.frame.width,
                height: self.clothesOptionCollectionView.frame.height)
            
            
            self.clothesOptionCollectionView.alpha = CGFloat(1.0)
            
                if let button = self.showSelectorButton {
                    self.showSelectorButton.frame = CGRect(x: self.showSelectorButton.frame.origin.x - displacement,
                        y: self.showSelectorButton.frame.origin.y,
                        width: self.showSelectorButton.frame.width,
                        height: self.showSelectorButton.frame.height)
                }
            
            
            }, completion: { finished in
                UIView.animate(withDuration: duration, animations: {
                    self.clothesOptionCollectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    self.showSelectorButton.alpha = 0.0
                    self.showSelectorButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    
                    self.typeFilter.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.occasionFilter.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    
                    }, completion: { finished in
                        if let button = self.showSelectorButton {
                            self.showSelectorButton.removeFromSuperview()
                        }
                        self.view.bringSubview(toFront: self.clothesOptionCollectionView)
                        self.view.bringSubview(toFront: self.typeFilter)
                        self.view.bringSubview(toFront: self.occasionFilter)
                })
                
                
        })

    }
    
    
    
    // MARK: Filtering
    func filterClothByType() {
        occasionFilterIsPressed = false
        if !typeFilterIsPressed {
            typeFilterIsPressed = true
            typeFilter.tintColor = AppCustomColor().pink
            occasionFilter.tintColor = AppCustomColor().lightGray
            clothesOptionCollectionView.reloadData()
        } else if typeFilterIsPressed {
            typeFilterIsPressed = false
            typeFilter.tintColor = AppCustomColor().lightGray
            clothesOptionCollectionView.reloadData()
        }
    }
    func filterClothByOccasion() {
        typeFilterIsPressed = false
        if !occasionFilterIsPressed {
            occasionFilterIsPressed = true
            occasionFilter.tintColor = AppCustomColor().pink
            typeFilter.tintColor = AppCustomColor().lightGray
            clothesOptionCollectionView.reloadData()
        } else if occasionFilterIsPressed {
            occasionFilterIsPressed = false
            clothesOptionCollectionView.reloadData()
            occasionFilter.tintColor = AppCustomColor().lightGray
        }
    }
    



}






// MARK: Class to Create Option Collection View Cell
class OptionCell: UICollectionViewCell {
    var optionImage: UIImageView!
    var optionLabel: UILabel!
    override init(frame: CGRect) {
       
        optionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        optionLabel = UILabel(frame: CGRect(x: 0, y: frame.height*0.8, width: frame.width, height: frame.height*0.2))
        
        super.init(frame: frame)
        
        optionImage.layer.cornerRadius = CGFloat(7)
        optionImage.contentMode = UIViewContentMode.scaleAspectFill
        optionImage.clipsToBounds = true
        contentView.addSubview(optionImage)
        
        
        optionLabel.backgroundColor = nil
        optionLabel.textAlignment = NSTextAlignment.center
        optionLabel.textColor = UIColor.white
//        contentView.addSubview(optionLabel)
        
        self.clipsToBounds = true
     
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

