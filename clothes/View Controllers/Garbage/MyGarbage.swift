//
//  MyGarbage.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 20/08/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

class MyGarbage: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    // Clothes
    var heightOffset: CGFloat!
    var clothesCollectionView: UICollectionView!
    var numberOfClothesPerLine: Int!
    var sizeOfClothCell: CGFloat!
    var sizeOfClothCellLayout: CGSize!
    var gapValueBetweenClothCells: Double!
    var maximumClothesCollectionViewHeight: CGFloat!
    var currentClothes: Array<Cloth> = []
    var currentClothesImages: [UIImage?] = []
    var currentClothesImagesFiles = [PFFile]()
    var currentSelectedClothIndex: Int?

    
    // Closets
    var userClosets: Array<Closet> = Array<Closet>()
    var userClosetsImage: Array<UIImage> = Array<UIImage>()
    var userClosetsImagesFiles: Array<PFFile> = Array<PFFile>()
    var container: UIView!
    
    override func viewDidLoad() {
        
        print("\n\n\nGARBAGE VIEW CONTROLLER IS BEING LOADED...")
        createBackground()
        createMenuButton()
        downloadClosetsWithRemainingSpaces()
        downloadClothesFromGarbage()
        setupOfVariables()
        createClothesCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Cesto"
    }
    
    // MARK: Setup Screen
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MyGarbage.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
        print("Created Menu Button.")
    }
    func menuShow() {
        Window().showMenuWithCustomTransition(sender: self)
    }
    func setupOfVariables() {
        heightOffset = UIScreen.main.bounds.height*0.095
        heightOffset = CGFloat(44 + 20)
        heightOffset = CGFloat(43)
        numberOfClothesPerLine = 3
        gapValueBetweenClothCells = 0.02
    }
    func createBackground() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let background = UIImageView()
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.image = UIImage(named: "looksBackground.png")
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        let messageToMoveClothes = UILabel()
        messageToMoveClothes.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth*0.07)
        messageToMoveClothes.text = "Mova as roupas para um armário"
        messageToMoveClothes.textAlignment = NSTextAlignment.center
        messageToMoveClothes.textColor = UIColor.white
        self.view.addSubview(messageToMoveClothes)
        print("Created Background.")
  

    }
    
    
    // MARK: Download from Server
    func downloadClothesFromGarbage() {
        
        print("\nDownloading Clothes From Garbage")
        let clothesQuery = PFQuery(className: "Clothes")
        clothesQuery.whereKey("parentCloset", equalTo: "cesto")
        clothesQuery.whereKey("ownerId", equalTo: ((PFUser.current()?.objectId)!))
        clothesQuery.findObjectsInBackground { (objects, error) in
            if (error != nil) {
                print(error)
            } else {
                if let objects = objects {
                    for cloth in objects {
                        let id = cloth.objectId!
                        let ownerId = cloth["ownerId"] as! String
                        let name = cloth["name"] as! String
                        let image = cloth["image"] as! PFFile
                        self.currentClothesImagesFiles.append(image)
                        let clothCreation: Cloth = Cloth(id: "\(id)", name: name, ownerId: ownerId)
                        self.currentClothes.append(clothCreation)
                        image.getDataInBackground(block: { (data, error) in
                            if let _ = data {
                                let clothImage = UIImage(data: data!)
                                clothCreation.setImage(clothImage!)
                                clothCreation.setDownloaded(true)
                                self.currentClothesImages.append(clothImage)
                                if self.clothesCollectionView != nil {
                                    self.clothesCollectionView.reloadData()
                                }
                            }
                        })
                        
                    }
                }
            }
        }
    }
    func downloadClosetsWithRemainingSpaces() {
        let closetQuery = PFQuery(className: "Closet")
        closetQuery.whereKey("ownerId", equalTo: ((PFUser.current()?.objectId)!))
        closetQuery.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for closet in objects {
                        let id = closet.objectId!
                        let ownerId = closet["ownerId"] as! String
                        let name = closet["name"] as! String
                        let capacity = closet["capacity"] as! Int
                        let image = closet["image"] as! PFFile
                        // After acquiring closet data, need to check if there is available spaces inside the closet by counting the clothes
                        
                        let clothesQuery = PFQuery(className: "Clothes")
                        clothesQuery.whereKey("parentCloset", equalTo: id)
                        clothesQuery.whereKey("ownerId", equalTo: ownerId)
                        clothesQuery.findObjectsInBackground(block: { (objects, error) in
                            if let objects = objects {
                                let numberOfClothes = objects.count
                                let availableSpaces = capacity - numberOfClothes
                                // Check if number of spaces is greater than ZERO
                                if availableSpaces > 0 {
                                    self.userClosetsImagesFiles.append(image)
                                    let closetCreation:Closet = Closet(id: "\(id)", ownerId: ownerId, name: name, capacity: capacity, numberOfClothes: numberOfClothes)
                                    self.userClosets.append(closetCreation)
                                    print("Para o armario \(name) tem \(capacity - numberOfClothes) disponiveis")
                                    image.getDataInBackground(block: { (data, error) in
                                        if error != nil {
                                            print(error)
                                        } else {
                                            if let _ = data {
                                                let closetImage = UIImage(data: data!)!
                                                self.userClosetsImage.append(closetImage)
                                                closetCreation.setImage(closetImage)
                                            }
                                        }
                                    })
                                    
                                }
                            }
                        })
                        
                        
                        
                    }
                }
            }
        }
    }
    
    
    // MARK: Create Clothes Collection View
    func createClothesCollectionView() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        // Create Clothes Collection View
        let numberOfGaps = Float((2 + numberOfClothesPerLine - 1))
        let gapValueToBeRemoved = numberOfGaps * Float(gapValueBetweenClothCells)
        sizeOfClothCell = CGFloat((Float(UIScreen.main.bounds.width) * (1 - gapValueToBeRemoved))/Float(numberOfClothesPerLine))
        
        // Create Clothes Collection View Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: screenWidth*CGFloat(gapValueBetweenClothCells),
                                           right: 0)
        layout.itemSize = CGSize(width: sizeOfClothCell, height: sizeOfClothCell)
        sizeOfClothCellLayout = layout.itemSize
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = CGFloat(0)
        layout.minimumLineSpacing = CGFloat(screenWidth*CGFloat(gapValueBetweenClothCells))
        let clothesColllectionViewStartHeight = heightOffset + screenHeight*0.0
        maximumClothesCollectionViewHeight = screenHeight - clothesColllectionViewStartHeight - 7
        
        // Create Clothes Collection View Frame
        let clothesCollectionViewFrame = CGRect(x: screenWidth*CGFloat(gapValueBetweenClothCells) + screenWidth*0.0,
                                                    y: clothesColllectionViewStartHeight,
                                                    width: screenWidth*(1-(2*CGFloat(gapValueBetweenClothCells))),
                                                    height: maximumClothesCollectionViewHeight)
        clothesCollectionView = UICollectionView(frame: clothesCollectionViewFrame, collectionViewLayout: layout)
        clothesCollectionView.dataSource = self
        clothesCollectionView.delegate = self
        clothesCollectionView.showsVerticalScrollIndicator = false
        clothesCollectionView.register(GarbageCell.self, forCellWithReuseIdentifier: "Cell")
        clothesCollectionView.backgroundColor = UIColor(red: 179/255, green: 110/255, blue: 180/255, alpha: 0.0)
        clothesCollectionView.layer.cornerRadius = CGFloat(7)
        self.view.addSubview(clothesCollectionView)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentClothesImagesFiles.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GarbageCell
        
        if (indexPath as NSIndexPath).item < currentClothesImages.count {
            cell.clothImage.frame.size.width = cell.frame.width
            cell.clothImage.frame.size.height = cell.frame.height
            cell.clothImage.image = currentClothes[(indexPath as NSIndexPath).item].getThumbnail()
//            let image = currentClothesImagesFiles[indexPath.item]
//            image.getDataInBackgroundWithBlock({ (data, error) in
//                if let _ = data {
//                    let cellImage = UIImage(data: data!)
//                    cell.clothImage.image = cellImage
//                }
//            })
            
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeOfClothCellLayout
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(currentClothes[(indexPath as NSIndexPath).item].getName())
        if userClosets.count > 0 {
        currentSelectedClothIndex = (indexPath as NSIndexPath).item
        createClosetSelector()
        } else {
            // no available closets
        }
    }
    

    // MARK: Create Closet Selector
    func createClosetSelector() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(container)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        container.addSubview(blurView)
        
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(MyGarbage.dismissClosetsSelector))
        dismissTapGesture.numberOfTapsRequired = 1
        blurView.addGestureRecognizer(dismissTapGesture)
        
        let infoLabel = UILabel()
        infoLabel.frame = CGRect(x: screenWidth*0.1, y: screenHeight*0.02, width: screenWidth*0.8, height: screenHeight*0.1)
        infoLabel.text = "Escolha um amário para mover sua roupa"
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.numberOfLines = 2
        infoLabel.font = UIFont(name: "Klavika", size: CGFloat(25))
        infoLabel.textAlignment = NSTextAlignment.center
        infoLabel.textColor = UIColor.white
        container.addSubview(infoLabel)
        
        let closetSelector = UITableView(frame: CGRect(x: screenWidth*0.1, y: screenHeight*0.24, width: screenWidth*0.8, height: screenHeight*0.45), style: UITableViewStyle.grouped)
        closetSelector.dataSource = self
        closetSelector.delegate = self
        closetSelector.backgroundColor = UIColor.white
        closetSelector.layer.cornerRadius = CGFloat(7)
        container.addSubview(closetSelector)
        
        let clothBadge = UIView()
        clothBadge.frame = CGRect(x: screenWidth*0.35, y: screenHeight*0.13, width: screenWidth*0.3, height: screenWidth*0.3)
        clothBadge.backgroundColor = UIColor.white
        clothBadge.layer.cornerRadius = CGFloat(clothBadge.frame.size.height/2)
        container.addSubview(clothBadge)
        
        let clothBadgeInner = UIImageView()
        clothBadgeInner.frame = CGRect(x: clothBadge.frame.size.width*0.05, y: clothBadge.frame.size.width*0.05, width: clothBadge.frame.size.width*0.9, height: clothBadge.frame.size.width*0.9)
        clothBadgeInner.backgroundColor = UIColor.blue
        clothBadgeInner.layer.cornerRadius = CGFloat(clothBadgeInner.frame.size.height/2)
        clothBadgeInner.contentMode = .scaleToFill
        clothBadgeInner.layer.masksToBounds = true
        clothBadgeInner.image = currentClothes[currentSelectedClothIndex!].getImage()
        clothBadge.addSubview(clothBadgeInner)
    
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userClosets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = closetCell(style: UITableViewCellStyle.default, reuseIdentifier: "closetCell")
        let closet = userClosets[(indexPath as NSIndexPath).item]
        cell.closetImage.image = closet.getImage()
        cell.closetName.text = closet.getName()
        cell.closetAvailableSpots.text = "\(closet.getCapacity() - closet.getNumberOfClothes())"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cloth = currentClothes[currentSelectedClothIndex!]
        let closet = userClosets[(indexPath as NSIndexPath).item]
        moveClothFromGarbageToCloset(cloth, closet: closet)
    }
    func dismissClosetsSelector() {
        if container != nil {
            container.removeFromSuperview()
        }
    }
    
    
    
    
    
    
    // MARK: Move clothes from garbage to closet
    func moveClothFromGarbageToCloset(_ cloth: Cloth, closet: Closet) {
        let clothId = cloth.getId()
        let clothOwnerId = cloth.getOwnerId()
        let closetId = closet.getId()
        let closetOwnerId = closet.getOwnerId()
        
        print("ClothId \(clothId), clothOwnerId \(clothOwnerId), ClosetId \(closetId), ClosetOwnerId \(closetOwnerId)")
        
        if clothOwnerId == closetOwnerId {
            let clothSearch = PFQuery(className: "Clothes")
            clothSearch.whereKey("ownerId", equalTo: ((PFUser.current()?.objectId)!))
            clothSearch.getObjectInBackground(withId: clothId, block: { (object, error) in
                if let object = object {
                    object["parentCloset"] = closetId
                    object.saveInBackground(block: { (success, error) in
                        if success {
                            self.messageClothBeingTransfered(cloth, closet: closet)
                            self.removeClothFromCollectionView(cloth)
                            self.decreaseStorageInCloset(closet)
                            self.dismissClosetsSelector()
                        }
                    })
                }
            })
        }
    
    }
    func messageClothBeingTransfered(_ cloth: Cloth, closet: Closet) {
        let clothName = cloth.getName()
        let closetName = closet.getName()
        let windowWidth = CGFloat(UIScreen.main.bounds.width*0.8)
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: windowWidth)
        alert.showWaiting("Transferindo", subTitle: "Roupa \(clothName) sendo transferida para armário \(closetName)", closeButtonTitle: nil, duration: 4.0)
    }
    func removeClothFromCollectionView(_ cloth: Cloth) {
        let clothIndex = currentClothes.index { (Cloth) -> Bool in
            return Cloth.getId() == cloth.getId()
        }
        
        if let index = clothIndex {
            currentClothes.remove(at: index)
            currentClothesImages.remove(at: index)
            currentClothesImagesFiles.remove(at: index)
            clothesCollectionView.reloadData()
        }
    }
    func decreaseStorageInCloset(_ closet: Closet) {
        let capacity = closet.getCapacity()
        let numberOfClothes = closet.getNumberOfClothes()
        closet.setNumberOfClothes(numberOfClothes+1)
        
        if capacity - numberOfClothes == 0 {
            removeClosetWithoutStorage(closet)
        }
    }
    func removeClosetWithoutStorage(_ closet: Closet) {
        let closetIndex = userClosets.index { (Closet) -> Bool in
            return Closet.getId() == closet.getId()
        }
        
        if let index = closetIndex {
            userClosets.remove(at: index)
            userClosetsImage.remove(at: index)
            userClosetsImagesFiles.remove(at: index)
        }
    }
    
    
    
    deinit {
        print("MyGarbageViewController has been deinitialized.")
    }
    
    
    
}






