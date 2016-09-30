//
//  DetailFullScreenImageViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 31/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import UIKit
import Parse
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol ManageClothesDelegate {
    func currentSelectedClothFromClothesCollectionView() -> Cloth
    func getCurrentCloset() -> Closet
    func getClosetById(_ closetId: String) -> Closet
    func updateClothesThatWillBeShown() -> Int
    func informClothWasRemoved()
    func scrollToCloset(_ closetIndex: Int)
    func downloadClothesFromClosets(_ closet: Closet)
    func getMyClosets() -> Array<Closet>
    func getMyClosetImages() -> Array<PFFile>
    func downloadClothesFromCurrentClosetIfNeeded()
}


class DetailFullScreenImageViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var detailImageScrollView: UIScrollView!
    var detailImage: UIImageView!
    var delegate: ManageClothesDelegate?
    var cloth: Cloth!
    var myToolBarItems = [UIBarButtonItem]()
    var arrayViewsAlert = [UIView]()
    var myClosetsOptions = [Closet]()
    var myClosetsImages = [PFFile]()
    var imageClicked = UIButton()
    var adInfo = [AnyObject]()
    
    // Initializers
    init(delegate: ManageClothesDelegate, cloth: Cloth) {
        self.delegate = delegate
        self.cloth = cloth
        super.init(nibName: "DetailFullScreenImageViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        setupClosetInformation()
        createEditClothButton()
        createToolBar()
        createDetailImageScrollView()
        addImageForFullScreen()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isToolbarHidden = false
        setScrollViewZoomProperties()
        if let clothImage = detailImage {
            detailImage.image = cloth.getImage()
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        createToolBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.isToolbarHidden = true
    }
    
    
    // MARK: Create Detail Image ScrollView
    func createDetailImageScrollView() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        detailImageScrollView = UIScrollView()
        detailImageScrollView.delegate = self
        detailImageScrollView.isPagingEnabled = false
        detailImageScrollView.clipsToBounds = true
        detailImageScrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight-44)
        detailImageScrollView.showsHorizontalScrollIndicator = false
        detailImageScrollView.showsVerticalScrollIndicator = false
        detailImageScrollView.backgroundColor = AppCustomColor().lightGray
        self.view.addSubview(detailImageScrollView)
        
        detailImage = UIImageView()
        detailImage.frame = detailImageScrollView.frame
        detailImage.contentMode = .scaleAspectFit
        detailImageScrollView.addSubview(detailImage)
        detailImageScrollView.contentSize = CGSize(width: detailImage.frame.width, height: detailImage.frame.height)
        
        let twoFingerTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailFullScreenImageViewController.scrollViewTwoFingerTapped(_:)))
        twoFingerTapRecognizer.numberOfTapsRequired = 1
        twoFingerTapRecognizer.numberOfTouchesRequired = 2
        detailImageScrollView.addGestureRecognizer(twoFingerTapRecognizer)
        
        let doubleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailFullScreenImageViewController.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        detailImageScrollView.addGestureRecognizer(doubleTapRecognizer)
        print("Created ScrollView to manipulate cloth in the screen.")
    }
    func addImageForFullScreen() {
        if let selectedCloth = delegate {
            let cloth: Cloth = selectedCloth.currentSelectedClothFromClothesCollectionView()
            detailImage.image = cloth.getImage()
//            detailImage.frame = CGRect(x: 0, y: 0, width: detailImage.image!.size.width, height: detailImage.image!.size.height)
            detailImageScrollView.contentSize = CGSize(width: detailImage.bounds.size.width, height: detailImage.bounds.size.height)
        }
    }
    func setScrollViewZoomProperties() {
        let scrollViewFrame = detailImageScrollView.frame
        let scaleWidth: CGFloat = scrollViewFrame.size.width / self.detailImageScrollView.contentSize.width
        let scaleHeigth: CGFloat = scrollViewFrame.size.height / self.detailImageScrollView.contentSize.height
        let minScale = min(scaleWidth,scaleHeigth)
        detailImageScrollView.minimumZoomScale = minScale
        detailImageScrollView.maximumZoomScale = 2.0
    }
    func centerScrollViewContents() {
        let boundsSize: CGSize = detailImageScrollView.bounds.size
        var contentsFrame: CGRect = detailImage.frame
        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width)/2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height)/2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        detailImage.frame = contentsFrame
    }
    func scrollViewTwoFingerTapped(_ gesture: UITapGestureRecognizer) {
        var newZoomScale: CGFloat = detailImageScrollView.maximumZoomScale / 1.5
        newZoomScale = max(newZoomScale, detailImageScrollView.minimumZoomScale)
        detailImageScrollView.setZoomScale(newZoomScale, animated: true)
    }
    func scrollViewDoubleTapped(_ gesture: UITapGestureRecognizer) {
        // Get the point where the double tap occurred
        let pointInView: CGPoint = gesture.location(in: self.view)
        
        // Calculate maximum allowed zoom
        let newZoomScale = self.detailImageScrollView.zoomScale*2.0
//        newZoomScale = min(newZoomScale, self.detailImageScrollView.zoomScale)
        
        // Calculate CGRect to Zoom in
        let bounds = detailImageScrollView.bounds.size
        let w: CGFloat = bounds.width / newZoomScale
        let h: CGFloat = bounds.height / newZoomScale
        let x: CGFloat = pointInView.x - (w/2.0)
        let y: CGFloat = pointInView.y - (h/2.0)
        let rectToZoomTo: CGRect = CGRect(x: x, y: y, width: w, height: h)
        
        // Let scroll view to zoom in
        detailImageScrollView.zoom(to: rectToZoomTo, animated: true)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return detailImage
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }


    // MARK: Setup Navigation Items
    func createEditClothButton() {
        let editClothButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(DetailFullScreenImageViewController.editCloth))
        self.navigationItem.rightBarButtonItem = editClothButton
    }
    
    // MARK: Setup ToolBar Items
    func createDeleteClothButton() -> UIBarButtonItem {
        let deleteClothButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(DetailFullScreenImageViewController.areYouSureToDelete))
        return deleteClothButton
    }
    func createMoveClothButton() -> UIBarButtonItem {
        let moveClothButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.bookmarks, target: self, action: #selector(DetailFullScreenImageViewController.moveClothToCloset))
        return moveClothButton
    }
    func createCropClothButton() -> UIBarButtonItem {
        let cropClothButton = UIBarButtonItem(image: UIImage(named: "customCrop.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(DetailFullScreenImageViewController.cropCloth))
        return cropClothButton
    }
    func createSellClothButton() -> UIBarButtonItem {
        let sellClothButton = UIBarButtonItem(image: UIImage(named: "saleIcon.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(DetailFullScreenImageViewController.createAd))
        return sellClothButton
    }
    func createFlexibleItem() -> UIBarButtonItem {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        return flexibleItem
    }
    func createToolBar() {
        print("Creating tools to edit cloth...")
        myToolBarItems.removeAll()
        myToolBarItems.append(createFlexibleItem())
        myToolBarItems.append(createMoveClothButton())
        myToolBarItems.append(createFlexibleItem())
        myToolBarItems.append(createCropClothButton())
        myToolBarItems.append(createFlexibleItem())
        if PFUser.current()!["ads"] as! Int > 0 {
            print(PFUser.current()!["ads"])
            myToolBarItems.append(createSellClothButton())
            myToolBarItems.append(createFlexibleItem())
        }
        myToolBarItems.append(createDeleteClothButton())
        myToolBarItems.append(createFlexibleItem())
        if let navigation = self.navigationController {
            navigation.toolbar.items = myToolBarItems
            print("Created bottom bar with tools.")
        }
        if let navigation = self.navigationController {
            navigation.isNavigationBarHidden = false
        }
    }
    
    // MARK: Setup Closet Information {
    func setupClosetInformation() {
        if let allMyClosets = delegate?.getMyClosets() {
            for closet in allMyClosets {
                let closetId = closet.getId()
                let clothesQuery = PFQuery(className: "Clothes")
                clothesQuery.whereKey("ownerId", equalTo: PFUser.current()!.objectId!)
                clothesQuery.whereKey("parentCloset", equalTo: closetId)
                clothesQuery.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        let numberOfClothes = objects.count
                        closet.setNumberOfClothes(numberOfClothes)
                    }
                })
            }
        }
    }
    
    
    // MARK: Operations with Cloth
    func editCloth() {
        for view in arrayViewsAlert {
            view.removeFromSuperview()
        }
        let destinationController = EditClothViewController(cloth: self.cloth!)
        if let navigation = navigationController {
            navigation.pushViewController(destinationController, animated: true)
        }
    }
    func areYouSureToDelete() {
        
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(UIScreen.main.bounds.width*0.8))
        alert.showQuestion("Gostaria de deletar a roupa?", subTitle: "Se você deletar a roupa todos os looks que possui esta roupa serão automaticamente excluídos", closeButtonTitle: "Não, foi sem querer!", duration: 0.0)
        let removeButton: SCLButton = alert.addButton("Sim eu quero remover", target: self, selector: #selector(DetailFullScreenImageViewController.deleteCloth))
        removeButton.backgroundColor = UIColor.gray
        
        
//        let alert = UIAlertController(title: "Deletar Roupa",
//            message: "Gostaria de deletar esta roupa?",
//            preferredStyle: UIAlertControllerStyle.Alert)
//        
//        let ok = UIAlertAction(title: "Sim eu quero remover",
//            style: UIAlertActionStyle.Default,
//            handler: { (getFromPhotoLibraryAction) -> Void in
//                self.deleteCloth()
//        })
//        let cancel = UIAlertAction(title: "Não, foi sem querer!",
//            style: UIAlertActionStyle.Cancel,
//            handler: { (cancelAction) -> Void in
//                self.dismissViewControllerAnimated(true, completion: nil)
//        })
//        alert.addAction(ok)
//        alert.addAction(cancel)
//        self.presentViewController(alert, animated: true, completion: nil)
    }
    func deleteCloth() {
        for view in arrayViewsAlert {
            view.removeFromSuperview()
        }
        if let _ = delegate {
            if let clothToBeRemoved = cloth {
                
                let lookQuery = PFQuery(className: "Looks")
                lookQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
                lookQuery.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        for look in objects {
                            let lookClothes = look["clothes"] as! [String]
                            for cloth in lookClothes {
                                if cloth == clothToBeRemoved.getId() {
                                    look.deleteInBackground(block: { (success, error) in
                                        if success {
                                            print("Look deletado")
                                        }
                                    })
                                }
                            }
                        }
                    }
                })
                
                
                
                let closetId = clothToBeRemoved.getClosetId()
                let closet = delegate!.getClosetById(closetId)
                let clothQuery = PFQuery(className: "Clothes")
                print(clothToBeRemoved.getId())
                clothQuery.getObjectInBackground(withId: "\(clothToBeRemoved.getId())", block: { (object, error) -> Void in
                    if error != nil {
                    } else {
                        if let object = object {
                            object.deleteInBackground(block: { (sucess, error) -> Void in
                                self.delegate!.informClothWasRemoved()
                                closet.removeCloth(clothToBeRemoved)
                                self.delegate!.updateClothesThatWillBeShown()
                                self.dismissViewControllerBackToClosets()
                            })
                        }
                    }
                })
            }
        }
    }
    func cropCloth() {
        let destinationController = CustomCropViewController(cloth: self.cloth!)
        if let navigation = navigationController {
            navigation.pushViewController(destinationController, animated: true)
        }
        
    }
    func moveClothToCloset() {
        for view in arrayViewsAlert {
            view.removeFromSuperview()
        }
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        
        if let allMyClosets = delegate?.getMyClosets() {
                myClosetsOptions = allMyClosets
                if let index = myClosetsOptions.index(where: { (Closet) -> Bool in
                    return Closet.getId() == cloth.getClosetId()
                }) {
                    myClosetsOptions.remove(at: index)
                    if let myImages = delegate?.getMyClosetImages() {
                        myClosetsImages = myImages
                        myClosetsImages.remove(at: index)
                    }
                }
        }
        
        for closet in myClosetsOptions {
            if (closet.getCapacity() - closet.getNumberOfClothes()) == 0 {
                if let index = myClosetsOptions.index(where: { (Closet) -> Bool in
                    return Closet.getId() == closet.getId()
                }) {
                    myClosetsOptions.remove(at: index)
                    if let myImages = delegate?.getMyClosetImages() {
                        myClosetsImages = myImages
                        myClosetsImages.remove(at: index)
                    }
                }
            }
        }

        
        
        let blackCover = UIView()
        blackCover.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        blackCover.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.7))
        self.view.addSubview(blackCover)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailFullScreenImageViewController.cancelChangingCloset(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        blackCover.addGestureRecognizer(tapGesture)
        
        let whitePanel = UIView()
        whitePanel.frame = CGRect(x: screenWidth*0.02, y: screenHeight*0.65, width: screenWidth*0.96, height: screenHeight*0.2)
        whitePanel.layer.cornerRadius = CGFloat(7)
        whitePanel.layer.masksToBounds = true
        whitePanel.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.9))
        self.view.addSubview(whitePanel)
        
        let actionLabel = UILabel()
        actionLabel.frame.size.width = whitePanel.frame.width
        actionLabel.frame.size.height = screenHeight*0.05
        actionLabel.frame.origin.x = 0
        actionLabel.frame.origin.y = 0
        actionLabel.textAlignment = NSTextAlignment.center
        actionLabel.font = UIFont(name: (actionLabel.font?.fontName)!, size: CGFloat(10))
        actionLabel.text = "Mova sua roupa para um dos armários abaixo."
        whitePanel.addSubview(actionLabel)
        
        // Create Closets Collection View Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0,
            left: 5,
            bottom: 5,
            right: 5)
        layout.itemSize = CGSize(width: screenHeight*0.11, height: screenHeight*0.11)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat(4)
        layout.minimumLineSpacing = CGFloat(6)
        
        // Create Closets Collection View Frame
        let selectClosetsCollectionViewFrame = CGRect(x: 0,y: screenHeight*0.01, width: whitePanel.frame.width, height: screenHeight*0.2)
        let selectClosetsCollectionView = UICollectionView(frame: selectClosetsCollectionViewFrame, collectionViewLayout: layout)
        selectClosetsCollectionView.dataSource = self
        selectClosetsCollectionView.delegate = self
        selectClosetsCollectionView.showsHorizontalScrollIndicator = false
        selectClosetsCollectionView.showsVerticalScrollIndicator = false
        selectClosetsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        selectClosetsCollectionView.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.0))
        whitePanel.addSubview(selectClosetsCollectionView)
        
        arrayViewsAlert.append(blackCover)
        arrayViewsAlert.append(whitePanel)

    }
    func cancelChangingCloset(_ gesture: UITapGestureRecognizer) {
        for view in arrayViewsAlert {
            view.removeFromSuperview()
        }
    }
    
    // MARK: Create Ad Pop Up
    func createAd() {
        print("User wants to sell the cloth.")
        print("\n\n\nAD VIEW CONTROLLER IS BEING LOADED...")
        adInfo.removeAll()
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        print("Creating ad form...")
        let form = UIView()
        form.frame = CGRect(x: 5, y: 70, width: screenWidth-10, height: screenHeight-75)
        form.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.9))
        form.layer.cornerRadius = CGFloat(7)
        form.layer.masksToBounds = true
        self.view.addSubview(form)
        
        // Name Fields
        let nameTitle = UILabel()
        nameTitle.frame = CGRect(x: 7, y: 7, width: 300, height: 15)
        nameTitle.text = "Título do Anúncio"
        nameTitle.textColor = AppCustomColor().lightGray
        form.addSubview(nameTitle)
        
        let nameText = UITextField()
        nameText.frame = CGRect(x: 7, y: (2*nameTitle.frame.origin.y) + nameTitle.frame.size.height, width: form.frame.size.width-14, height: 25)
        nameText.textColor = AppCustomColor().pink
        nameText.font = UIFont(name: nameText.font!.fontName, size: CGFloat(20))
        nameText.addTarget(nil, action: #selector(DetailFullScreenImageViewController.firstResponderAction(_:)), for: .editingDidEndOnExit)
        form.addSubview(nameText)
        print("Added name field.")
        
        let divisor = UILabel()
        divisor.frame = CGRect(x: 7, y: nameText.frame.origin.y + nameText.frame.size.height + 1 , width: form.frame.size.width - 14, height: 1)
        divisor.backgroundColor = UIColor.black
        form.addSubview(divisor)
        
        // Description Fields
        let descriptionTitle = UILabel()
        descriptionTitle.frame = CGRect(x: 7, y: divisor.frame.origin.y + divisor.frame.size.height + 7 , width: 300, height: 15)
        descriptionTitle.text = "Descrição do Anúncio"
        descriptionTitle.textColor = AppCustomColor().lightGray
        form.addSubview(descriptionTitle)
        
        let descriptionText = UITextField()
        descriptionText.frame = CGRect(x: 7, y: descriptionTitle.frame.origin.y + descriptionTitle.frame.size.height + 7, width: form.frame.size.width-14, height: 25)
        descriptionText.textColor = AppCustomColor().pink
        descriptionText.font = UIFont(name: descriptionText.font!.fontName, size: CGFloat(20))
        descriptionText.addTarget(nil, action: #selector(DetailFullScreenImageViewController.firstResponderAction(_:)), for: .editingDidEndOnExit)
//        descriptionText.backgroundColor = UIColor.whiteColor()
        form.addSubview(descriptionText)
        print("Added description field.")

        
        let divisor2 = UILabel()
        divisor2.frame = CGRect(x: 7, y: descriptionText.frame.origin.y + descriptionText.frame.size.height + 1 , width: form.frame.size.width - 14, height: 1)
        divisor2.backgroundColor = UIColor.black
        form.addSubview(divisor2)
        
        // Brand Fields
        let brandTitle = UILabel()
        brandTitle.frame = CGRect(x: 7, y: divisor2.frame.origin.y + divisor2.frame.size.height + 7 , width: 300, height: 15)
        brandTitle.text = "Marca"
        brandTitle.textColor = AppCustomColor().lightGray
        form.addSubview(brandTitle)
        
        let brandText = UITextField()
        brandText.frame = CGRect(x: 7, y: brandTitle.frame.origin.y + brandTitle.frame.size.height + 7, width: form.frame.size.width-14, height: 25)
        brandText.textColor = AppCustomColor().pink
        brandText.font = UIFont(name: brandText.font!.fontName, size: CGFloat(20))
        brandText.addTarget(nil, action: #selector(DetailFullScreenImageViewController.firstResponderAction(_:)), for: .editingDidEndOnExit)
//        brandText.backgroundColor = UIColor.whiteColor()
        form.addSubview(brandText)
        print("Added brand field.")
        
        let divisor3 = UILabel()
        divisor3.frame = CGRect(x: 7, y: brandText.frame.origin.y + brandText.frame.size.height + 1 , width: form.frame.size.width - 14, height: 1)
        divisor3.backgroundColor = UIColor.black
        form.addSubview(divisor3)
        
        // Type Fields
        let typeTitle = UILabel()
        typeTitle.frame = CGRect(x: 7, y: divisor3.frame.origin.y + divisor3.frame.size.height + 7 , width: (form.frame.size.width/2)-14, height: 15)
        typeTitle.text = "Tipo da roupa"
        typeTitle.textColor = AppCustomColor().lightGray
        typeTitle.textAlignment = NSTextAlignment.center
        form.addSubview(typeTitle)
        
        let typeText = UILabel()
        typeText.frame = CGRect(x: 7, y: typeTitle.frame.origin.y + typeTitle.frame.size.height + 7, width: (form.frame.size.width/2)-14, height: 25)
        typeText.textColor = AppCustomColor().pink
        typeText.font = UIFont(name: typeText.font!.fontName, size: CGFloat(20))
        typeText.text = cloth.getType()
//        typeText.backgroundColor = UIColor.whiteColor()
        typeText.textAlignment = NSTextAlignment.center
        form.addSubview(typeText)
        print("Added type of cloth field.")
        
        // Price Fields
        let priceTitle = UILabel()
        priceTitle.frame = CGRect(x: form.frame.size.width/2, y: divisor3.frame.origin.y + divisor3.frame.size.height + 7 , width: (form.frame.size.width/2)-7, height: 15)
        priceTitle.text = "Preço (R$)"
        priceTitle.textColor = AppCustomColor().lightGray
        priceTitle.textAlignment = NSTextAlignment.center
        form.addSubview(priceTitle)
        
        let priceText = UITextField()
        priceText.frame = CGRect(x: form.frame.size.width/2, y: priceTitle.frame.origin.y + priceTitle.frame.size.height + 7, width: (form.frame.size.width/2)-7, height: 25)
        priceText.textColor = AppCustomColor().pink
        priceText.font = UIFont(name: typeText.font!.fontName, size: CGFloat(20))
        priceText.placeholder = "0"
        priceText.textAlignment = NSTextAlignment.center
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,target: priceText, action: #selector(UITextField.resignFirstResponder))
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        priceText.inputAccessoryView = toolbarDone
        priceText.keyboardType = .numberPad
        form.addSubview(priceText)
        print("Added price field.")
        
        // Image Fields
        let size = (form.frame.size.width - (5*5))/4
        
        let image1 = UIButton(type: UIButtonType.custom)
        image1.frame = CGRect(x: 5, y: priceText.frame.origin.y + priceText.frame.size.height + 10, width: size, height: size)
        image1.layer.cornerRadius = CGFloat(5)
        image1.layer.masksToBounds = true
        image1.contentMode = .scaleAspectFill
        image1.backgroundColor = UIColor.white
        image1.setImage(cloth.getImage(), for: UIControlState())
        image1.imageView?.contentMode = .scaleAspectFill
        image1.tag = 1
        form.addSubview(image1)
        print("Added container for picture 1.")
        
        let image2 = UIButton(type: UIButtonType.custom)
        image2.frame = CGRect(x: image1.frame.origin.x + image1.frame.size.width + 5, y: priceText.frame.origin.y + priceText.frame.size.height + 10, width: size, height: size)
        image2.layer.cornerRadius = CGFloat(5)
        image2.layer.masksToBounds = true
        image2.setBackgroundImage(UIImage(named: "shirtsIconAdd.png"), for: UIControlState())
        image2.backgroundColor = UIColor.white
        image2.imageView?.contentMode = .scaleAspectFill
        image2.addTarget(self, action: #selector(DetailFullScreenImageViewController.pictureClicked(_:)), for: UIControlEvents.touchUpInside)
        image2.tag = 2
        form.addSubview(image2)
        print("Added container for picture 2.")
        
        let image3 = UIButton(type: UIButtonType.custom)
        image3.frame = CGRect(x: image2.frame.origin.x + image2.frame.size.width + 5, y: priceText.frame.origin.y + priceText.frame.size.height + 10, width: size, height: size)
        image3.layer.cornerRadius = CGFloat(5)
        image3.layer.masksToBounds = true
        image3.setBackgroundImage(UIImage(named: "shirtsIconAdd.png"), for: UIControlState())
        image3.addTarget(self, action: #selector(DetailFullScreenImageViewController.pictureClicked(_:)), for: UIControlEvents.touchUpInside)
        image3.imageView?.contentMode = .scaleAspectFill
        image3.backgroundColor = UIColor.white
        image3.tag = 3
        form.addSubview(image3)
        print("Added container for picture 3.")
        
        let image4 = UIButton(type: UIButtonType.custom)
        image4.frame = CGRect(x: image3.frame.origin.x + image3.frame.size.width + 5, y: priceText.frame.origin.y + priceText.frame.size.height + 10, width: size, height: size)
        image4.layer.cornerRadius = CGFloat(5)
        image4.layer.masksToBounds = true
        image4.setBackgroundImage(UIImage(named: "shirtsIconAdd.png"), for: UIControlState())
        image4.addTarget(self, action: #selector(DetailFullScreenImageViewController.pictureClicked(_:)), for: UIControlEvents.touchUpInside)
        image4.imageView?.contentMode = .scaleAspectFill
        image4.backgroundColor = UIColor.white
        image4.tag = 4
        form.addSubview(image4)
        print("Added container for picture 4.")
        

        // Exchange Boolean Fields
        let exchangeTitle = UILabel()
        exchangeTitle.frame = CGRect(x: 7, y: image1.frame.origin.y + image1.frame.size.height + 14 , width: form.frame.size.width/3, height: 15)
        exchangeTitle.text = "Aceita Troca?"
        exchangeTitle.textColor = AppCustomColor().lightGray
        exchangeTitle.textAlignment = NSTextAlignment.left
        form.addSubview(exchangeTitle)
        
        let exchangeSwitch = UISwitch()
        exchangeSwitch.frame = CGRect(x: exchangeTitle.frame.origin.x  + exchangeTitle.frame.size.width + 7, y: exchangeTitle.frame.origin.y - 5, width: form.frame.size.width/3, height: 15)
        exchangeSwitch.setOn(false, animated: true)
        exchangeSwitch.backgroundColor = nil
        exchangeSwitch.thumbTintColor = AppCustomColor().pink
        exchangeSwitch.tintColor = AppCustomColor().lightGray
        exchangeSwitch.onTintColor = UIColor.green
        form.addSubview(exchangeSwitch)
        
        let saveAdButton = UIButton(type: UIButtonType.custom)
        saveAdButton.frame = CGRect(x: 7, y: exchangeSwitch.frame.origin.y + exchangeSwitch.frame.size.height + 15, width: (form.frame.size.width/2)-14, height: 35)
        saveAdButton.backgroundColor = AppCustomColor().lightGray
        saveAdButton.setTitle("Criar", for: UIControlState())
        saveAdButton.layer.cornerRadius = CGFloat(7)
        saveAdButton.layer.masksToBounds = true
        saveAdButton.addTarget(self, action: #selector(DetailFullScreenImageViewController.saveAd), for: UIControlEvents.touchUpInside)
        form.addSubview(saveAdButton)
        
        let cancelAdButton = UIButton(type: UIButtonType.custom)
        cancelAdButton.frame = CGRect(x: saveAdButton.frame.origin.x + saveAdButton.frame.width + 7, y: exchangeSwitch.frame.origin.y + exchangeSwitch.frame.size.height + 15, width: (form.frame.size.width/2)-14, height: 35)
        cancelAdButton.backgroundColor = AppCustomColor().lightGray
        cancelAdButton.setTitle("Cancelar", for: UIControlState())
        cancelAdButton.layer.cornerRadius = CGFloat(7)
        cancelAdButton.layer.masksToBounds = true
        cancelAdButton.addTarget(self, action: #selector(DetailFullScreenImageViewController.dismissAd), for: UIControlEvents.touchUpInside)
        form.addSubview(cancelAdButton)
        
        
        print("Created ad info array.")
        adInfo = [form,
                  nameText,
                  descriptionText,
                  brandText,
                  typeText,
                  priceText,
                  image1,
                  image2,
                  image3,
                  image4,
                  exchangeSwitch]
    
    }
    func dismissAd() {
        adInfo[0].removeFromSuperview()
        adInfo.removeAll()
        print("Ad creation dismissed.\n")
    }
    func saveAd() {
        print("Data from ad is being indexed...")
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        let PFStore = PFObject(className: "Store")
        let onwerIdText = adInfo[1] as! UITextField
        let descriptionText = adInfo[2] as! UITextField
        let brandText = adInfo[3] as! UITextField
        let typeText = adInfo[4] as! UILabel
        PFStore["ownerId"] = (PFUser.current()?.objectId)!
        PFStore["titleAd"] = onwerIdText.text
        PFStore["clothesId"] = cloth.getId()
        PFStore["descriptionAd"] = descriptionText.text
        PFStore["brand"] = brandText.text
        PFStore["type"] = typeText.text
        if adInfo[5].text == "" {
            PFStore["price"] = 0
        } else {
            PFStore["price"] = Int(adInfo[5].text)
        }
        PFStore["change"] = adInfo[10].isOn
        PFStore["ative"] = true
        PFStore["customers"] = []
        
        
        var name = adInfo[1] as! UITextField
        if name.text == "" {
            name.text = "Sem Nome"
        }
        if adInfo[6].imageView!!.image != nil {
            let imageData = UIImageJPEGRepresentation(adInfo[6].imageView!!.image!, CGFloat(0.5))
            let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
            PFStore["image1"] = imageFile
        }
        if adInfo[7].imageView!!.image != nil {
            let imageData = UIImageJPEGRepresentation(adInfo[7].imageView!!.image!, CGFloat(0.5))
            let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
            PFStore["image2"] = imageFile
        }
        if adInfo[8].imageView!!.image != nil {
            let imageData = UIImageJPEGRepresentation(adInfo[8].imageView!!.image!, CGFloat(0.5))
            let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
            PFStore["image3"] = imageFile
        }
        if adInfo[9].imageView!!.image != nil {
            let imageData = UIImageJPEGRepresentation(adInfo[9].imageView!!.image!, CGFloat(0.5))
            let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
            PFStore["image4"] = imageFile
        }
        print("Saving new ad to server...")
        PFStore.saveInBackground { (success, error) in
            if success {
                let adName = self.adInfo[1] as! UITextField
                print("Ad \(adName.text!) was succesfully saved.")
                if let user = PFUser.current() {
                    user.incrementKey("ads", byAmount: -1)
                    user.saveInBackground(block: { (success, error) in
                        if success {
                            print("User consumed one Ad.")
                        }
                    })
                }
                
                let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(UIScreen.main.bounds.width)*0.8)
                alert.showAnimationType = .SlideInFromBottom
                alert.backgroundType = .Blur
                alert.hideAnimationType = .SlideOutToBottom
                alert.showSuccess("Sucesso", subTitle: "Ad salvo com sucesso!", closeButtonTitle: "Ok.", duration: 0)
                self.dismissAd()
            } else {
                print("Ad was not saved because of error: \(error)")
            }
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
        
        
        
    }
    func firstResponderAction(_ textField: UITextField!) -> Bool {
        // To turn off keyboard
        self.view.endEditing(true)
        textField.resignFirstResponder()
        print("Keyboard Dismissed.")
        return true
    }
    func pictureClicked(_ sender: UIButton) {
        imageClicked = sender
        print("Container \(sender.tag) clicked.")
        print("Displaying options for user...")
        let alert = UIAlertController(title: "Adicionar Roupa",
                                      message: "Gostaria de adicionar uma roupa?",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let album = UIAlertAction(title: "Escolher do Album",
                                  style: UIAlertActionStyle.default,
                                  handler: { (getFromPhotoLibraryAction) -> Void in
                                    weak var weakSelfInClosure = self
                                    weakSelfInClosure!.takePictureFromPhotoLibrary()
                                    print("User will choose picture from album.")
        })
        let camera = UIAlertAction(title: "Tirar Foto",
                                   style: UIAlertActionStyle.default,
                                   handler: { (getFromPhotoLibraryAction) -> Void in
                                    weak var weakSelfInClosure = self
                                    weakSelfInClosure!.takeShot()
                                    print("User will take a picture.")
        })
        
        let remove = UIAlertAction(title: "Remover foto", style: UIAlertActionStyle.destructive, handler: { (getFromPhotoLibraryAction) -> Void in
            sender.setImage(nil, for: UIControlState())
            print("Picture \(sender.tag) removed from ad.")
        })
        
        let cancel = UIAlertAction(title: "Cancelar",
                                   style: UIAlertActionStyle.cancel,
                                   handler: { (cancelAction) -> Void in
                                print("User canceled action.")
        })
        
        album.setValue(UIImage(named: "getAlbum.png"), forKey: "image")
        camera.setValue(UIImage(named: "takeShot.png"), forKey: "image")
        
        alert.addAction(album)
        alert.addAction(camera)
        if (sender.imageView!.image?.size.width > 0 ) {
            alert.addAction(remove)
        }
        alert.addAction(cancel)
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
    func takeShot() {
        let cameraImage = UIImagePickerController()
        cameraImage.sourceType = UIImagePickerControllerSourceType.camera
        cameraImage.delegate = self
        cameraImage.allowsEditing = true
        cameraImage.showsCameraControls = true
        self.present(cameraImage, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageClicked.setImage(image, for: UIControlState())
        print("Added Image to container \(imageClicked.tag).")
        self.dismiss(animated: true, completion: nil)
        
    }

    
    
    
    
    
    // MARK: Collection View for Closets shown when user wants to move cloth to another closet.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myClosetsOptions.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let screenHeight = UIScreen.main.bounds.height
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        myClosetsImages[(indexPath as NSIndexPath).item].getDataInBackground { (data, error) -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    let image = UIImageView(image: downloadedImage)
                    image.frame.size.width = cell.frame.width
                    image.frame.size.height = cell.frame.height
                    cell.addSubview(image)
                }
            }
        
        let closetName = UILabel()
        closetName.frame.size.width = cell.frame.width*0.8
        closetName.frame.size.height = screenHeight*0.06
        closetName.frame.origin.x = cell.frame.width*0.1
        closetName.frame.origin.y = cell.frame.height*0.8
        closetName.text = myClosetsOptions[(indexPath as NSIndexPath).item].getName()
        closetName.textAlignment = NSTextAlignment.center
        closetName.numberOfLines = 0
        closetName.font = UIFont(name: (closetName.font?.fontName)!, size: CGFloat(8))
        cell.addSubview(closetName)
    
        cell.layer.cornerRadius = CGFloat(7)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let fromCloset = delegate?.getCurrentCloset() {
            let toCloset = myClosetsOptions[(indexPath as NSIndexPath).item]
            cloth.moveToCloset(fromCloset, toCloset: toCloset)
            for view in arrayViewsAlert {
                view.removeFromSuperview()
            }
            if let allClosets = delegate?.getMyClosets() {
                if let index = allClosets.index(where: { (Closet) -> Bool in
                    return Closet.getId() == toCloset.getId()
                }) {
                    delegate?.downloadClothesFromCurrentClosetIfNeeded()
                    delegate?.updateClothesThatWillBeShown()
                    delegate?.scrollToCloset(index)
                }
            }
            
            dismissViewControllerBackToClosets()
        }
    }
    
    
    
    func dismissViewControllerBackToClosets() {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        print("DetailFullScreenViewController has been deinitialized.")
    }
    

}





