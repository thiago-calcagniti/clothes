//
//  EditAdViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 08/09/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
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


protocol EditAdDelegate {
    func refreshMyAds()
    func removeAdFromViewer(_ ad: Ad)
}

class EditAdViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var adInfo = [AnyObject]()
    var delegate: EditAdDelegate?
    var ad: Ad!
    var imageClicked = UIButton()
    var showingCustomers:Bool = false
    var container: UIView!
    
    // Initializers
    init(delegate: EditAdDelegate, ad: Ad) {
        self.delegate = delegate
        self.ad = ad
        super.init(nibName: "EditAdViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        print("\n\n\nEDITADVIEWCONTROLLER IS BEING LOADED.")
        createBackground()
        createRightBarButtons()
        createAd()
    }
    override func viewDidLayoutSubviews() {
        self.navigationItem.rightBarButtonItems![1].badgeValue = "\(ad.getCustomers().count)"
    }

    // MARK: Setup Screen
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
    func createRightBarButtons() {
        let deleteAdButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(EditAdViewController.areYouSureToDelete))
        let seeInterestedBuyersButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.bookmarks, target: self, action: #selector(EditAdViewController.seeInterestedBuyers))
        self.navigationItem.rightBarButtonItems = [deleteAdButton, seeInterestedBuyersButton]

    }
    func areYouSureToDelete() {
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(UIScreen.main.bounds.width*0.8))
        alert.showQuestion("Hum...", subTitle: "Gostaria de deletar o ad?", closeButtonTitle: "Não, foi sem querer!", duration: 0.0)
        let removeButton: SCLButton = alert.addButton("Sim eu quero remover", target: self, selector: #selector(EditAdViewController.deleteAd))
        removeButton.backgroundColor = UIColor.gray
    }
    func deleteAd() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        print("Searcing Ad in server...")
        let adQuery = PFQuery(className: "Store")
        adQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        adQuery.getObjectInBackground(withId: ad.getId()) { (object, error) in
            if let object = object {
                object.deleteInBackground(block: { (success, error) in
                    print("Deleting current Ad...")
                    if success {
                        print("Ad was deleted successfully.")
                        self.delegate?.removeAdFromViewer(self.ad)
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.dismissAd()
                    } else {
                        print("Ad couldn't be deleted due to error: \(error)")
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                })
            }
        }
    }
    func seeInterestedBuyers() {
        if ad.getCustomers().count > 0 {
            if !showingCustomers {
            showingCustomers = true
            print("Showing interested buyers in a list...")
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            container = UIView()
            container.frame = CGRect(x: screenWidth*0.05, y: screenWidth*0.1, width: screenWidth*0.9, height: screenHeight*0.8)
            container.backgroundColor = UIColor.white
            container.layer.cornerRadius = CGFloat(7)
            container.layer.masksToBounds = true
            self.view.addSubview(container)
            
            let viewCustomersLabel = UILabel()
            viewCustomersLabel.frame = CGRect(x: 0, y: 0, width: container.frame.width*0.7, height: container.frame.width*0.1)
            viewCustomersLabel.center.x = container.frame.width*0.5
            viewCustomersLabel.center.y = container.frame.width*0.07
            viewCustomersLabel.text = "Clientes interessados."
            viewCustomersLabel.textAlignment = .center
            viewCustomersLabel.numberOfLines = 0
            viewCustomersLabel.lineBreakMode = .byCharWrapping
            container.addSubview(viewCustomersLabel)
            
            let closeButton = UIButton(type: UIButtonType.custom)
            closeButton.frame = CGRect(x: 0, y: 0, width: container.frame.size.width*0.1, height: container.frame.size.width*0.1)
            closeButton.center.x = container.frame.width*0.92
            closeButton.center.y = container.frame.width*0.07
            closeButton.layer.cornerRadius = CGFloat(7)
            closeButton.layer.masksToBounds = true
            closeButton.setImage(UIImage(named: "closeButton.png" ), for: UIControlState())
            closeButton.imageView?.contentMode = .scaleAspectFit
            closeButton.addTarget(nil, action: #selector(EditAdViewController.removeCustomersList(_:)), for: UIControlEvents.touchUpInside)
            container.addSubview(closeButton)
            
            let tableView = UITableView()
            tableView.frame = CGRect(x: 0, y: closeButton.frame.height + container.frame.width*0.03, width: container.frame.width, height: container.frame.height - closeButton.frame.height - container.frame.width*0.05)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorColor = .none
            container.addSubview(tableView)
            } else {
                showingCustomers = false
                container.removeFromSuperview()
            }
        }

    }
    
    func removeCustomersList(_ sender: UIButton) {
        sender.superview?.removeFromSuperview()
    }
    
    
    // MARK: TableView DataSource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ad.getCustomers().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CustomersCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackground(withId: ad.getCustomers()[(indexPath as NSIndexPath).item], block: { (object, error) in
            if let user = object {
                print("Username from offer is \(user["nickname"]).")
                cell.name.text = user["nickname"] as? String
                cell.email.text = user["email"] as? String
                cell.phone.text = user["phoneNumber"] as? String
                let image = user["profilePicture"] as! PFFile
                image.getDataInBackground(block: { (data, error) in
                    if let _ = data {
                        cell.profilePicture.image = UIImage(data: data!)
                        
                    }
                })
            } else {
                print("Error: \(error)")
            }
        })
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight*0.1
    }
    

    
    // MARK: Create Ad Pop Up
    func createAd() {
        print("User wants to edit the ad.")
        print("Ad \(ad.getTitle()) is being displayed...")
        adInfo.removeAll()
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        print("Creating ad form...")
        let form = UIView()
        form.frame = CGRect(x: 5, y: 0, width: screenWidth-10, height: screenHeight-75)
        form.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.7))
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
        nameText.text = ad.getTitle()
        nameText.font = UIFont(name: nameText.font!.fontName, size: CGFloat(20))
        nameText.addTarget(nil, action: #selector(EditAdViewController.firstResponderAction(_:)), for: .editingDidEndOnExit)
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
        descriptionText.text = ad.getDescription()
        descriptionText.font = UIFont(name: descriptionText.font!.fontName, size: CGFloat(20))
        descriptionText.addTarget(nil, action: #selector(EditAdViewController.firstResponderAction(_:)), for: .editingDidEndOnExit)
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
        brandText.text = ad.getBrand()
        brandText.font = UIFont(name: brandText.font!.fontName, size: CGFloat(20))
        brandText.addTarget(nil, action: #selector(EditAdViewController.firstResponderAction(_:)), for: .editingDidEndOnExit)
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
        typeText.text = ad.getType()
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
        priceText.text = "\(ad.getPrice())"
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
        image1.setImage(ad.getImage1(), for: UIControlState())
        image1.imageView?.contentMode = .scaleAspectFill
        image1.tag = 1
        form.addSubview(image1)
        print("Added container for picture 1.")
        
        let image2 = UIButton(type: UIButtonType.custom)
        image2.frame = CGRect(x: image1.frame.origin.x + image1.frame.size.width + 5, y: priceText.frame.origin.y + priceText.frame.size.height + 10, width: size, height: size)
        image2.layer.cornerRadius = CGFloat(5)
        image2.layer.masksToBounds = true
        image2.setBackgroundImage(UIImage(named: "shirtsIconAdd.png"), for: UIControlState())
        image2.setImage(ad.getImage2(), for: UIControlState())
        image2.backgroundColor = UIColor.white
        image2.imageView?.contentMode = .scaleAspectFill
        image2.addTarget(self, action: #selector(EditAdViewController.pictureClicked(_:)), for: UIControlEvents.touchUpInside)
        image2.tag = 2
        form.addSubview(image2)
        print("Added container for picture 2.")
        
        let image3 = UIButton(type: UIButtonType.custom)
        image3.frame = CGRect(x: image2.frame.origin.x + image2.frame.size.width + 5, y: priceText.frame.origin.y + priceText.frame.size.height + 10, width: size, height: size)
        image3.layer.cornerRadius = CGFloat(5)
        image3.layer.masksToBounds = true
        image3.setBackgroundImage(UIImage(named: "shirtsIconAdd.png"), for: UIControlState())
        image3.setImage(ad.getImage3(), for: UIControlState())
        image3.addTarget(self, action: #selector(EditAdViewController.pictureClicked(_:)), for: UIControlEvents.touchUpInside)
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
        image4.setImage(ad.getImage4(), for: UIControlState())
        image4.addTarget(self, action: #selector(EditAdViewController.pictureClicked(_:)), for: UIControlEvents.touchUpInside)
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
        exchangeSwitch.setOn(ad.getExchange(), animated: true)
        exchangeSwitch.backgroundColor = nil
        exchangeSwitch.thumbTintColor = AppCustomColor().pink
        exchangeSwitch.tintColor = AppCustomColor().lightGray
        exchangeSwitch.onTintColor = UIColor.green
        form.addSubview(exchangeSwitch)
        
        let saveAdButton = UIButton(type: UIButtonType.custom)
        saveAdButton.frame = CGRect(x: 7, y: exchangeSwitch.frame.origin.y + exchangeSwitch.frame.size.height + 15, width: (form.frame.size.width/2)-14, height: 35)
        saveAdButton.backgroundColor = AppCustomColor().lightGray
        saveAdButton.setTitle("Salvar", for: UIControlState())
        saveAdButton.layer.cornerRadius = CGFloat(7)
        saveAdButton.layer.masksToBounds = true
        saveAdButton.addTarget(self, action: #selector(EditAdViewController.saveAd), for: UIControlEvents.touchUpInside)
        form.addSubview(saveAdButton)
        
        let cancelAdButton = UIButton(type: UIButtonType.custom)
        cancelAdButton.frame = CGRect(x: saveAdButton.frame.origin.x + saveAdButton.frame.width + 7, y: exchangeSwitch.frame.origin.y + exchangeSwitch.frame.size.height + 15, width: (form.frame.size.width/2)-14, height: 35)
        cancelAdButton.backgroundColor = AppCustomColor().lightGray
        cancelAdButton.setTitle("Cancelar", for: UIControlState())
        cancelAdButton.layer.cornerRadius = CGFloat(7)
        cancelAdButton.layer.masksToBounds = true
        cancelAdButton.addTarget(self, action: #selector(EditAdViewController.dismissAd), for: UIControlEvents.touchUpInside)
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
        print("Ad edition dismissed.\n")
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func saveAd() {
        print("Data from ad is being indexed...")
        UIApplication.shared.beginIgnoringInteractionEvents()
        let adQuery = PFQuery(className: "Store")
        adQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        adQuery.getObjectInBackground(withId: ad.getId()) { (object, error) in
            if let object = object {
                print("Ad \(self.ad.getTitle()) was found in server.")
                let titleAd = self.adInfo[1] as! UITextField
                let descriptionText = self.adInfo[2] as! UITextField
                let brandText = self.adInfo[3] as! UITextField
                let typeText = self.adInfo[4] as! UILabel
                object["titleAd"] = titleAd.text
                object["descriptionAd"] = descriptionText.text
                object["brand"] = brandText.text
                object["type"] = typeText.text
                if self.adInfo[5].text == "" {
                    object["price"] = 0
                } else {
                    object["price"] = Int(self.adInfo[5].text)
                }
                object["change"] = self.adInfo[10].isOn
                object["customers"] = []
        
                var name = self.adInfo[1] as! UITextField
                if name.text == "" {
                    name.text = "Sem Nome"
                }
                if self.adInfo[6].imageView!!.image?.size.width > 0 {
                    let imageData = UIImageJPEGRepresentation(self.adInfo[6].imageView!!.image!, CGFloat(0.5))
                    let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
                    object["image1"] = imageFile
                }
                if self.adInfo[7].imageView!!.image?.size.width > 0 {
                    let imageData = UIImageJPEGRepresentation(self.adInfo[7].imageView!!.image!, CGFloat(0.5))
                    let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
                    object["image2"] = imageFile
                }
                if self.adInfo[8].imageView!!.image?.size.width > 0 {
                    let imageData = UIImageJPEGRepresentation(self.adInfo[8].imageView!!.image!, CGFloat(0.5))
                    let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
                    object["image3"] = imageFile
                }
                if self.adInfo[9].imageView!!.image?.size.width > 0 {
                    let imageData = UIImageJPEGRepresentation(self.adInfo[9].imageView!!.image!, CGFloat(0.5))
                    let imageFile = PFFile(name: "\(name.text!).png", data: imageData!)
                    object["image4"] = imageFile
                }
                object.saveInBackground(block: { (success, error) in
                    if success {
                        print("Ad was sucessfully saved.")
                        self.ad.setTitle(self.adInfo[1].text)
                        self.ad.setDescription(self.adInfo[2].text)
                        self.ad.setBrand(self.adInfo[3].text)
                        self.ad.setType(self.adInfo[4].text)
                        self.ad.setPrice(Int(self.adInfo[5].text)!)
                        self.ad.setExchange(self.adInfo[10].isOn)
                        let name = self.adInfo[1] as! UITextField
                        if self.adInfo[6].imageView!!.image?.size.width > 0 {self.ad.setImage1(self.adInfo[6].imageView!!.image!)}
                        if self.adInfo[7].imageView!!.image?.size.width > 0 {self.ad.setImage2(self.adInfo[7].imageView!!.image!)}
                        if self.adInfo[8].imageView!!.image?.size.width > 0 {self.ad.setImage3(self.adInfo[8].imageView!!.image!)}
                        if self.adInfo[9].imageView!!.image?.size.width > 0 {self.ad.setImage4(self.adInfo[9].imageView!!.image!)}
                        
                        self.delegate?.refreshMyAds()
                        
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(UIScreen.main.bounds.width)*0.8)
                        alert.showAnimationType = .SlideInFromBottom
                        alert.backgroundType = .Blur
                        alert.hideAnimationType = .SlideOutToBottom
                        alert.showSuccess("Sucesso", subTitle: "Ad alterado com sucesso!", closeButtonTitle: "Ok.", duration: 0)
                        self.dismissAd()
                    }
                })
                
            } else {
                print("Coudn't find ad in server, error: \(error)")
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            
            
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
                                    self.takePictureFromPhotoLibrary()
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
            print("Image of container \(sender.tag) is \(sender.imageView!.image!)")
            sender.setImage(UIImage(), for: UIControlState())
            print("Picture from container \(sender.tag) removed from ad.")
            print("Image of container \(sender.tag) is now \(sender.imageView!.image!)")
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
    
    
    
    
    
    
    deinit {
        adInfo[0].removeFromSuperview()
        adInfo.removeAll()
        print("EditAdViewController has been deinitialized.")
    }

}


// MARK: Custom MyAdsCell
class CustomersCell: UITableViewCell {
    
    var profilePicture: UIImageView!
    var name: UILabel!
    var email: UILabel!
    var phone: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let cellWidth = screenWidth
        let cellHeight = screenHeight*0.1
        
        profilePicture = UIImageView()
        profilePicture.frame = CGRect(x: cellHeight*0.1, y: cellHeight*0.1, width: cellHeight*0.8, height: cellHeight*0.8)
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.layer.cornerRadius = CGFloat(profilePicture.frame.width/2)
        profilePicture.layer.masksToBounds = true
        self.contentView.addSubview(profilePicture)
        
        name = UILabel()
        name.frame = CGRect(x: profilePicture.frame.origin.x + profilePicture.frame.width + 2, y: profilePicture.frame.origin.y, width: cellWidth*0.7, height: cellHeight*0.8*0.33)
        name.textColor = UIColor.black
        self.contentView.addSubview(name)
        
        email = UILabel()
        email.frame = CGRect(x: profilePicture.frame.origin.x + profilePicture.frame.width + 2, y: name.frame.origin.y + name.frame.height, width: cellWidth*0.7, height: cellHeight*0.8*0.33)
        email.textColor = UIColor.black
        self.contentView.addSubview(email)
        
        phone = UILabel()
        phone.frame = CGRect(x: profilePicture.frame.origin.x + profilePicture.frame.width + 2, y: email.frame.origin.y + email.frame.height, width: cellWidth*0.7, height: cellHeight*0.8*0.33)
        phone.textColor = UIColor.black
        self.contentView.addSubview(phone)
        

    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}