// MARK: Class to Create Custom Cells UITableViewCell
class closetCell: UITableViewCell {
    var closetImage: UIImageView!
    var closetName: UILabel!
    var closetAvailableSpots: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let cellWidth = self.frame.width
        let cellHeight = self.frame.height
        
        closetImage = UIImageView()
        closetImage.frame = CGRect(x: cellWidth*0.2, y: 2, width: 56, height: 56)
        closetImage.layer.cornerRadius = CGFloat(6)
        closetImage.layer.masksToBounds = true
        closetImage.contentMode = .scaleAspectFit
        self.contentView.addSubview(closetImage)
        
        closetName = UILabel()
        closetName.frame = CGRect(x: cellWidth*0.4, y: 2, width: cellWidth*0.45, height: 56)
        closetName.lineBreakMode = .byWordWrapping
        closetName.numberOfLines = 0
        self.contentView.addSubview(closetName)
        
        closetAvailableSpots = UILabel()
        closetAvailableSpots.frame = CGRect(x: cellWidth*0.07, y: 1, width: 40, height: 40)
        closetAvailableSpots.font = UIFont(name: "Klavika", size: CGFloat(35))
        closetAvailableSpots.textColor = AppCustomColor().pink
        self.contentView.addSubview(closetAvailableSpots)
        
