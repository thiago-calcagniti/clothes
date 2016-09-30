//
//  MyClosets.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 24/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//


import UIKit
import Parse


class MyClosets: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ManageClothesDelegate, RegisterClothesDelegate, EditCloset {
    

    weak var weakSelf: MyClosets!
    let transitionManager = TransitionManager()
    
    // View Data Source
    var backgroundImage:UIImageView!
    var heightOffset: CGFloat!
    var backgroundClosetsScrollView: UIImageView!
    var availablePositionsForIcons: [CGPoint]! = []
    var availableIndexForIcons: [Bool]! = []

    
    // View Delegate
    var selectedClothType: String?
    lazy var newClothHasBeenAdded: Bool = false
    lazy var aClothHasBeenRemoved: Bool = false
    var clothAddedType: String = "Indefinido"
    
    
    // Closets
    var closetsScrollView: UIScrollView!
    var pageViews: [UIImageView?] = []
    var pageCount: Int!
    var closetNameLabel: UITextField = UITextField()
    var closets = Array<Closet>()
    var myClosetImages = [PFFile]()
    var closetsPreviewCollectionView: UICollectionView!
    
    
    // Icons
    var movedIcons: Int!
    var acessoriesIcon: IconParameter?
    var shirtsIcon: IconParameter?
    var tShirtsIcon: IconParameter?
    var jacketsIcon: IconParameter?
    var dressesIcon: IconParameter?
    var skirtsIcon: IconParameter?
    var underwearIcon: IconParameter?
    var pantsIcon: IconParameter?
    var socketsIcon: IconParameter?
    var shoesIcon: IconParameter?
    var arrayOfIcons: [IconParameter] = []
    var arrayOfIconsThatNeedToAppear: [IconParameter] = []
    var startedIconCGPoint = CGPoint()
    var borningIconCGPoint = CGPoint()
    var nextIconCGPoint = CGPoint()
    var heightInvervalBetweenIcons = CGFloat()
    
    
    // Clothes
    var clothesCollectionView: UICollectionView!
    var numberOfClothesPerLine: Int!
    var sizeOfClothCell: CGFloat!
    var sizeOfClothCellLayout: CGSize!
    var gapValuePercentageBetweenCells: Double!
    var maximumClothesCollectionViewHeight: CGFloat!
    var currentClothes: Array<Cloth> = []
    var currentClothesImages: [UIImage?] = []
    var currentClothesImagesFiles = [PFFile]()
    var currentClothesTypes: [String] = []
    var currentClothesViews: [UIImageView?] = []
    var currentSelectedClothIndex: Int?
    var clothesStand: UIImageView!
    
    // Parse Information
    var parseContentDownloaded: Bool = false
    
    // Registering New Closet
    var newNameTextField: SCLTextView!
    var newName: String = ""
    var newClosetAdded: Bool = false
    
