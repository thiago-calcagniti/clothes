//
//  ViewOfferViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 10/09/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse
import MessageUI

protocol ViewOfferDelegate {
    
}

class ViewOfferViewController: UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {

    var offerInfo = [AnyObject]()
    var delegate: ViewOfferDelegate?
    var offer: Ad!
    
    
    // Initializers
    init(delegate: ViewOfferDelegate, offer: Ad) {
        self.delegate = delegate
        self.offer = offer
        super.init(nibName: "ViewOfferViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        print("\n\n\nVIEWOFFERVIEWCONTROLLER IS BEING LOADED...")
        createBackground()
        createOffer()
        

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
    
    // MARK: Create Offer
    func createOffer() {
        print("Offer \(offer.getTitle()) is being displayed...")
        offerInfo.removeAll()
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        print("Creating offer container...")
        let container = UIView()
        container.frame = CGRect(x: 5, y: 0, width: screenWidth-10, height: screenHeight-75)
        container.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.2))
        container.layer.cornerRadius = CGFloat(7)
        container.layer.masksToBounds = true
        self.view.addSubview(container)
        offerInfo.append(container)
        
        let body = UIImageView()
        body.frame = container.frame
        body.image = UIImage(named: "adBackground.png")
        body.alpha = CGFloat(0.6)
        body.contentMode = .scaleToFill
        container.addSubview(body)
        
        // Closets Scroll View
        let offersScrollView = UIScrollView()
        offersScrollView.delegate = self
        offersScrollView.isPagingEnabled = true
        offersScrollView.clipsToBounds = true
        offersScrollView.showsHorizontalScrollIndicator = false
        offersScrollView.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.9))
        offersScrollView.layer.cornerRadius = CGFloat(7)
        offersScrollView.layer.masksToBounds = true
        offersScrollView.frame = CGRect(x: container.frame.size.width*0.02, y: container.frame.size.width*0.02, width: container.frame.size.width*0.96, height: container.frame.size.height*0.4)
        offersScrollView.center.x = container.frame.size.width/2
        let pagesScrollViewSize = offersScrollView.frame.size
        offersScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(4), height: pagesScrollViewSize.height)
        container.addSubview(offersScrollView)
        print("Offer Scroll View added to container.")

        
        // Populate with clothes
        var images = [UIImage]()
        images.append(offer.getImage1())
        images.append(offer.getImage2())
        images.append(offer.getImage3())
        images.append(offer.getImage4())
        
        for image in images {
            if image.size.width == 0 {
                images.remove(at: images.index(of: image)!)
            }
            print("Offer has \(images.count) images.")
        }
        
        for i in 0...(images.count-1) {
            var frame = offersScrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(i)
            frame.origin.y = UIScreen.main.bounds.height*(0.04)
            frame.size.height = offersScrollView.frame.size.height*0.85
            
            let newPageView = UIImageView(image: images[i])
            newPageView.contentMode = .scaleAspectFit
            newPageView.frame = frame
            newPageView.tag = i
            offersScrollView.addSubview(newPageView)
        }
        
        // Info of the offer
        let title = UILabel()
        title.frame = CGRect(x: container.frame.size.width*0.02, y: container.frame.size.width*0.02 + offersScrollView.frame.size.height + offersScrollView.frame.origin.y, width: container.frame.size.width*0.96, height: container.frame.size.height*0.05)
        title.textColor = UIColor.black
        title.text = offer.getTitle()
        title.font = UIFont(name: "Klavika", size: CGFloat(25))
        container.addSubview(title)
        
        let description = UILabel()
        description.frame = CGRect(x: container.frame.size.width*0.02, y: title.frame.size.height + title.frame.origin.y, width: container.frame.size.width*0.96, height: container.frame.size.height*0.05)
        description.textColor = UIColor.black
        description.text = offer.getDescription()
        description.font = UIFont(name: "Klavika", size: CGFloat(20))
        container.addSubview(description)
        
        let brand = UILabel()
        brand.frame = CGRect(x: container.frame.size.width*0.02, y: description.frame.size.height + description.frame.origin.y, width: container.frame.size.width*0.96, height: container.frame.size.height*0.05)
        brand.textColor = UIColor.black
        brand.text = offer.getBrand()
        brand.font = UIFont(name: "Klavika", size: CGFloat(20))
        container.addSubview(brand)
        
        let exchange = UILabel()
        exchange.frame = CGRect(x: container.frame.size.width*0.02, y: container.frame.size.width*0.02 + brand.frame.size.height + brand.frame.origin.y, width: container.frame.size.width*0.96, height: container.frame.size.height*0.05)
        exchange.textColor = UIColor.white
        var accept = ""
        if offer.getExchange() {
            accept = "Sim"
        } else {
            accept = "Não"
        }
        exchange.text = "Aceita troca?: \(accept)"
        exchange.font = UIFont(name: "Klavika", size: CGFloat(20))
        container.addSubview(exchange)
        
        let price = UILabel()
        price.frame = CGRect(x: container.frame.size.width*0.02, y: exchange.frame.size.height + exchange.frame.origin.y, width: container.frame.size.width*0.96, height: container.frame.size.height*0.06)
        price.textColor = UIColor.white
        price.text = "R$ \(offer.getPrice()),00"
        price.font = UIFont(name: "Klavika", size: CGFloat(25))
        container.addSubview(price)
        
        let purchaseButton = UIButton(type: UIButtonType.custom)
        purchaseButton.frame = CGRect(x: 0, y: container.frame.size.width*0.04 + price.frame.origin.y + price.frame.size.height, width: container.frame.size.width*0.6, height: container.frame.size.height*0.1)
        purchaseButton.center.x = CGFloat(container.frame.size.width/2)
        purchaseButton.layer.cornerRadius = CGFloat(5)
        purchaseButton.backgroundColor = AppCustomColor().lightGray
        purchaseButton.setTitle("QUERO COMPRAR", for: UIControlState())
        purchaseButton.addTarget(nil, action: #selector(ViewOfferViewController.showSellerInfo), for: UIControlEvents.touchUpInside)
        container.addSubview(purchaseButton)
        offerInfo.append(purchaseButton)
        
    }
    func showSellerInfo() {
        
        let adQuery = PFQuery(className: "Store")
        adQuery.getObjectInBackground(withId: offer.getId()) { (object, error) in
            if let object = object {
                object.addUniqueObject("\((PFUser.current()!.objectId)!)", forKey: "customers")
                object.saveInBackground()
                print("Added current user as interested buyer.")
            }
        }
        
        
        let sellerPicture = UIImageView()
        sellerPicture.frame = CGRect(x: offerInfo[0].frame.size.width*0.02, y: offerInfo[1].frame.origin.y, width: offerInfo[0].frame.size.width*0.25, height: offerInfo[0].frame.size.width*0.25)
        sellerPicture.backgroundColor = UIColor.blue
        sellerPicture.layer.cornerRadius = CGFloat(sellerPicture.frame.size.width/2)
        sellerPicture.layer.masksToBounds = true
        sellerPicture.layer.borderWidth = CGFloat(2)
        sellerPicture.layer.borderColor = AppCustomColor().pink.cgColor
        sellerPicture.contentMode = .scaleAspectFill
        offerInfo[0].addSubview(sellerPicture)
        
        let sellerName = UILabel()
        sellerName.frame = CGRect(x: sellerPicture.frame.origin.x + sellerPicture.frame.size.width + offerInfo[0].frame.size.width*0.02, y: sellerPicture.frame.origin.y, width: offerInfo[0].frame.size.width - sellerPicture.frame.size.width, height: sellerPicture.frame.height*0.3)
        sellerName.text = "Carregando Nome..."
        sellerName.textColor = UIColor.black
        sellerName.font = UIFont(name: "Klavika", size: CGFloat(25))
        offerInfo[0].addSubview(sellerName)

        let sellerEmail = UILabel()
        sellerEmail.frame = CGRect(x: sellerPicture.frame.origin.x + sellerPicture.frame.size.width + offerInfo[0].frame.size.width*0.02, y: sellerName.frame.origin.y + sellerName.frame.size.height, width: offerInfo[0].frame.size.width - sellerPicture.frame.size.width, height: sellerPicture.frame.height*0.35)
        sellerEmail.text = "Carregando Email..."
        sellerEmail.numberOfLines = 0
        sellerEmail.lineBreakMode = .byWordWrapping
        sellerEmail.textColor = UIColor.blue
        sellerEmail.font = UIFont(name: "Klavika", size: CGFloat(15))
        offerInfo[0].addSubview(sellerEmail)
        
        let sellerPhone = UILabel()
        sellerPhone.frame = CGRect(x: sellerPicture.frame.origin.x + sellerPicture.frame.size.width + offerInfo[0].frame.size.width*0.02, y: sellerEmail.frame.origin.y + sellerEmail.frame.size.height, width: offerInfo[0].frame.size.width - sellerPicture.frame.size.width, height: sellerPicture.frame.height*0.30)
        sellerPhone.text = "Carregando Telefone..."
        sellerPhone.textColor = UIColor.blue
        sellerPhone.font = UIFont(name: "Klavika", size: CGFloat(25))
        offerInfo[0].addSubview(sellerPhone)
        
        print("Donwloading information from seller of offer...")
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackground(withId: offer.getOwnerId(), block: { (object, error) in
        if let user = object {
                print("Username from offer is \(user["nickname"]).")
                sellerName.text = user["nickname"] as? String
                sellerEmail.text = user["email"] as? String
                sellerPhone.text = user["phoneNumber"] as? String
                self.offerInfo.append(sellerName.text! as AnyObject)
                self.offerInfo.append(sellerEmail.text! as AnyObject)
                let image = user["profilePicture"] as! PFFile
                image.getDataInBackground(block: { (data, error) in
                    if let _ = data {
                        sellerPicture.image = UIImage(data: data!)
                        
                    }
                })
            } else {
                print("Error: \(error)")
            }
        })
        
        
        let sendMailButton = UIButton(type: UIButtonType.custom)
        sendMailButton.frame = CGRect(x: sellerPicture.frame.origin.x, y: sellerPicture.frame.origin.y + sellerPicture.frame.size.height + sellerPicture.frame.origin.x , width: (offerInfo[0].frame.size.width/2)*0.9, height: offerInfo[0].frame.size.height*0.08)
        sendMailButton.layer.cornerRadius = CGFloat(5)
        sendMailButton.backgroundColor = AppCustomColor().lightGray
        sendMailButton.setTitle("ENVIE UM EMAIL", for: UIControlState())
        sendMailButton.titleLabel?.font = UIFont(name: "Klavika", size: CGFloat(15))
        sendMailButton.titleLabel?.numberOfLines = 1
        sendMailButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendMailButton.titleLabel?.textAlignment = .center
        sendMailButton.titleLabel?.lineBreakMode = .byWordWrapping
        sendMailButton.addTarget(nil, action: #selector(ViewOfferViewController.sendEmail), for: UIControlEvents.touchUpInside)
        offerInfo[0].addSubview(sendMailButton)
        
        let sendWatsButton = UIButton(type: UIButtonType.custom)
        sendWatsButton.frame = CGRect(x: offerInfo[0].frame.width/2 + sellerPicture.frame.origin.x , y: sellerPicture.frame.origin.y + sellerPicture.frame.size.height + sellerPicture.frame.origin.x , width: (offerInfo[0].frame.size.width/2)*0.9, height: sendMailButton.frame.size.height)
        sendWatsButton.layer.cornerRadius = CGFloat(5)
        sendWatsButton.backgroundColor = AppCustomColor().lightGray
        sendWatsButton.setTitle("ENVIE UM WHATS", for: UIControlState())
        sendWatsButton.titleLabel?.font = UIFont(name: "Klavika", size: CGFloat(15))
        sendWatsButton.titleLabel?.numberOfLines = 1
        sendWatsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendWatsButton.titleLabel?.textAlignment = .center
        sendWatsButton.titleLabel?.lineBreakMode = .byWordWrapping
        sendWatsButton.addTarget(nil, action: #selector(ViewOfferViewController.sendWats), for: .touchUpInside)
        offerInfo[0].addSubview(sendWatsButton)
        
        print("Showing seller info...")
        offerInfo[1].removeFromSuperview()
        offerInfo.remove(at: 1)
    }
    func sendEmail() {
        print("Invoking mail windown...")
        if MFMailComposeViewController.canSendMail() {
            
            let senderName = PFUser.current()?["nickname"] as! String
            let senderEmail = PFUser.current()?["email"] as! String
            let senderPhone = PFUser.current()?["phoneNumber"] as! String
            let sellerName = offerInfo[1] as! String
            let sellerEmail = offerInfo[2] as! String
    
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["\(sellerEmail)"])
            mail.setSubject("+CLOTHES: Interesse na compra de \(offer.getTitle()).")
            mail.setMessageBody("<p>Olá \(sellerName) tudo bem?</p>Tenho interesse em comprar o sua roupa \(offer.getTitle()).<br/>Podemos conversar?<br/>Aguardo seu retorno obrigado.<br/>Atenciosamente,<br/><br/>\(senderName)<br/>\(senderEmail)<br/>\(senderPhone)<br/><br/><br/><br/><br/><br/><br/>", isHTML: true)
            mail.addAttachmentData(UIImageJPEGRepresentation(offer.getThumbnail(), CGFloat(1.0))!, mimeType: "image/jpeg", fileName:  "\(offer.getTitle()).jpeg")
            
            
            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func sendWats() {
        let urlString = "Sending WhatsApp message through app in Swift"
        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url  = URL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Message", message: "Your device is not able to send WhatsApp messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
            
        
    }
    
    
    



    
    
    
    deinit {
        offerInfo.removeAll()
        print("ViewOfferViewController has been deinitialized.")
    }
}