        let availableSpacesText = UILabel()
        availableSpacesText.frame = CGRect(x: cellWidth*0.02, y: 38, width: 56, height: 10)
        availableSpacesText.text = "Espaços"
        availableSpacesText.font = UIFont(name: "Klavika", size: CGFloat(9))
        availableSpacesText.textColor = AppCustomColor().pink
        availableSpacesText.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(availableSpacesText)
        
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
    
}


// MARK: Class to Create Custom Clothes UICollectionViewCell
class GarbageCell: UICollectionViewCell {
    var clothImage: UIImageView!
    var clothImageLastPositionY: CGPoint!
    override init(frame: CGRect) {
        clothImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width*0.9, height: frame.size.height*0.9))
        super.init(frame: frame)
        clothImage.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.6))
        clothImage.layer.cornerRadius = CGFloat(7)
        clothImage.contentMode = UIViewContentMode.scaleAspectFill
        clothImage.layer.borderWidth = CGFloat(1)
        clothImage.layer.borderColor = UIColor(red: 179/255, green: 110/255, blue: 180/255, alpha: 0.8).cgColor
        clothImage.clipsToBounds = true
        let duration = 1.0
        let delay = TimeInterval(arc4random_uniform(10))/10
        let options: UIViewAnimationOptions = [.autoreverse, .repeat]
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.clothImage.frame = CGRect(x: 0, y: 2, width: frame.size.width*0.9, height: frame.size.height*0.9)
            self.clothImage.alpha = 0.9
            }, completion: nil)
        contentView.addSubview(clothImage)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