    // Taking a photo
    var typeOfPictureTaken: String = ""
    
    
    // MARK: View Controller Presentation
    override func viewDidLoad() {
        
        print("\n\n\nMY CLOSETS VIEW CONTROLLER IS BEING LOADED.")
        
        initVariables()
        createBackground()
        createMenuButton()
        createAddClosetButton()
        createClosetsScrollView()
        
        
        let windowWidth = UIScreen.main.bounds.width*0.8
        let alert = SCLAlertView(newWindowWidth: windowWidth)
        alert?.showAnimationType = .SlideInToCenter
        alert?.hideAnimationType = .SlideOutFromCenter
        alert?.backgroundType = .Shadow
        alert?.showWaiting("Relaxe ...", subTitle: "Estamos carregando seus dados", closeButtonTitle: nil, duration: 5.0)
        
        
        
        
        print("\nStarting comunication with server...")
        let closetQuery = PFQuery(className: "Closet")
        closetQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        closetQuery.getFirstObjectInBackground { (object, error) -> Void in
            if error != nil {
                
                print("New user detected.")
                print("Preparing scene...")
                let spots = 90
                let ads = 10
                let user = PFUser.current()!
                user["spot"] = spots
                user["ads"] = ads
                user.saveInBackground(block: { (success, error) in
                    if success {
                        print("\(spots) starter spots were granted to the user.")
                    }
                })
                
                print("Installing a closet for the new user...")
                let initialCloset = PFObject(className: "Closet")
                initialCloset["ownerId"] = (PFUser.current()?.objectId)!
                initialCloset["name"] = "Novo Armario"
                initialCloset["capacity"] = 10
                let imageData = UIImagePNGRepresentation(UIImage(named: "standardCloset.png")!)
                let imageFile = PFFile(name: "novoarmario.png", data: imageData!)
                initialCloset["image"] = imageFile
                initialCloset.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("New closet has been granted for new user.")
                        self.downloadClosetsFromServer()
                        self.createClothesCollectionView()
                        self.downloadClothesFromInitialCloset()
                        if let alert = alert {
                            alert.hideView()
                        }

                    }
                })
            } else {
                self.downloadClosetsFromServer()
                self.createClothesCollectionView()
                self.downloadClothesFromInitialCloset()
                if let alert = alert {
                    alert.hideView()
                }
            }
        }

        

        
        
        

    }
    override func viewDidLayoutSubviews() {
       // if parseContentDownloaded {
       // loadClosetsToScrollView()                            // closets are loaded to the scroll view
       // }
    }
    override func viewDidAppear(_ animated: Bool) {
        if parseContentDownloaded {
        alertIfNewClothWasAdded()                       // if new cloth was added to a closet, show alert to user informing it worked
        alertIfClothWasRemoved()                        // if a cloth was removed from a closet
        loadClosetsToScrollView()                            // closets are loaded to the scroll view
        updateClothesThatWillBeShown()
        loadIcons()
        animateIcons()                                  // animate icons
//        createClothesCollectionView()
        updateClothesCollectionViewFrame()              // load clothes from updated array of clothes that will be uploaded
        weakSelf.title = getCurrentCloset().getName()
        }
    }
    
    // MARK: Setup Navigation Items
    func createMenuButton() {
        print("Created Button for Menu.")
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: weakSelf, action: #selector(weakSelf.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
    }
    func menuShow() {
        print("Requested Menu to Appear.")

        closets.removeAll()
        myClosetImages.removeAll()
        currentClothes.removeAll()
        currentClothesImages.removeAll()
        currentClothesImagesFiles.removeAll()
        currentClothesTypes.removeAll()
        currentClothesViews.removeAll()
        arrayOfIcons.removeAll()
        arrayOfIconsThatNeedToAppear.removeAll()
        
        
        acessoriesIcon = nil
        shirtsIcon = nil
        tShirtsIcon = nil
        jacketsIcon = nil
        dressesIcon = nil
        skirtsIcon = nil
        underwearIcon = nil
        pantsIcon = nil
        socketsIcon = nil
        shoesIcon = nil

        Window().showMenuWithCustomTransition(sender: self)
        
        
    }
    func createAddClosetButton() {
        print("Created Button to add Closets.")
        let addClosetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: weakSelf, action: #selector(weakSelf.addNewCloset))
        self.navigationItem.rightBarButtonItem = addClosetButton
    }
    func addNewCloset() {
        let screenWidth = UIScreen.main.bounds.width
        
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(screenWidth*0.7))
        newNameTextField = alert.addTextField("Digite Nome do Armário")
        newNameTextField.textAlignment = NSTextAlignment.center
        newNameTextField.addTarget(weakSelf, action: #selector(weakSelf.prepareNewName(_:)), for: UIControlEvents.editingDidEndOnExit)
        let confirmButton: SCLButton = alert.addButton("Criar Armário", target: weakSelf, selector: #selector(weakSelf.saveNewCloset))
        alert.showCustom(UIImage(named: "standardCloset.png"), color: AppCustomColor().pink, title: "Novo Armário", subTitle: "Que ótima idéia criar um novo armário!", closeButtonTitle: "Cancelar", duration: 0.0)
    }
    func prepareNewName(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let _ = newNameTextField {
            newName = newNameTextField.text!
        }
        print("\(newName)")
        return true
    }
    func saveNewCloset() {
        newNameTextField.resignFirstResponder()
        if let _ = newNameTextField {
            newName = newNameTextField.text!
            
            // Create a new PFOBject to save the new closet in Parse
            let newCloset = PFObject(className: "Closet")
            newCloset["name"] = newName
            newCloset["capacity"] = 0
            newCloset["ownerId"] = PFUser.current()?.objectId!
            let imageData = UIImagePNGRepresentation(UIImage(named: "standardCloset.png")!)
            let imageFile = PFFile(name: newName, data: imageData!)
            newCloset["image"] = imageFile
            // Save new closet in Parse and if sucess
            newCloset.saveInBackground(block: { (sucess, error) -> Void in
                weak var weakSelfInClosure = self
                if sucess {
                    print("Saved Closet and new name is \(weakSelfInClosure!.newName)")
                    // Search added closet in Parse
                    let closetQuery = PFQuery(className: "Closet")
                    closetQuery.whereKey("name", equalTo: "\(weakSelfInClosure!.newName)")
                    closetQuery.getFirstObjectInBackground(block: { (object, error) -> Void in
                        if let object = object {
                            let id = "\(object.objectId!)"
                            let name = object["name"] as! String
                            let ownerId = object["ownerId"] as! String
                            let capacity = object["capacity"] as! Int
                            let standImageName = "clothesStand.png"
                            let image = object["image"] as! PFFile
                            // Create a new Closet instance in the app
                            let closet = Closet(id: "\(id)", ownerId: ownerId, name: name, capacity: capacity, standImageName: standImageName)
                            weakSelfInClosure!.closets.append(closet)
                            weakSelfInClosure!.myClosetImages.append(image)
                            let closetIndex = weakSelfInClosure!.closets.count - 1
                            // Download Image from the Closet
                            image.getDataInBackground(block: { (data, error) -> Void in
                                if let downloadedImage = UIImage(data: data!) {
                                    
                                    // Set an image for the closet inside app
                                    weakSelfInClosure!.closets[closetIndex].setImage(downloadedImage)
                                    
                                    // Set image size
                                    var frame = weakSelfInClosure!.closetsScrollView.bounds
                                    frame.origin.x = frame.size.width * CGFloat(closetIndex)
                                    frame.origin.y = UIScreen.main.bounds.height*(0.04)
                                    frame.size.height = weakSelfInClosure!.closetsScrollView.bounds.height*0.85
                                    
                                    // Add image to closets Scroll View
                                    let newPageView = UIImageView(image: weakSelfInClosure!.closets[closetIndex].getImage())
                                    newPageView.contentMode = .scaleAspectFit
                                    newPageView.frame = frame
                                    weakSelfInClosure!.closetsScrollView.addSubview(newPageView)
                                    weakSelfInClosure!.closets[closetIndex].setLoadedToScrollView(true)
                                    
                                    // Update ScrollView ContentSize
                                    let pagesScrollViewSize = weakSelfInClosure!.closetsScrollView.frame.size
                                    weakSelfInClosure!.closetsScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(weakSelfInClosure!.closets.count), height: pagesScrollViewSize.height)
                                    
                                    // Inform that a new closet is added
                                    weakSelfInClosure!.newClosetAdded = true
                                    
                                    // Scroll programmatically to show new created closet
                                    let newClosetIndex = (weakSelfInClosure!.closets.count - 1)
                                    weakSelfInClosure!.scrollToCloset(newClosetIndex)
                                    
                                    closet.setClothesDownloaded(true)
                                    
                                }
                            })
                           
                        }

                    })

                }
            })
            
            
        }
        
    }

    
    
    
    // MARK: Setup View Controller
    func initVariables() {
        
        print("Variables being initialized.")
        // Adding weak relation for self
        weakSelf = self
        
        heightOffset = UIScreen.main.bounds.height*0.095
        heightOffset = CGFloat(44 + 20)
        heightOffset = CGFloat(43)

        startedIconCGPoint = CGPoint(x: UIScreen.main.bounds.width*0.03, y: heightOffset + UIScreen.main.bounds.height*0.08)
        borningIconCGPoint = CGPoint(x: UIScreen.main.bounds.width*0.50, y: heightOffset + UIScreen.main.bounds.height*0.21)
        nextIconCGPoint.x = startedIconCGPoint.x
        nextIconCGPoint.y = startedIconCGPoint.y
        heightInvervalBetweenIcons = 0.07
        numberOfClothesPerLine = 3
        gapValuePercentageBetweenCells = 0.02
        
        initAvailablePositionsForIcons()
        
    }
    func createBackground() {
        print("Created Background.")
        // Get Screen Bounds
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Add background picture
        backgroundClosetsScrollView = UIImageView()
        backgroundClosetsScrollView.frame = CGRect(x: 0, y: heightOffset /*+ screenHeight*0.059*/, width: screenWidth, height: screenHeight - heightOffset)
        backgroundClosetsScrollView.image = UIImage(named: "looksBackground.png")
        backgroundClosetsScrollView.contentMode = .scaleAspectFill
        backgroundClosetsScrollView.alpha = CGFloat(1)
        self.view.addSubview(backgroundClosetsScrollView)
    }

    
    // MARK: Alerts for User
    func alertIfNewClothWasAdded() {
        if newClothHasBeenAdded {
            Alert(controller: weakSelf).tellUserClothWasSucessfullyAdded(clothAddedType)
            newClothHasBeenAdded = false
        }
    }
    func alertIfClothWasRemoved() {
        if aClothHasBeenRemoved {
            Alert(controller: weakSelf).tellUserClothWasRemoved()
            aClothHasBeenRemoved = false
        }
    }
    
    
    
    // MARK: Info Share Functions
    func getCurrentSelectedClothType() -> String {
        return selectedClothType!
    }
    func informNewClothWasAdded(_ type: String) {
        newClothHasBeenAdded = true
        clothAddedType = type
    }
    func informClothWasRemoved() {
        aClothHasBeenRemoved = true
    }
    
    

    
    // MARK: Create Closets Scroll View With Page Control and Methods
    func createClosetsScrollView() {
        print("\nCreating Scroll View for Closets.")
        // Prepare Array of Closets
        pageCount = closets.count
        
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // Get Screen Measures
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidth = UIScreen.main.bounds.size.width
        
        // Closets Scroll View
        closetsScrollView = UIScrollView()
        closetsScrollView.delegate = self
        closetsScrollView.isPagingEnabled = true
        closetsScrollView.clipsToBounds = true
        closetsScrollView.showsHorizontalScrollIndicator = false
        closetsScrollView.frame = CGRect(x: 0, y: heightOffset + screenHeight*0.02, width: screenWidth, height: screenHeight*0.4)
        closetsScrollView.center.x = screenWidth/2
        let pagesScrollViewSize = closetsScrollView.frame.size
        closetsScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount), height: pagesScrollViewSize.height)
        self.view.addSubview(closetsScrollView)
        print("Closets Scroll View added to view.")
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyClosets.editCloset))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        closetsScrollView.addGestureRecognizer(tapGesture)
        print("Added a Edit Closet function on tap.")
    }
    func loadCloset(_ page: Int) {
        if (page < 0 || page >= closets.count) {
            return
        }
    
        
        myClosetImages[page].getDataInBackground(block: { (data, error) -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    weak var weakSelfInClosure = self
                    weakSelfInClosure!.closets[page].setImage(downloadedImage)
                        var frame = weakSelfInClosure!.closetsScrollView.bounds
                        frame.origin.x = frame.size.width * CGFloat(page)
                        frame.origin.y = UIScreen.main.bounds.height*(0.04)
                        frame.size.height = weakSelfInClosure!.closetsScrollView.bounds.height*0.85
                        
                        let newPageView = UIImageView(image: weakSelfInClosure!.closets[page].getImage())
                        newPageView.contentMode = .scaleAspectFit
                        newPageView.frame = frame
                        newPageView.tag = page
                        weakSelfInClosure!.closetsScrollView.addSubview(newPageView)
                        weakSelfInClosure!.closets[page].setLoadedToScrollView(true)

                }
            })
        
    }
    func purgeCloset(_ page: Int) {
        if (page < 0 || page >= closets.count) {
            return
        }
        
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    func loadClosetsToScrollView() {
        print("Loading Closets to ScrollView...")
        if closetsScrollView != nil {
            
            // Update ScrollView ContentSize
            var pagesScrollViewSize = closetsScrollView.frame.size
            closetsScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(closets.count), height: pagesScrollViewSize.height)
            
            // Determine which page is currently loaded
            let pageWidth = closetsScrollView.frame.size.width
            let closet = Int(floor(((closetsScrollView.contentOffset.x*2.0 + pageWidth) / (pageWidth*2.0))))
            
            
            // Load Closet
            if !closets[closet].getLoadedToScrollView() {
                loadCloset(closet)
                
                // Update ScrollView ContentSize
                pagesScrollViewSize = closetsScrollView.frame.size
                closetsScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(closets.count), height: pagesScrollViewSize.height)
            }
            

            
            // Change View Name
            self.title = getCurrentCloset().getName()
            
            // Animate Current Closet
            animateCurrentCloset()
            clothesCollectionView.reloadData()
        }
    }
    func animateCurrentCloset() {
        /*
        let screenHeight = UIScreen.mainScreen().bounds.height
        let currentPage = closetsPageControl.currentPage
        if let animatedCloset = pageViews[currentPage] {
            let duration = 1.0
            let delay = 0.0
            let options: UIViewAnimationOptions = [.Autoreverse, .Repeat, .CurveEaseInOut]
            UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
                animatedCloset.frame = CGRect(x: animatedCloset.frame.origin.x, y: (animatedCloset.frame.origin.y + (screenHeight*0.005)), width: animatedCloset.frame.width, height: animatedCloset.frame.height)
                }, completion: nil)
        }*/
    }

    func getCurrentCloset() -> Closet {
        // Determine which page is currently loaded
        let pageWidth = closetsScrollView.frame.size.width
        let page = Int(floor(((closetsScrollView.contentOffset.x*2.0 + pageWidth) / (pageWidth*2.0))))
        
        if let currentCloset: Closet = closets[page] {
        return currentCloset
        }
    }
    func getClosetById(_ closetId: String) -> Closet {
        let myClosets = closets
        var wantedCloset: Closet!
        for closet in myClosets {
            if closet.getId() == closetId {
                wantedCloset = closet
            }
        }
        return wantedCloset
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch (scrollView) {
            case closetsScrollView:
                if newClosetAdded {
                    
                    weakSelf.title = getCurrentCloset().getName()
                    updateIcons()
                    reloadClothesCollectionData()
                    loadIcons()
                    if weakSelf.title == closets[closets.count - 1].getName() {
                        newClosetAdded = false
                    }
                }
            break
            
            case clothesCollectionView:
            break
            
            default:break
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch (scrollView) {
        case closetsScrollView:
            loadClosetsToScrollView()
            downloadClothesFromCurrentClosetIfNeeded()
            updateIcons()
            reloadClothesCollectionData()
            loadIcons()
            break
        default:
//            updateIcons()
//            reloadClothesCollectionData()
//            loadIcons()
            break
        }
     
    }
    func scrollToCloset(_ closetIndex: Int) {
        if let _ = closetsScrollView {
            weakSelf.closetsScrollView.setContentOffset(CGPoint(x: CGFloat(UIScreen.main.bounds.width)*CGFloat(closetIndex), y: 0), animated: true)
        }
    }
    
    
    
    // MARK: Manage Closets
    func editCloset(){
        let currentCloset = getCurrentCloset()
        let numberOfClosets = closets.count
        let currentClosetIndex = closets.index { (Closet) -> Bool in
            return Closet.getId() == currentCloset.getId()
        }
        
        let destinationController = EditClosetViewController(delegate: weakSelf, closet: currentCloset, closetIndex: currentClosetIndex!, numberOfClosets: numberOfClosets)
        if let navigation = navigationController {
            navigation.pushViewController(destinationController, animated: true)
        }
    }
    func removeCloset(_ closetIndex: Int) {
        if closetIndex <= (closets.count - 1) {
            closets.remove(at: closetIndex)
            myClosetImages.remove(at: closetIndex)
            loadClosetsToScrollView()
            menuShow()
        }
    }
    func getMyClosets() -> Array<Closet> {
        return weakSelf.closets
    }
    func getMyClosetImages() -> Array<PFFile> {
        return weakSelf.myClosetImages
    }


    
    // MARK: Create Clothes Collection View
    func createClothesCollectionView() {
        print("\nCreating Clothes Collection View...")
//            if closetsScrollView != nil {
        
                print("Defining Layout and Dimensions...")
                let screenHeight = UIScreen.main.bounds.size.height
                let screenWidth = UIScreen.main.bounds.size.width
                let numberOfGaps = Float((2 + numberOfClothesPerLine - 1))
                let gapValueToBeRemoved = numberOfGaps * Float(gapValuePercentageBetweenCells)
                sizeOfClothCell = CGFloat((Float(UIScreen.main.bounds.width) * (1 - gapValueToBeRemoved))/Float(numberOfClothesPerLine))
                
                // Create Clothes Collection View Layout
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: screenWidth*CGFloat(gapValuePercentageBetweenCells),
                                                   right: 0)
                layout.itemSize = CGSize(width: sizeOfClothCell, height: sizeOfClothCell)
                sizeOfClothCellLayout = layout.itemSize
                layout.scrollDirection = .vertical
                layout.minimumInteritemSpacing = CGFloat(0)
                layout.minimumLineSpacing = CGFloat(screenWidth*CGFloat(gapValuePercentageBetweenCells))
                let clothesColllectionViewStartHeight = heightOffset + screenHeight*0.465
                maximumClothesCollectionViewHeight = screenHeight - clothesColllectionViewStartHeight - 7
                
                // Create Clothes Collection View Frame
                let clothesCollectionViewFrame = CGRect(x: screenWidth*CGFloat(gapValuePercentageBetweenCells) + screenWidth*0.0,
                                                            y: clothesColllectionViewStartHeight,
                                                            width: screenWidth*(1-(2*CGFloat(gapValuePercentageBetweenCells))),
                                                            height: maximumClothesCollectionViewHeight)
                if clothesCollectionView != nil {
                    clothesCollectionView.removeFromSuperview()
                }
                
                // Create CLothes Collection View
                clothesCollectionView = UICollectionView(frame: clothesCollectionViewFrame, collectionViewLayout: layout)
                clothesCollectionView.dataSource = weakSelf
                clothesCollectionView.delegate = weakSelf
                clothesCollectionView.showsVerticalScrollIndicator = false
                clothesCollectionView.register(ClothCell.self, forCellWithReuseIdentifier: "Cell")
                clothesCollectionView.backgroundColor = UIColor(red: 179/255, green: 110/255, blue: 180/255, alpha: 0.0)
                clothesCollectionView.layer.cornerRadius = CGFloat(7)
                self.view.addSubview(clothesCollectionView)
                print("Clothes Collection View added to view.")
 
                let longPressureGesture = UILongPressGestureRecognizer(target: weakSelf, action: #selector(weakSelf.handleLongPressureGesture(_:)))
                longPressureGesture.minimumPressDuration = 1.0
                self.clothesCollectionView.addGestureRecognizer(longPressureGesture)
                print("Added long press gesture to change order of clothes.")
                

                let pinchResizeGesture = UIPinchGestureRecognizer(target: weakSelf, action: #selector(weakSelf.changeCellSize(_:)))
//                self.clothesCollectionView.addGestureRecognizer(pinchResizeGesture)
                print("Added pinch gesture to resize cells.")
//            }
        
        
    }
    func changeCellSize(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        switch (gesture.state) {
        case .began:
            break
        case .changed:
            break
        case .ended:
            if scale < 1 {
                numberOfClothesPerLine = numberOfClothesPerLine + 1
            } else {
                numberOfClothesPerLine = numberOfClothesPerLine - 1
            }
            
            if numberOfClothesPerLine > 6 {
                numberOfClothesPerLine = 6
            } else if numberOfClothesPerLine < 3 {
                numberOfClothesPerLine = 3
            }
            
            let numberOfGaps = Float((2 + numberOfClothesPerLine - 1))
            let gapValueToBeRemoved = numberOfGaps * Float(gapValuePercentageBetweenCells)
            sizeOfClothCell = CGFloat((Float(UIScreen.main.bounds.width) * (1 - gapValueToBeRemoved))/Float(numberOfClothesPerLine))
            sizeOfClothCellLayout = CGSize(width: sizeOfClothCell, height: sizeOfClothCell)
            updateClothesCollectionViewFrame()
            clothesCollectionView.reloadData()
            break
        default: break
        }
        

        

        
    }
    func updateClothesCollectionViewFrame() {
        if let thisCollectionView = clothesCollectionView {
        let frame = thisCollectionView.frame
        var numberOflines = Double(getCurrentCloset().getCapacity()/numberOfClothesPerLine)
            if round(numberOflines) > numberOflines {
                numberOflines = round(numberOflines)
            } else {
                numberOflines = round(numberOflines) + 1
            }
        let linesHeight = numberOflines * Double(sizeOfClothCell)
        let gapsHeight = (1.1 + numberOflines) * Double((CGFloat(gapValuePercentageBetweenCells) * UIScreen.main.bounds.width))
        var totalHeight = linesHeight + gapsHeight
            if Float(totalHeight) > Float(maximumClothesCollectionViewHeight) {
                totalHeight = Double(maximumClothesCollectionViewHeight)
            }
        clothesCollectionView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: CGFloat(Float(totalHeight)))
        }
        print("Recalculated dimensions of Clothes Collection View")
        clothesCollectionView.reloadData()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentClothesImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ClothCell
        
        if closets.count > 0 {
            cell.clothImage.frame.size.width = cell.frame.width
            cell.clothImage.frame.size.height = cell.frame.height
            cell.clothImage.image = currentClothesImages[(indexPath as NSIndexPath).item]
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).item > (currentClothes.count-1) {
            addPicture()
        } else {
            let selectedCloth = currentClothes[(indexPath as NSIndexPath).item]
            let destinationController = DetailFullScreenImageViewController(delegate: weakSelf, cloth: selectedCloth)
            if let navigation = navigationController {
                currentSelectedClothIndex = (indexPath as NSIndexPath).item
                navigation.pushViewController(destinationController, animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let maxIndex = (getCurrentCloset().getClothes().count - 1)
        if (sourceIndexPath as NSIndexPath).item <= maxIndex {
            getCurrentCloset().moveClothPositionAtCloset((sourceIndexPath as NSIndexPath).item, destinationIndex: (destinationIndexPath as NSIndexPath).item)
            reloadClothesCollectionData()
        } else {
            reloadClothesCollectionData()
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeOfClothCellLayout
    }
    
    func updateClothesThatWillBeShown() -> Int {
        if clothesCollectionView != nil {
        
        currentClothesImages.removeAll()
        currentClothesTypes.removeAll()
        currentClothes.removeAll()
        
        let currentCloset = getCurrentCloset()
        currentClothes = currentCloset.getClothes()
        if currentClothes.count > 0 {
            for cloth in currentClothes {
                currentClothesImages.append(cloth.getThumbnail()) // reduce size of image 221 MB detected.
                currentClothesTypes.append(cloth.getType())
            }
        }
       
        
        let availableCapacity = getCurrentCloset().getCapacity() - currentClothes.count
        if availableCapacity > 0 {
            for _ in 0...(availableCapacity - 1) {
                currentClothesImages.append(UIImage(named: "shirtsIconAdd.png"))
            }
        }
        updateClothesCollectionViewFrame()
        updateIcons()
        return currentClothes.count
        } else {
            return 0
        }
    }
    func appendImagePFFileToCurrentClothesImagesFiles(_ image: PFFile) -> Int {
        currentClothesImagesFiles.append(image)
        return currentClothesImagesFiles.count
    }
    
    func reloadClothesCollectionData() {
        if let _ = clothesCollectionView {
            let numberOfClothesToBeShown = updateClothesThatWillBeShown()
            clothesCollectionView.reloadData()
            if numberOfClothesToBeShown > 0 {
                clothesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    func currentSelectedClothFromClothesCollectionView() -> Cloth {
        var cloth: Cloth = Cloth()
        if let selectedCloth = currentSelectedClothIndex {
            cloth = getCurrentCloset().getClothes()[selectedCloth]
        }
        return cloth
    }
    func handleLongPressureGesture(_ longPress: UILongPressGestureRecognizer) {
        switch (longPress.state) {
        case .began:
            guard let selectedIndexPath = clothesCollectionView.indexPathForItem(at: longPress.location(in: clothesCollectionView))
                else { break }
            clothesCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            break
        case .changed:
            clothesCollectionView.updateInteractiveMovementTargetPosition(longPress.location(in: longPress.view!))
            break
        case .ended:
            clothesCollectionView.endInteractiveMovement()
            break
        default:
            clothesCollectionView.cancelInteractiveMovement()
        }
    }

    
    
    
    // MARK: Parse Download
    func downloadClosetsFromServer() {
        print("Downloading Closets from server...")
        myClosetImages.removeAll()
        let closetsQuery = PFQuery(className: "Closet")
        closetsQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        closetsQuery.findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    let PFCloset = object
                    let id = PFCloset.objectId!
                    let ownerId = PFCloset["ownerId"] as! String
                    let name = PFCloset["name"] as! String
                    let capacity = PFCloset["capacity"] as! Int
                    let standImageName = "clothesStand.png"
                    let closet = Closet(id: "\(id)", ownerId: ownerId, name: name, capacity: capacity, standImageName: standImageName)
                    self.closets.append(closet)
                    self.myClosetImages.append(PFCloset["image"] as! PFFile)
                    print("Downloaded closet \(closet.getName()) and it's parameters.")
                }
                self.loadClosetsToScrollView()
            } else {
                print("No closets were found in the server.")
            }
        }
    }
    func downloadClothesFromInitialCloset() {
        print("Downloading Clothes for first closet...")
        let closetQuery = PFQuery(className: "Closet")
        closetQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        closetQuery.getFirstObjectInBackground { (object, error) -> Void in
            if error != nil {
                print("No closets were found for the current user.")
            } else {
                if self.closets.count > 0 && self.clothesCollectionView != nil {
                    print("First closet \(object!["name"]) from user has been found.")
                    print("Started downloading clothes for first closet...")
                    let clothesQuery = PFQuery(className: "Clothes")
                    clothesQuery.whereKey("parentCloset", equalTo: object!.objectId!)
                    clothesQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if let objects = objects {
                            for cloth in objects {
                                let id = cloth.objectId!
                                let name = cloth["name"] as! String
                                let type = cloth["type"] as! String
                                let ownerId = cloth["ownerId"] as! String
                                let image = cloth["image"] as! PFFile
                                let clothCreation:Cloth = Cloth(id: "\(id)", name: name, type: type, ownerId: ownerId)
                                
                                print("Added cloth \(id) to closet \(self.closets[0].getName())")
                                self.closets[0].addCloth(clothCreation)
                                
                                image.getDataInBackground(block: { (data, error) -> Void in
                                    if let _ = data {
                                        let clothImage = UIImage(data: data!)
                                        clothCreation.setImage(clothImage!)
                                        clothCreation.setDownloaded(true)
                                        self.currentClothesImages.append(clothImage)
                                        self.updateClothesThatWillBeShown()
                                        self.clothesCollectionView.reloadData()
                                    }
                                })
                            }
                        self.loadIcons()
                        }
                        self.closets[0].setClothesDownloaded(true)
                        self.parseContentDownloaded = true
                        self.updateClothesThatWillBeShown()
                        self.clothesCollectionView.reloadData()

                    })
                }
            }
        }
    }
    func downloadClothesFromCurrentClosetIfNeeded() {
        
        let closet = getCurrentCloset()
        
        if !closet.getClothesDownloaded() {
            currentClothesImages.removeAll()
            currentClothesTypes.removeAll()
            currentClothes.removeAll()
            currentClothesImagesFiles.removeAll()
        
            let closetId = closet.getId()
            let closetQuery = PFQuery(className: "Closet")
            closetQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
            closetQuery.whereKey("objectId", equalTo: "\(closetId)")
            closetQuery.getFirstObjectInBackground { (object, error) -> Void in
                if error != nil {
                    // show error
                } else {
                    let clothesQuery = PFQuery(className: "Clothes")
                    clothesQuery.whereKey("parentCloset", equalTo: object!.objectId!)
                    clothesQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                        if let objects = objects {
                            for cloth in objects {
                                let id = cloth.objectId!
                                
                                let name = cloth["name"] as! String
                                let type = cloth["type"] as! String
                                let ownerId = cloth["ownerId"] as! String
                                let image = cloth["image"] as! PFFile
                                let clothCreation:Cloth = Cloth(id: "\(id)", name: name, type: type, ownerId: ownerId)
                                closet.addCloth(clothCreation)
                                self.loadIcons()
                                
                                image.getDataInBackground(block: { (data, error) -> Void in
                                    if let _ = data {
                                        let clothImage = UIImage(data: data!)
                                        clothCreation.setImage(clothImage!)
                                        clothCreation.setDownloaded(true)
                                        self.currentClothesImages.append(clothImage)
                                        self.updateClothesThatWillBeShown()
                                        self.clothesCollectionView.reloadData()
                                    }
                                })
                            }
                        }
                        closet.setClothesDownloaded(true)
                        self.updateClothesThatWillBeShown()
                        self.clothesCollectionView.reloadData()
                    })
                }
            }
        }

    }
    func downloadAddedClothToCurrentCloset(_ object: PFObject) {
        let closet = getCurrentCloset()
                let newObject = object
                let id = "\(newObject.objectId!)"
                let name = newObject["name"] as! String
                let type = newObject["type"] as! String
                let ownerId = newObject["ownerId"] as! String
                let image = newObject["image"] as! PFFile
                weakSelf.currentClothesImagesFiles.append(image)
                let cloth = Cloth(id: "\(id)", name: name, type: type, ownerId: ownerId)
                closet.addCloth(cloth)
                weakSelf.loadIcons()
                
                image.getDataInBackground(block: { (data, error) -> Void in
                    weak var weakSelfInClosure = self
                    if let _ = data {
                        let clothImage = UIImage(data: data!)
                        cloth.setImage(clothImage!)
                        cloth.setDownloaded(true)
                        weakSelfInClosure!.currentClothesImages.append(clothImage)
                        weakSelfInClosure!.updateClothesThatWillBeShown()
                        weakSelfInClosure!.clothesCollectionView.reloadData()
                    }
                })
                weakSelf.updateClothesThatWillBeShown()
                weakSelf.clothesCollectionView.reloadData()
    }
    func downloadClothesFromClosets(_ closet: Closet) {
        currentClothesImages.removeAll()
        currentClothesTypes.removeAll()
        currentClothes.removeAll()
        currentClothesImagesFiles.removeAll()
        
        let currentCloset = closet
        print("\(closet.getName()) já foi feito download?: \(closet.getClothesDownloaded()))")
        if currentCloset.getClothesDownloaded() {
            currentClothes = getCurrentCloset().getClothes()
        } else {
            currentClothesImagesFiles.removeAll()
            let clothQuery = PFQuery(className: "Clothes")
            clothQuery.whereKey("parentCloset", equalTo: currentCloset.getId())
            clothQuery.findObjectsInBackground { (objects, error) -> Void in
                weak var weakSelfInClosure = self
                if let objects = objects {
                    for object in objects {
                        let id = "\(object.objectId!)"
                        let name = object["name"] as! String
                        let type = object["type"] as! String
                        let ownerId = object["ownerid"] as! String
                        let image = object["image"] as! PFFile
                        weakSelfInClosure!.currentClothesImagesFiles.append(image)
                        let cloth = Cloth(id: id, name: name, type: type, ownerId:  ownerId)
                        currentCloset.addCloth(cloth)
                        
                        image.getDataInBackground(block: { (data, error) -> Void in
                            if let downloadedImage = data {
                                cloth.setImage(UIImage(data: downloadedImage)!)
                                cloth.setDownloaded(true)
                            }
                        })
                        
                    }
                    weakSelfInClosure!.currentClothes = currentCloset.getClothes()
                    currentCloset.setClothesDownloaded(true)
                }
            }
            
        }
    }
    


    
    // MARK: Take or Get Pictures
    func addPicture() {
        let alert = UIAlertController(title: "Adicionar Roupa",
                                      message: "Gostaria de adicionar uma roupa?",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let album = UIAlertAction(title: "Escolher do Album",
                                  style: UIAlertActionStyle.default,
                                  handler: { (getFromPhotoLibraryAction) -> Void in
                                  weak var weakSelfInClosure = self
                                  weakSelfInClosure!.takePictureFromPhotoLibrary()
        })
        let camera = UIAlertAction(title: "Tirar Foto",
                                   style: UIAlertActionStyle.default,
                                   handler: { (getFromPhotoLibraryAction) -> Void in
                                   weak var weakSelfInClosure = self
                                   weakSelfInClosure!.takeShot()
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
        weakSelf.present(alert, animated: true, completion: nil)
        
        setTypeOfPictureBeingTaken("cloth")
    }
    func takePictureFromPhotoLibrary() {
        let photoLibraryImage = UIImagePickerController()
        photoLibraryImage.sourceType = UIImagePickerControllerSourceType.photoLibrary
        photoLibraryImage.delegate = weakSelf
        photoLibraryImage.allowsEditing = true
        weakSelf.present(photoLibraryImage, animated: true, completion: nil)
 
    }
    func takeShot() {
        let cameraImage = UIImagePickerController()
        cameraImage.sourceType = UIImagePickerControllerSourceType.camera
        cameraImage.delegate = weakSelf
        cameraImage.allowsEditing = true
        cameraImage.showsCameraControls = true
        weakSelf.present(cameraImage, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if typeOfPictureTaken == "cloth" {
            let destinationController = RegisterClothViewController(delegate: self, clothImage: image)
            if let navigation = navigationController {
                navigation.pushViewController(destinationController, animated: true)
            }
            self.dismiss(animated: true, completion: nil)
        } else if typeOfPictureTaken == "closet" {
            self.dismiss(animated: true, completion: nil)
            UIApplication.shared.beginIgnoringInteractionEvents()
            let windowWidth = UIScreen.main.bounds.width*0.8
            let alert = SCLAlertView(newWindowWidth: windowWidth)
            alert?.showAnimationType = .SlideInToCenter
            alert?.hideAnimationType = .SlideOutFromCenter
            alert?.backgroundType = .Shadow
            alert?.showWaiting("Relaxe", subTitle: "Estamos salvando sua nova foto do armário", closeButtonTitle: nil, duration: 15.0)
            
            let closet = getCurrentCloset()
            let closetIndex = closets.index(where: { (Closet) -> Bool in
                return Closet.getId() == closet.getId()
            })
            let closetQuery = PFQuery(className: "Closet")
            closetQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
            closetQuery.getObjectInBackground(withId: "\(closet.getId())") { (object, error) -> Void in
                if error != nil {
                    print(error)
                } else if let object = object {
                    let imageData = UIImageJPEGRepresentation(image, CGFloat(0.5))
                    let imageFile = PFFile(name: "\(closet.getName()).png", data: imageData!)
                    object["image"] = imageFile
                    object.saveInBackground(block: { (success, error) -> Void in
                        
                        if success {
                            alert?.hideView()    
                            closet.setImage(image)
                            weak var weakSelfInClosure = self
                            if let closetsScroll = weakSelfInClosure!.closetsScrollView {
                                
                                for view in weakSelfInClosure!.closetsScrollView.subviews as! [UIImageView] {
                                    if view.tag == closetIndex {
                                        view.removeFromSuperview()
                                    }
                                }
                                
                                var frame = weakSelfInClosure!.closetsScrollView.bounds
                                frame.origin.x = frame.size.width * CGFloat(closetIndex!)
                                frame.origin.y = UIScreen.main.bounds.height*(0.04)
                                frame.size.height = weakSelfInClosure!.closetsScrollView.bounds.height*0.85
                                print("Subviews é : \(weakSelfInClosure!.closetsScrollView.subviews.count)")
                                let newPageView = UIImageView(image: weakSelfInClosure!.closets[closetIndex!].getImage())
                                newPageView.contentMode = .scaleAspectFit
                                newPageView.frame = frame
                                weakSelfInClosure!.closetsScrollView.insertSubview(newPageView, at: closetIndex!)
                                print("Subviews é : \(weakSelfInClosure!.closetsScrollView.subviews.count)")
                                
                            }
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                        }
                    })
                }
            }
        }
        
    }
    func setTypeOfPictureBeingTaken(_ type: String) {
        typeOfPictureTaken = type
    }
    
    
    
    
    
    // MARK: Icon Actions
    func animateIcons() {
        for icon in arrayOfIcons {
            icon.animateFloating()
        }
    }
    func searchForIconOfType(_ type: String) -> Bool {
        var found = false
        for icon in arrayOfIcons {
            if icon.getType() == type {
                found = true
            }
        }
        return found
    }
    func initAvailablePositionsForIcons () {
        print("Initializing Position for Icons.")
        let increment = (UIScreen.main.bounds.height * heightInvervalBetweenIcons)
        let iconPosition1 = CGPoint(x: UIScreen.main.bounds.width*0.01, y: startedIconCGPoint.y + (0 * increment))
        let iconPosition2 = CGPoint(x: UIScreen.main.bounds.width*0.01, y: startedIconCGPoint.y + (1 * increment))
        let iconPosition3 = CGPoint(x: UIScreen.main.bounds.width*0.01, y: startedIconCGPoint.y + (2 * increment))
        let iconPosition4 = CGPoint(x: UIScreen.main.bounds.width*0.01, y: startedIconCGPoint.y + (3 * increment))
        
        let iconPosition5 = CGPoint(x: UIScreen.main.bounds.width*0.805, y: startedIconCGPoint.y + (0 * increment))
        let iconPosition6 = CGPoint(x: UIScreen.main.bounds.width*0.805, y: startedIconCGPoint.y + (1 * increment))
        let iconPosition7 = CGPoint(x: UIScreen.main.bounds.width*0.805, y: startedIconCGPoint.y + (2 * increment))
        let iconPosition8 = CGPoint(x: UIScreen.main.bounds.width*0.805, y: startedIconCGPoint.y + (3 * increment))
        
        availablePositionsForIcons.append(iconPosition1)
        availablePositionsForIcons.append(iconPosition2)
        availablePositionsForIcons.append(iconPosition3)
        availablePositionsForIcons.append(iconPosition4)
        availablePositionsForIcons.append(iconPosition5)
        availablePositionsForIcons.append(iconPosition6)
        availablePositionsForIcons.append(iconPosition7)
        availablePositionsForIcons.append(iconPosition8)
        
        for _ in 0...7 {
            availableIndexForIcons.append(true)
        }
        
    }
    func getAvailablePositionForIcon () -> CGPoint {
        var availablePoint = 0
        for index in availableIndexForIcons {
            if index == true {
                return availablePositionsForIcons[availablePoint]
            }
            availablePoint = availablePoint + 1
        }
        return borningIconCGPoint
    }
    func disableAvailablePosition () {
        let cgPointOccupied = getAvailablePositionForIcon()
        let index = availablePositionsForIcons.index(of: cgPointOccupied)
        if index != nil {
        availableIndexForIcons[index!] = false
        }
    }
    func enableThisPosition(_ iconPosition: CGPoint) {
        let index = availablePositionsForIcons.index(of: iconPosition)
        availableIndexForIcons[index!] = true
    }
    func addNecessaryIcons() {
        
        // Create Acessories Icon
        if getCurrentCloset().getCapacityByType("Acessorio") > 0 {
            if searchForIconOfType("Acessorio") {
                arrayOfIconsThatNeedToAppear.append(acessoriesIcon!)
            } else {
                acessoriesIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Acessorio"),
                    type: "Acessorio",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(acessoriesIcon!)
                arrayOfIconsThatNeedToAppear.append(acessoriesIcon!)
                acessoriesIcon!.setIconScreenTag(1)
            }
        }
        
        // Create Jacket Icon
        if getCurrentCloset().getCapacityByType("Jaqueta") > 0 {
            if searchForIconOfType("Jaqueta") {
                arrayOfIconsThatNeedToAppear.append(jacketsIcon!)
            } else {
                jacketsIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Jaqueta"),
                    type: "Jaqueta",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(jacketsIcon!)
                arrayOfIconsThatNeedToAppear.append(jacketsIcon!)
                jacketsIcon!.setIconScreenTag(2)
            }
        }
        
        // Create Shirts Icon
        if getCurrentCloset().getCapacityByType("Camisa") > 0 {
            if searchForIconOfType("Camisa") {
                arrayOfIconsThatNeedToAppear.append(shirtsIcon!)
            } else {
                shirtsIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Camisa"),
                    type: "Camisa",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(shirtsIcon!)
                arrayOfIconsThatNeedToAppear.append(shirtsIcon!)
                shirtsIcon!.setIconScreenTag(2)
            }
        }
        
        // Create Tshirts Icon
        if getCurrentCloset().getCapacityByType("Camiseta") > 0 {
            if searchForIconOfType("Camiseta") {
                arrayOfIconsThatNeedToAppear.append(tShirtsIcon!)
            } else {
                tShirtsIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Camiseta"),
                    type: "Camiseta",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(tShirtsIcon!)
                arrayOfIconsThatNeedToAppear.append(tShirtsIcon!)
                tShirtsIcon!.setIconScreenTag(4)
            }
        }
        
        // Create Skirts Icon
        if getCurrentCloset().getCapacityByType("Saia") > 0 {
            if searchForIconOfType("Saia") {
                arrayOfIconsThatNeedToAppear.append(skirtsIcon!)
            } else {
                skirtsIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Saia"),
                    type: "Saia",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(skirtsIcon!)
                arrayOfIconsThatNeedToAppear.append(skirtsIcon!)
                skirtsIcon!.setIconScreenTag(5)
            }
        }
        
        // Create Dress Icon
        if getCurrentCloset().getCapacityByType("Vestido") > 0 {
            if searchForIconOfType("Vestido") {
                arrayOfIconsThatNeedToAppear.append(dressesIcon!)
            } else {
                dressesIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Vestido"),
                    type: "Vestido",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(dressesIcon!)
                arrayOfIconsThatNeedToAppear.append(dressesIcon!)
                dressesIcon!.setIconScreenTag(6)
            }
        }
        
        // Create Underwear Icon
        if getCurrentCloset().getCapacityByType("Calcinha") > 0 {
             if searchForIconOfType("Calcinha") {
                arrayOfIconsThatNeedToAppear.append(underwearIcon!)
             } else {
                underwearIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Calcinha"),
                    type: "Calcinha",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(underwearIcon!)
                arrayOfIconsThatNeedToAppear.append(underwearIcon!)
                underwearIcon!.setIconScreenTag(7)
            }
        }
        
        // Create Pants Icon
        if getCurrentCloset().getCapacityByType("Calca") > 0 {
            if searchForIconOfType("Calca") {
                arrayOfIconsThatNeedToAppear.append(pantsIcon!)
            } else {
                pantsIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Calca"),
                    type: "Calca",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(pantsIcon!)
                arrayOfIconsThatNeedToAppear.append(pantsIcon!)
                pantsIcon!.setIconScreenTag(8)
            }
        }
        
        /*
        // Create Sockets Icon
        if getCurrentCloset().getCapacityByType("Meias") > 0 {
            if searchForIconOfType("Meias") {
                arrayOfIconsThatNeedToAppear.append(socketsIcon!)
            } else {
                socketsIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Meias"),
                    type: "Meias",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(socketsIcon!)
                arrayOfIconsThatNeedToAppear.append(socketsIcon!)
                socketsIcon!.setIconScreenTag(9)
            }
        }
        
    
        
        // Create Shoes Icon
        if getCurrentCloset().getCapacityByType("Calcados") > 0 {
            if searchForIconOfType("Calcados") {
                arrayOfIconsThatNeedToAppear.append(shoesIcon!)
            } else {
                shoesIcon = IconParameter(controller: weakSelf,
                    imageName: Enumerators().getImageForClothType("Calcados"),
                    type: "Calcados",
                    startPoint: CGPoint(x: borningIconCGPoint.x,y: borningIconCGPoint.y))
                arrayOfIcons.append(shoesIcon!)
                arrayOfIconsThatNeedToAppear.append(shoesIcon!)
                shoesIcon!.setIconScreenTag(10)
            }
        }
        */
        

        reorderIconsAlreadyOnTheScreen()
        
        // Make Missing Icons To Appear
        var index = 0
        for icon in arrayOfIconsThatNeedToAppear {
            if !icon.getStatus() {
                icon.appear(closetsScrollView, newPosition: getAvailablePositionForIcon())
                disableAvailablePosition()
            }
            index = index + 1
        }
        arrayOfIconsThatNeedToAppear.removeAll()
        resetIconsStarterPoint()
        
    }
    func hideUnecessaryIcons() {
        var index = 0
        for icon in arrayOfIcons {
            if getCurrentCloset().getCapacityByType(icon.getType()) == 0 {
                if icon.getStatus() {
                    icon.hide(closetsScrollView)
                    enableThisPosition(icon.getLastPosition())
                }
            }
            index = index + 1
        }
    }
    func reorderIconsAlreadyOnTheScreen() {
        resetIconsStarterPoint()
        arrayOfIcons = arrayOfIcons.sorted(by: { $0.getIconScreenTag() < $1.getIconScreenTag() })
        movedIcons = 0
        for icon in arrayOfIcons {
            if icon.moveToNewPosition(getAvailablePositionForIcon()) {
                disableAvailablePosition()
            }
        }
    }
    func updateIcons() {
        for icon in arrayOfIcons {
            icon.updateIconValue(getCurrentCloset())
        }
    }
    func loadIcons() {
        hideUnecessaryIcons()
        addNecessaryIcons()
        updateIcons()
    }
    func resetIconsStarterPoint() {
        for index in 0...7 {
            availableIndexForIcons[index] = true
        }
    }
    
    
    
    deinit {
        print("MyClosetViewController has been deinitialised")
    }
    
}









// MARK: Class for Creating Icons in Views
class IconParameter {
    fileprivate var parameterValueLabel = UILabel()
    fileprivate var image = UIImage()
    fileprivate var startPoint = CGPoint()
    fileprivate var rememberPoint = CGPoint()
    fileprivate let container = UIImageView()
    fileprivate let controller: UIViewController!
    fileprivate let type: String!
    fileprivate var status: Bool = false
    fileprivate var screenTag: Int = 0
    
    // Initializers
    init (controller: UIViewController, imageName: String, type: String, startPoint: CGPoint) {
        self.controller = controller
        self.image = UIImage(named: imageName)!
        self.startPoint = startPoint
        self.type = type
        create()
        animateFloating()
    }
    
    // Actions
    func create() {
        let screenWidth = UIScreen.main.bounds.width
        
        // Create Icon Container
        container.frame = CGRect(x: startPoint.x, y: startPoint.y, width: screenWidth*0.20, height: screenWidth*0.17)
        container.layer.cornerRadius = CGFloat(7)
        controller.view.addSubview(container)
        
        // Create Rounded White Square Behind Value
        let roundedSquare = UIImageView()
        roundedSquare.frame = CGRect(x: screenWidth*0.04, y: 0, width: screenWidth*0.14, height: screenWidth*0.1)
        roundedSquare.layer.cornerRadius = CGFloat(7)
        roundedSquare.backgroundColor = UIColor.white
        roundedSquare.alpha = 0.9
        container.addSubview(roundedSquare)
        
        // Create Icon Image
        let iconView = UIImageView()
        iconView.frame = CGRect(x: 0, y: screenWidth*0.01, width: screenWidth*0.075, height: screenWidth*0.075)
        iconView.image = self.image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        iconView.tintColor = UIColor(red: 254/255, green: 113/255, blue: 152/255, alpha: CGFloat(1))
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)
        
        // Create Icon Label for Values
        parameterValueLabel.frame = CGRect(x: screenWidth*0.06, y: 0, width: screenWidth*0.12, height: screenWidth*0.1)
        parameterValueLabel.textAlignment = NSTextAlignment.center
        parameterValueLabel.text = ""
        parameterValueLabel.font = parameterValueLabel.font.withSize(11)
        if Device().getType() >= 60 {
            parameterValueLabel.font = parameterValueLabel.font.withSize(15)
        }
        container.addSubview(parameterValueLabel)
        
        self.status = false
    }
    func animateFloating() {
        let screenHeight = UIScreen.main.bounds.height
        let animatedIcon = self.container as UIView
        animatedIcon.alpha = 1
        let duration = 1.0
        let delay = TimeInterval(arc4random_uniform(10))/10
        let options: UIViewAnimationOptions = [.autoreverse, .repeat]
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            animatedIcon.frame = CGRect(x: animatedIcon.frame.origin.x, y: (animatedIcon.frame.origin.y + (screenHeight*0.005)), width: animatedIcon.frame.width, height: animatedIcon.frame.height)
            animatedIcon.alpha = 0.9
            }, completion: nil)
    }
    func hide(_ belowSubView: UIView) {
        if self.status == true {
            self.status = false
            let screenHeight = UIScreen.main.bounds.height
            let screenWidth = UIScreen.main.bounds.width
            for view in self.controller.view.subviews {
                if view == self.container {
                    let myFrame = self.container.frame
                    self.container.superview?.insertSubview(self.container, belowSubview: belowSubView)
                    let animatedIcon = self.container as UIView
                    let duration = 0.6
                    let delay = 0.0
                    let options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseIn]
                    UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                        animatedIcon.frame = CGRect(x: screenWidth*0.5, y: screenHeight*0.25, width: myFrame.width, height: myFrame.height)
                        }, completion: { finished in
                            self.container.frame = CGRect(x: screenWidth*0.5, y: screenHeight*0.25, width: myFrame.width, height: myFrame.height)
                            self.container.superview?.sendSubview(toBack: self.container)
                    })
                }
            }
        }
    }
    func appear(_ belowSubView: UIView, newPosition: CGPoint) {
        if self.status == false {
            for view in self.controller.view.subviews {
                if view == self.container {
                    self.status = true
                    self.startPoint = newPosition
                    let myFrame = self.container.frame
                    self.container.superview?.insertSubview(self.container, belowSubview: belowSubView)
                    let animatedIcon = self.container as UIView
                    let duration = 0.8
                    let delay = 0.0
                    let options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseIn]
                    UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                        animatedIcon.frame = CGRect(x: self.startPoint.x, y: self.startPoint.y, width: myFrame.width, height: myFrame.height)
                        }, completion: { finished in
                            self.container.frame = CGRect(x: self.startPoint.x, y: self.startPoint.y, width: myFrame.width, height: myFrame.height)
                            self.container.superview?.bringSubview(toFront: self.container)
                            self.animateFloating()
                    })
                }
            }
        }
        self.container.bringSubview(toFront: self.container)
    }
    func moveToNewPosition(_ newPosition: CGPoint) -> Bool {
        if self.status == true {
            self.startPoint = newPosition
            let animatedIcon = self.container as UIView
            let duration = 0.4
            let delay = 0.0
            let options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseIn]
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                animatedIcon.frame = CGRect(x: newPosition.x, y: newPosition.y, width: animatedIcon.frame.width, height: animatedIcon.frame.height)
                }, completion: { finished in
                    self.container.frame = CGRect(x: newPosition.x, y: newPosition.y, width: animatedIcon.frame.width, height: animatedIcon.frame.height)
                    self.container.superview?.bringSubview(toFront: self.container)
                    self.animateFloating()
            })
            return true
        } else {
            return false
        }
    }
    
    // Getters
    func getContainer() -> UIView {
        return self.container as UIView
    }
    func getType() -> String {
        return self.type
    }
    func getStatus() -> Bool {
        return self.status
    }
    func getIconScreenTag() -> Int {
        return self.screenTag
    }
    func getLastPosition() -> CGPoint {
        return self.startPoint
    }

    // Setters
    func updateIconValue(_ currentCloset: Closet) {
        let number = currentCloset.getClothesOfType(self.type).count
        self.parameterValueLabel.text = ("\(number)")
    }
    func setValue(_ value: String) {
        self.parameterValueLabel.text = value
    }
    func setStartPoint(_ newPoint: CGPoint) {
        self.startPoint = newPoint
    }
    func setIconScreenTag(_ tag: Int) {
        self.screenTag = tag
    }
    
    
    deinit {
        print("Icons \(self.type) was deinitialized.")
    }
}


// MARK: Class to Create Custom Clothes UICollectionViewCell
class ClothCell: UICollectionViewCell {
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
            weak var weakClothCell = self
            weakClothCell!.clothImage.frame = CGRect(x: 0, y: 2, width: frame.size.width*0.9, height: frame.size.height*0.9)
            weakClothCell!.clothImage.alpha = 0.9
            }, completion: nil)
        contentView.addSubview(clothImage)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}



