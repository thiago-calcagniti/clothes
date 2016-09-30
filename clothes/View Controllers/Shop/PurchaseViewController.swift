//
//  PurchaseViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 02/09/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ViewOfferDelegate {

    var containerView = UIView()
    var offers = Array<Ad>()
    var offersViewer: UITableView!
    var skip: Int = 0
    
    override func viewDidLoad() {
        print("PURCHASE VIEW CONTROLLER IS BEING LOADED.")
        self.view.backgroundColor = nil
        createContainerView()
        createOffersViewer()
        downloadOffers()
        
        
    }
    
    
    func createContainerView() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let maximumHeight = screenHeight - (10 + screenHeight*0.05 + 10 + 100)
        containerView.frame = CGRect(x: 0, y: 5, width: screenWidth, height: maximumHeight)
        containerView.backgroundColor = nil
        self.view.addSubview(containerView)
        print("Created Container View.")
        
    }
    func createOffersViewer() {
        offersViewer = UITableView(frame: containerView.frame, style: UITableViewStyle.plain)
        offersViewer.delegate = self
        offersViewer.dataSource = self
        offersViewer.backgroundColor = nil
        offersViewer.separatorStyle = .none
        containerView.addSubview(offersViewer)
        print("Added tableview to visualize offers.")
    }
    func refreshOffers() {
        offersViewer.reloadData()
    }
    func downloadOffers() {
        print("Downloading Offers...")
        let adQuery = PFQuery(className: "Store")
        adQuery.whereKey("ative", equalTo: true)
        adQuery.whereKey("ownerId", notEqualTo: (PFUser.current()?.objectId)!)
        adQuery.findObjectsInBackground { (objects, error) in
            if let objects = objects {
                if self.skip < objects.count {
                    adQuery.limit = 7
                    adQuery.skip = self.skip
                    adQuery.findObjectsInBackground { (objects, error) in
                        if let objects = objects {
                            for object in objects {
                                let id = object.objectId!
                                let clothId = object["clothesId"] as! String
                                let ownerId = object["ownerId"] as! String
                                let title = object["titleAd"] as! String
                                let description = object["descriptionAd"] as! String
                                let brand = object["brand"] as! String
                                let type = object["type"] as! String
                                let exchange = object["change"] as! Bool
                                let price = object["price"] as! Int
                                let customers = object["customers"] as! [String]
                                let image1 = object["image1"] as! PFFile
                                let ad: Ad = Ad(id: "\(id)", clothId: clothId, ownerId: ownerId, title: title, description: description, brand: brand, type: type, exchange: exchange, price: price, customers: customers, imageFile1: image1)
                                self.offers.append(ad)
                                
                                image1.getDataInBackground(block: { (data, error) in
                                    if let _ = data {
                                        let image = UIImage(data: data!)!
                                        ad.setImage1(image)
                                        ad.setThumbnail()
                                        self.refreshOffers()
                                    }
                                })
                                
                                if let _ = object["image2"] {
                                    let image2 = object["image2"] as! PFFile
                                    image2.getDataInBackground(block: { (data, error) in
                                        if let _ = data {
                                            let image = UIImage(data: data!)!
                                            ad.setImage2(image)
                                        }
                                    })
                                }
                                
                                if let _ = object["image3"] {
                                    let image3 = object["image3"] as! PFFile
                                    image3.getDataInBackground(block: { (data, error) in
                                        if let _ = data {
                                            let image = UIImage(data: data!)!
                                            ad.setImage3(image)
                                        }
                                    })
                                }
                                
                                if let _ = object["image4"] {
                                    let image4 = object["image4"] as! PFFile
                                    image4.getDataInBackground(block: { (data, error) in
                                        if let _ = data {
                                            let image = UIImage(data: data!)!
                                            ad.setImage4(image)
                                        }
                                    })
                                }
                            }
                        }
                    }
                    self.skip = self.skip + 7
                    UIApplication.shared.endIgnoringInteractionEvents()
                } else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    print("All ads were downloaded.")
                    self.skip = -1
                }
                
            } else {
                print("No objects were found due to error: \(error)")
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    
    
    
    // MARK: UITableView Datasource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = OffersCell(style: UITableViewCellStyle.default, reuseIdentifier: "offerCell")
        cell.cover.image = offers[(indexPath as NSIndexPath).item].getThumbnail()
        cell.title.text = offers[(indexPath as NSIndexPath).item].getTitle()
        cell.subtitle.text = offers[(indexPath as NSIndexPath).item].getDescription()
        cell.exchange.text = "Troca: \(offers[(indexPath as NSIndexPath).item].changeAccepted())"
        cell.price.text = "R$ \(offers[(indexPath as NSIndexPath).item].getPrice()),00"
        cell.backgroundColor = nil
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height/6
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User wants to see ad \(offers[(indexPath as NSIndexPath).item].getTitle()).")
        viewOffer(offers[(indexPath as NSIndexPath).item])
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if skip > 0 {
            downloadOffers()
            offersViewer.reloadData()
        }
    }

    
    
    // MARK: View Offer
    func viewOffer(_ offer: Ad) {
        print("Entering ad \(offer.getTitle())")
        let destinationController = ViewOfferViewController(delegate: self, offer: offer)
        if let navigation = navigationController {
            navigation.pushViewController(destinationController, animated: true)
        }
    }

    
    deinit {
        self.containerView.removeFromSuperview()
        print("Purchase View Controller has been deinitialized.")
    }
    
}

