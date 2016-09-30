//
//  Cloth.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 29/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import Foundation
import UIKit
import Parse


class Cloth {
    
    // General
    fileprivate var id: String = ""
    fileprivate var name: String!
    fileprivate var type: String!
    fileprivate var image: UIImage = UIImage()
    fileprivate var thumbnail: UIImage = UIImage()
    fileprivate var parseFile: PFFile?
    fileprivate var ownerId: String = ""
    fileprivate var closetId: String = ""
    fileprivate var occasions: [String] = []
    fileprivate var downloaded: Bool = false

    
    
    
    // Initializers
    init () {
        self.name = "Empty"
        self.type = "Indefinido"
        self.image = UIImage()
    }
    
    init (id: String, name: String) {
        self.id = id
        self.name = name
        self.type = "Indefinido"
    }
    
    init (id: String, name: String, ownerId: String) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.type = "Indefinido"
    }
    
    init (name: String, type: String, imageName: String) {
        self.name = name
        self.type = type
        self.image = UIImage(named: imageName)!
    }
    
    init (name: String, type: String, image: UIImage) {
        self.name = name
        self.type = type
        self.image = image
    }
    
    init (id: String, name: String, type: String, ownerId: String) {
        self.id = id
        self.name = name
        self.type = type
        self.ownerId = ownerId
        self.setOccasions(id)
    }
    
    
    init (id: String, name: String, type: String, ownerId: String, parseFile: PFFile) {
        self.id = id
        self.name = name
        self.type = type
        self.ownerId = ownerId
        self.setOccasions(id)
        self.parseFile = parseFile
    }
    
    
    // Setters
    func setClosetId(_ closetId: String) {
        let clothQuery = PFQuery(className: "Clothes")
        clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothQuery.getObjectInBackground(withId: self.id) { (object, error) -> Void in
            if error != nil {
                print(error)
            } else if let object = object {
                object["parentCloset"] = closetId
                object.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        self.closetId = closetId
                    }
                })
                
            }
        }
        
    }
    func setId(_ clothId: String) {
        self.id = clothId
    }
    func setName(_ newName: String) {
        self.name = newName
        let clothQuery = PFQuery(className: "Clothes")
        clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothQuery.getObjectInBackground(withId: self.id) { (object, error) -> Void in
            if error != nil {
                print("Ao tentar mudar o nome, o erro obtido foi \(error)")
            } else if let object = object {
                object["name"] = newName
                object.saveInBackground()
                self.name = newName
                
            }
        }
    }
    func setType(_ type: String) {
        self.type = type
        let clothQuery = PFQuery(className: "Clothes")
        clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothQuery.getObjectInBackground(withId: self.id) { (object, error) -> Void in
            if error != nil {
                print(" Id da roupa: \(self.id) e o erro foi \(error)")
            } else if let object = object {
                object["type"] = "\(type)"
                object.saveInBackground()
            }
        }
        
    }
    func setImage(_ image: UIImage) {
        self.image = image
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
        self.thumbnail = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }

    func setDownloaded(_ status: Bool) {
        self.downloaded = status
    }
    func setOwnerId(_ ownerId: String) {
        self.ownerId = ownerId
    }
    func setOccasions(_ clothId: String) {
        let clothQuery = PFQuery(className: "Clothes")
        clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothQuery.getObjectInBackground(withId: clothId) { (object, error) -> Void in
            if error != nil {
                print(error)
            } else if let object = object {
                let clothOccasions = object["occasions"]
                if clothOccasions != nil {
                self.occasions = clothOccasions as! [String]
                }
            }
        }
    }
    
    
    

    
    
    
    
    // Getters
    func getName() -> String {
        return self.name
    }
    func getType() -> String {
        return self.type
    }
    func getImage() -> UIImage {
        return self.image
    }
    func getThumbnail() -> UIImage {
        return self.thumbnail
    }
    func getImageWithPFFile() {
        if let parseFile: PFFile = self.parseFile {
            parseFile.getDataInBackground(block: { (data, error) -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    self.image = downloadedImage
                    self.downloaded = true
                }
            })
        }
    }
    func getClosetId() -> String {
        return self.closetId
    }
    func getId() -> String {
        return self.id
    }
    func getOccasions() -> [String] {
        return self.occasions
    }
    func getDownloaded() -> Bool {
        return self.downloaded
    }
    func getOwnerId() -> String {
        return self.ownerId
    }
    func hasOccasion(_ occasion: String) -> String {
        for object in self.occasions {
            if object == occasion {
                return occasion
            }
        }
        return ""
    }
    
    // Actions
    func addToCloset(_ closet: Closet) {
        closet.addCloth(self)
    }
    func moveToCloset(_ fromCloset: Closet, toCloset: Closet) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let fromClosetId = fromCloset.getId()
        let toClosetId = toCloset.getId()
        let clothQuery = PFQuery(className: "Clothes")
        clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothQuery.getObjectInBackground(withId: self.id) { (object, error) -> Void in
            if error != nil {
                print(error)
                UIApplication.shared.endIgnoringInteractionEvents()
            } else if let object = object {
                object["parentCloset"] = toClosetId
                object.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        fromCloset.removeCloth(self)
                        if toCloset.getClothesDownloaded() {
                            toCloset.addCloth(self)
                        }

                        let windowWidth = UIScreen.main.bounds.width*0.8
                        let closeButtonTitles: Array<String> = ["Que ótimo!", "Perfeito!", "Adorei!"]
                        var closeButtonTitle = closeButtonTitles[Int(arc4random_uniform(UInt32(closeButtonTitles.count)))]
                        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(windowWidth))
                        alert.showSuccess("Roupa Transferida", subTitle: "Roupa movida do \(fromCloset.getName()) para \(toCloset.getName()) com sucesso!", closeButtonTitle: closeButtonTitle, duration: 3.0)
                        UIApplication.shared.endIgnoringInteractionEvents()
                    } else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                })
            }
        }
        
        

    }
    func addOccasion(_ occasion: String) {
        let clothQuery = PFQuery(className: "Clothes")
        clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothQuery.getObjectInBackground(withId: self.id) { (object, error) -> Void in
            if error != nil {
                print(error)
            } else if let object = object {
                object.addUniqueObjects(from: [occasion], forKey: "occasions")
                object.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        self.occasions.append(occasion)
                    }
                })
                
            }
        }
        
    }
    func removeOccasion(_ occasion: String) {
        if let position = occasions.index(where: { (Item) -> Bool in
            return Item == occasion
        }) {
            let clothQuery = PFQuery(className: "Clothes")
            clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
            clothQuery.getObjectInBackground(withId: self.id, block: { (object, error) -> Void in
                if error != nil {
                    print(error)
                } else if let object = object {
                    object.remove(occasion, forKey: "occasions")
                    object.saveInBackground(block: { (success, error) -> Void in
                        if success {
                            self.occasions.remove(at: position)
                        }
                    })
                    
                }
            })
            
        }

    }
    
    
    
    
    
    // For usage in looks
    
    fileprivate var look: String = "Empty"
    fileprivate var width = CGFloat(100)
    fileprivate var height = CGFloat(100)
    fileprivate var centerInX = CGFloat(0.0)
    fileprivate var centerInY = CGFloat(0.0)
    fileprivate var rotation = CGFloat(0.0)
    fileprivate var lookString = [String]()
    
    func setWidth(_ newWidth: CGFloat) {
        self.width = newWidth
        self.setLookString()
    }
    func setHeight(_ newHeight: CGFloat) {
        self.height = newHeight
        self.setLookString()
    }
    func setCenterInX(_ newCenterX: CGFloat) {
        self.centerInX = newCenterX
        self.setLookString()
    }
    func setCenterInY(_ newCenterY: CGFloat) {
        self.centerInY = newCenterY
        self.setLookString()
    }
    func setRotation(_ newRotation: CGFloat) {
        self.rotation = newRotation
        self.setLookString()
    }
    func setLookString() {
        lookString = [self.id,
                      "\(self.width)",
                      "\(self.height)",
                      "\(self.centerInX)",
                      "\(self.centerInY)",
                      "\(self.rotation)"]
    }
    
    func getWidth() -> CGFloat {
        return self.width
    }
    func getHeight() -> CGFloat {
        return self.height
    }
    func getCenterInX() -> CGFloat {
        return self.centerInX
    }
    func getCenterInY() -> CGFloat {
        return self.centerInY
    }
    func getRotation() -> CGFloat {
        return self.rotation
    }
    func getLookString() -> [String] {
        return self.lookString
    }

    func getCoordinatesStringFromLook(_ looksCoordinates:[String]) -> [String] {
        print("Getting coordinates from \(self.name)... \n\(looksCoordinates)...\n")
        if looksCoordinates[0] == (self.id){
            self.width = CGFloat(Double(looksCoordinates[1])!)
            self.height = CGFloat(Double(looksCoordinates[2])!)
            self.centerInX = CGFloat(Double(looksCoordinates[3])!)
            self.centerInY = CGFloat(Double(looksCoordinates[4])!)
            self.rotation = CGFloat(Double(looksCoordinates[5])!)
            self.setLookString()
        }
        
        
        return self.lookString
    }
    
    
    deinit {
//        print("Cloth \(self.name) was deinitialized.")
    }
    
    
}
