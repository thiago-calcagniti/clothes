//
//  Look.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 16/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Look {
    fileprivate var id: String!
    fileprivate var ownerId: String!
    fileprivate var name: String!
    fileprivate var image: UIImage!
    fileprivate var thumbnail: UIImage! = UIImage()
    fileprivate var parseFile: PFFile?
    fileprivate var clothesId = [String]()
    fileprivate var clothes = Array<Cloth>()
    fileprivate var clothesCoordinates = Array<Array<String>>()
    fileprivate var downloaded:Bool = false

    
    init(id: String, name: String, ownerId: String, clothesId: [String]) {
        self.id = id
        self.name = name
        self.clothesId = clothesId
        self.ownerId = ownerId
    }
    
    init(id: String, name: String, ownerId: String, clothesId: [String], parseFile:PFFile) {
        self.id = id
        self.name = name
        self.clothesId = clothesId
        self.ownerId = ownerId
        self.parseFile = parseFile
    }
    
    // Setters
    func setId(_ newId: String) {
        self.id = newId
    }
    func setImage(_ newImage: UIImage) {
        self.image = newImage
        setThumbnail()
    }
    func setThumbnail() {
        let height = self.image.size.height
        let width = self.image.size.width
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
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        self.thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    func setClothesCoordinates(_ clothesCoordinates:[[String]]){
        self.clothesCoordinates = clothesCoordinates
    }
    func setName(_ newName: String) {
        self.name = newName
    }
    
    
    // Getters
    func getId() -> String {
        return self.id
    }
    func getImage() -> UIImage {
        return self.image
    }
    func getThumbnail() -> UIImage {
        return self.thumbnail
    }
    func getImageWithPFFile(_ completion: @escaping (_ success:Bool) -> Void ) {
        if let parseFile: PFFile = self.parseFile {
            parseFile.getDataInBackground(block: { (data, error) -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    self.setImage(downloadedImage)
                    self.downloaded = true
                    completion(self.downloaded)
                }
            })
        }
    }
    func getOwnerId() -> String {
        return self.ownerId
    }
    func getName() -> String {
        return self.name
    }
    func getClothes() -> [Cloth] {
        return self.clothes
    }
    func getClothesId() -> [String] {
        return self.clothesId
    }
    func getClothesCoordinates(_ indexOfCloth: Int) -> [String] {
        return self.clothesCoordinates[indexOfCloth]
    }
    func getDownloaded() -> Bool {
        return self.downloaded
    }
    
    
    // Actions
    func addCloth(_ cloth: Cloth) {
        self.clothes.append(cloth)
    }
    
    func removeCloth(_ cloth: Cloth) {
        if let index = self.clothes.index (where: {(Cloth) -> Bool in
            return Cloth.getId() == cloth.getId()
        })  {
            self.clothes.remove(at: index)
        }
        
    }

    
    
}
