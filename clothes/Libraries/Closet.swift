//
//  Closet.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 27/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import Foundation
import UIKit
import Parse


class Closet {
    
    fileprivate let id: String
    fileprivate let ownerId: String
    fileprivate var name: String
    fileprivate var image: UIImage = UIImage()
    fileprivate var clothes = Array<Cloth>()
    fileprivate var stand = UIImage()
    fileprivate var capacity: Int = 0
    fileprivate var numberOfClothes: Int = 0
    fileprivate var loadedToScrollView: Bool = false
    fileprivate var clothesDownloaded: Bool = false
    
    init(id: String, ownerId: String ,name: String, capacity: Int, standImageName: String) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.capacity = capacity
        self.stand = UIImage(named: standImageName)!
    }
    init(id: String, ownerId:String, name: String, capacity: Int, numberOfClothes: Int) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.capacity = capacity
        self.numberOfClothes = numberOfClothes
    }
    
    // Setters
    func setImage(_ image:UIImage) {
        self.image = image
    }
    func setName(_ newName: String) {
        let closetQuery = PFQuery(className: "Closet")
        closetQuery.getObjectInBackground(withId: "\(self.id)") { (object, error) -> Void in
            if let object = object {
                object["name"] = "\(newName)"
                self.name = newName
                object.saveInBackground()
            }
        }
    }
    func setCapacity(_ newCapacity:Int) {
        let closetQuery = PFQuery(className: "Closet")
        closetQuery.getObjectInBackground(withId: "\(self.id)") { (object, error) -> Void in
            if let object = object {
                object["capacity"] = newCapacity
                self.capacity = newCapacity
                object.saveInBackground()
            }
        }
    }
    func setNumberOfClothes(_ numberOfClothes: Int) {
        self.numberOfClothes = numberOfClothes
    }
    func setLoadedToScrollView(_ status: Bool) {
        self.loadedToScrollView = status
    }
    func setClothesDownloaded(_ status: Bool) {
        self.clothesDownloaded = status
    }
    
    // Getters
    func getName() -> String {
        return self.name
    }
    func getId() -> String {
        return self.id  
    }
    func getOwnerId() -> String {
        return self.ownerId
    }
    func getImage() -> UIImage {
        return self.image
    }
    func getStandImage() -> UIImage {
        return self.stand
    }
    func getCapacity() -> Int {
        return self.capacity
    }
    func getNumberOfClothes() -> Int {
        return self.numberOfClothes
    }
    func getLoadedToScrollView() -> Bool {
        return self.loadedToScrollView
    }
    func getClothesDownloaded() -> Bool {
        return self.clothesDownloaded
    }
    func getCapacityByType(_ type: String) -> Int {
        var quantity = 0
        for cloth in self.clothes {
            if cloth.getType() == type {
                quantity = quantity + 1
            }
        }
        return quantity
    }
    func getClothesOfType(_ type: String) -> Array<Cloth> {
        var myClothes = Array<Cloth>()
        for cloth in self.clothes {
            if cloth.getType() == type {
                myClothes.append(cloth)
            }
        }
        return myClothes
    }
    func getClothes() -> Array<Cloth> {
        return self.clothes
    }
    func getTypes() -> Array<String> {
        var types:[String] = []
        for cloth in self.clothes {
            types.append(cloth.getType())
        }
        let unique = Array(Set(types))
        return unique
    }
    func getClothOfIdIsLoaded(_ clothId: String) -> Bool {
        for cloth in self.clothes {
            if cloth.getId() == clothId {
                if (cloth.getDownloaded()) {
                    return true
                }
            }
        }
        return false
    }
    func getClothPosition() {
        
    }
    

    
    // Actions
    func addCloth(_ cloth: Cloth) {
        if self.clothes.count < self.capacity {
            self.clothes.append(cloth)
            cloth.setClosetId(self.id)
        }
    }
    func moveClothPositionAtCloset(_ sourceIndex: Int, destinationIndex: Int) {
        let maxIndex = self.clothes.count - 1
        let cloth = self.clothes.remove(at: sourceIndex)
        if destinationIndex >= maxIndex {
            self.clothes.insert(cloth, at: maxIndex)
        } else {
            self.clothes.insert(cloth, at: destinationIndex)
        }
    }
    func removeCloth(_ cloth: Cloth) {
        if let position = self.clothes.index(where: { (Item) -> Bool in
            return Item.getId() == cloth.getId()
        }) {
            self.clothes.remove(at: position)
            print("Removed cloth \(cloth.getId()) from closet \(self.id)")
        }
    }
  
    

    deinit {
        for cloth in self.clothes {
            removeCloth(cloth)
        }
//        print("Closet \(self.name) was deinitialized.")
    }

}