// MARK: Custom MyAdsCell
class OffersCell: UITableViewCell {
    
    var body: UIImageView!
    var cover: UIImageView!
    var title: UILabel!
    var subtitle: UILabel!
    var exchange: UILabel!
    var price: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let cellWidth = screenWidth
        let cellHeight = screenHeight/6
        
        
        body = UIImageView()
        body.frame = CGRect(x: 7, y: 2, width: cellWidth-14, height: cellHeight-4)
        body.image = UIImage(named: "adBackground.png")
        body.alpha = CGFloat(0.9)
        body.layer.cornerRadius = CGFloat(7)
        body.layer.masksToBounds = true
        self.contentView.addSubview(body)
        
        
        cover = UIImageView()
        cover.frame = CGRect(x: 8,y: 8,width: body.frame.size.height-16, height: body.frame.size.height-16)
        cover.contentMode = .scaleAspectFill
        cover.backgroundColor = UIColor.white
        cover.layer.cornerRadius = CGFloat(4)
        cover.layer.masksToBounds = true
        body.addSubview(cover)
        
        
        title = UILabel()
        title.frame = CGRect(x: cover.frame.origin.x + cover.frame.size.width + 8, y: 8, width: screenWidth - (cover.frame.size.width + cover.frame.origin.x + 4), height: cellHeight/5)
        title.font = UIFont(name: "Klavika", size: CGFloat(20))
        title.textColor = UIColor.black
        body.addSubview(title)
        
        
        subtitle = UILabel()
        subtitle.frame = CGRect(x: title.frame.origin.x, y: title.frame.origin.y + title.frame.size.height, width: title.frame.size.width, height: 2*(cellHeight/5))
        subtitle.numberOfLines = 0
        subtitle.lineBreakMode = .byWordWrapping
        subtitle.font = UIFont(name: "Klavika", size: CGFloat(15))
        subtitle.textColor = AppCustomColor().lightGray
        body.addSubview(subtitle)
        
        
        exchange = UILabel()
        exchange.frame = CGRect(x: subtitle.frame.origin.x, y: cover.frame.origin.y + cover.frame.size.height - (cellHeight/5), width: 200, height: cellHeight/5)
        exchange.font = UIFont(name: "Klavika", size: CGFloat(10))
        exchange.textColor = UIColor.black
        body.addSubview(exchange)
        
        price = UILabel()
        price.frame = CGRect(x: body.frame.size.width - 150 - 8, y: body.frame.height - cellHeight/3, width: 150, height: cellHeight/3)
        price.font = UIFont(name: "Klavika", size: CGFloat(20))
        price.textColor = UIColor.white
        price.textAlignment = NSTextAlignment.right
        body.addSubview(price)
        
        
        
        
        
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}

