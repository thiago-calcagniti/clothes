//
//  Ad.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 07/09/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Ad {
    
    fileprivate var id: String!
    fileprivate var ownerId: String!
    fileprivate var title: String!
    fileprivate var description: String!
    fileprivate var brand: String!
    fileprivate var type: String!
    fileprivate var exchange: Bool!
    fileprivate var price: Int!
    fileprivate var clothId: String!
    fileprivate var customers: Array<String>!
    
    fileprivate var image1: UIImage!
    fileprivate var imageFile1: PFFile!
    fileprivate var thumbnail1: UIImage!
    
    fileprivate var image2: UIImage!
    fileprivate var imageFile2: PFFile!
    fileprivate var thumbnail2: UIImage!
    
    fileprivate var image3: UIImage!
    fileprivate var imageFile3: PFFile!
    fileprivate var thumbnail3: UIImage!
    
    fileprivate var image4: UIImage!
    fileprivate var imageFile4: PFFile!
    fileprivate var thumbnail4: UIImage!
    
    init(id: String, clothId: String, ownerId: String, title: String, description: String, brand: String, type: String, exchange: Bool, price: Int, customers: [String], imageFile1: PFFile) {
        self.id = id
        self.clothId = clothId
        self.ownerId = ownerId
        self.title = title
        self.description = description
        self.brand = brand
        self.type = type
        self.exchange = exchange
        self.price = price
        self.imageFile1 = imageFile1
        self.customers = customers
        print("Ad \(self.title) was born.")
    }
    
    
    // Setters
    func setTitle(_ title: String) {
        self.title = title
    }
    func setDescription(_ description: String) {
        self.description = description
    }
    func setBrand(_ brand: String) {
        self.brand = brand
    }
    func setType(_ type: String) {
        self.type = type
    }
    func setExchange(_ exchange: Bool) {
        self.exchange = exchange
    }
    func setPrice(_ price: Int) {
        self.price = price
    }
    func setClothId(_ clothId: String) {
        self.clothId = clothId
    }
    func setImage1(_ image: UIImage) {
        self.image1 = image
    }
    func setImage2(_ image: UIImage) {
        self.image2 = image
    }
    func setImage3(_ image: UIImage) {
        self.image3 = image
    }
    func setImage4(_ image: UIImage) {
        self.image4 = image
    }
    
    func setThumbnail() {
        if self.image1 != nil {
        let height = self.image1.size.height
        let width = self.image1.size.width
        let compress:CGFloat!
        
        if height < 700 {
            compress = CGFloat(5)
        } else if height < 1500 {
            compress = CGFloat(20)
        } else if height < 2500 {
            compress = CGFloat(30)
        } else {
            compress = CGFloat(40)
        }
        
        let newHeight = CGFloat(height/compress)
        let newWidth = CGFloat(width/compress)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, UIScreen.main.scale)
        image1.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        self.thumbnail1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        }
    }
    
    
    // Getters
    func getId() -> String {
        return self.id
    }
    func getOwnerId() -> String {
        return self.ownerId
    }
    func getTitle() -> String {
        return self.title
    }
    func getDescription() -> String {
        return self.description
    }
    func getBrand() -> String {
        return self.brand
    }
    func getType() -> String {
        return self.type
    }
    func getExchange() -> Bool {
        return self.exchange
    }
    func getPrice() -> Int {
        return self.price
    }
    func getCustomers() -> Array<String> {
        return self.customers
    }
    func changeAccepted() -> String {
        if self.exchange == true {
            return "Sim"
        } else {
            return "Não"
        }
    }
    func getImage1() -> UIImage {
        return self.image1
    }
    func getImage2() -> UIImage {
        if (self.image2 != nil) {
            return self.image2
        }
        else {
            return UIImage()
        }

    }
    func getImage3() -> UIImage {
        if (self.image3 != nil) {
            return self.image3
        }
        else {
            return UIImage(named: "shirtsIconAdd.png")!
        }
        
    }
    func getImage4() -> UIImage {
        if (self.image4 != nil) {
            return self.image4
        }
        else {
            return UIImage(named: "shirtsIconAdd.png")!
        }
        
    }
    func getThumbnail() -> UIImage {
        setThumbnail()
        if self.thumbnail1 != nil {
        return self.thumbnail1
        }
        else { return UIImage() }
    }
    
    
    // Functions
    func downloadImageFile(_ imageFile: PFFile) -> UIImage {
        var downloadedImage = UIImage()
        imageFile.getDataInBackground(block: { (data, error) -> Void in
            if let _ = data {
                downloadedImage = UIImage(data: data!)!
            }
        })
        return downloadedImage
    }
    func downloadImage1(_ closure:@escaping () -> Void) -> UIImage {
        if image1 == nil {
        var downloadedImage = UIImage()
        imageFile1.getDataInBackground(block: { (data, error) -> Void in
            if let _ = data {
                downloadedImage = UIImage(data: data!)!
                self.image1 = downloadedImage
                print("downloaded")
                closure()
            }
        })
        return downloadedImage
        } else {
            return self.image1
        }
    }




    deinit {
        print("Ad has been deinitialized.")
    }

}
