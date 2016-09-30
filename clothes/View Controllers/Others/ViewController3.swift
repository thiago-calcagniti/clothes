//
//  ViewController3.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 25/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import UIKit
import Parse

class ViewController3: UIViewController {


    var imageView = UIImageView()
    
    
    override func viewDidLoad() {
        createMenuButton()
        
        self.view.backgroundColor = UIColor.blue
        
        
        let image = UIImage(named: "jeansRemoveBack.jpeg")
        
        imageView = UIImageView(frame: CGRect(x: 20, y: 80, width: 250, height: 450))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
               
        
//        let cropped = PFObject(className: "cropped")
//        let imageData = UIImagePNGRepresentation(modifiedImage)
//        let imageFile = PFFile(name: "cropped", data: imageData!)
//        cropped["image"] = imageFile
//        cropped.saveInBackground()
     
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Meus Malas"
    }
    
    
    func magicWand(_ image: UIImage, filterColor: UIColor) -> UIImage {
        let jpegImage = UIImageJPEGRepresentation(image,0.5)
        let convertImage = UIImage(data: jpegImage!)!.cgImage
        
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        let colors = filterColor.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        let iRed = CGFloat(fRed * 255.0)
        let iGreen = CGFloat(fGreen * 255.0)
        let iBlue = CGFloat(fBlue * 255.0)
        let iAlpha = CGFloat(fAlpha * 255.0)
        
        
        
        let colorMasking: [CGFloat] = [max((iRed*0.7),0), min((iRed*1.3),255),  max((iGreen*0.7),0), min((iGreen*1.3),255), max((iBlue*0.7),0), min((iBlue*1.3),255)]
        if let maskedImage: CGImage = convertImage?.copy(maskingColorComponents: colorMasking) {
        let newImage = UIImage(cgImage: maskedImage)
        
        
        UIGraphicsBeginImageContextWithOptions(newImage.size, false, 1.0)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        var renderedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
            
        renderedImage = UIImage(data: UIImageJPEGRepresentation(renderedImage, 0.5)!)!
        
        return renderedImage
        } else {
            return image
        }
        
    }
    
    

    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent!) {
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            let color: UIColor = colorOfPoint(location)

            print(color)
            let modifiedImage = magicWand(imageView.image!, filterColor: color)
            imageView.image = modifiedImage
            
  
        }
        super.touchesBegan(touches, with: event)
    }
    
    
    
    func colorOfPoint(_ point: CGPoint) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.translateBy(x: -point.x, y: -point.y)
        self.view.layer.render(in: context!)
        let color: UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deallocate(capacity: 4)
        return color
    }
    
    
    // MARK: Setup Navigation Items
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController3.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
    }
    func menuShow() {
        Window().showMenu()
    }

    
    
}
