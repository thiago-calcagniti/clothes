//
//  ViewController4.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 25/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import UIKit
import Parse

class ViewController4: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {


    var fingerPath = UIBezierPath()
    var customLayer = CAShapeLayer()
    var imageView = UIImageView()
    var scrollImage = UIScrollView()
    
    var scrollX = CGFloat(0.0)
    var scrollY = CGFloat(0.0)
    
    override func viewDidLoad() {
        createMenuButton()
        
        let imageToBeCropped = UIImage(named: "jeansRemoveBack.jpeg")
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageToBeCropped!.size.width, height: imageToBeCropped!.size.height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageToBeCropped
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController4.createCustomCrop(_:)))
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.minimumPressDuration = 0.4
        
        scrollImage = UIScrollView()
        scrollImage.frame = UIScreen.main.bounds
        scrollImage.delegate = self
        scrollImage.contentSize = CGSize(width: imageView.bounds.width, height: imageView.bounds.height)
        scrollImage.panGestureRecognizer.require(toFail: longPressGesture)
        self.view.addSubview(scrollImage)
        

        
        scrollImage.addSubview(imageView)
        
        scrollImage.addGestureRecognizer(longPressGesture)
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Configurações"
        
        self.view.backgroundColor = UIColor.yellow
        self.edgesForExtendedLayout = UIRectEdge()
        
    }
    
    
    
    func createCustomCrop(_ gesture: UILongPressGestureRecognizer) {
        scrollImage.isScrollEnabled = false
        print("Start")
        switch gesture.state {
        case .began:
            print("Began")
            if let location:CGPoint = gesture.location(in: self.view) {
                fingerPath.lineWidth = 2.0
                customLayer.path = fingerPath.cgPath
                customLayer.fillColor = UIColor.white.withAlphaComponent(CGFloat(1)).cgColor
                self.view.layer.addSublayer(customLayer)
                
                fingerPath.move(to: location)
            }
            
            break
        case .changed:
            print("Changed")
            if let location: CGPoint = gesture.location(in: self.view) {
            fingerPath.addLine(to: location)
            customLayer.path = fingerPath.cgPath
            self.view.setNeedsDisplay()
        }
        
            
            break
        case .ended:
            print("Ended")
            
            fingerPath.close()
            
            let screenPath = UIBezierPath()
            screenPath.move(to: CGPoint(x: imageView.bounds.origin.x,y: imageView.bounds.origin.y))
            screenPath.addLine(to: CGPoint(x: imageView.bounds.origin.x, y: imageView.frame.maxY))
            screenPath.addLine(to: CGPoint(x: imageView.frame.maxX, y: imageView.frame.maxY))
            screenPath.addLine(to: CGPoint(x: imageView.frame.maxX, y: imageView.bounds.origin.y))
            screenPath.close()
            
            
            screenPath.apply(CGAffineTransform(translationX: -scrollX, y: -scrollY))
            
            screenPath.append(fingerPath)
            screenPath.usesEvenOddFillRule = true
            
            let context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            screenPath.addClip()
            UIColor.white.setFill()
            screenPath.fill()
            context?.restoreGState()
            
    
            
            
            
//            fingerPath.applyTransform(CGAffineTransformMakeTranslation(scrollX, scrollY))
            customLayer.path = screenPath.cgPath
            customLayer.fillColor = UIColor.white.cgColor
            
            //        let maskFromPath = shapeImageFromBezierPath(fingerPath, fillColor: UIColor.blackColor(), strokeColor: nil, strokeWidth: 0.0)
            //        self.view.addSubview(UIImageView(image: maskFromPath))
            
            //        imageView.image = maskedImage
            
            //        imageView.layer.mask = customLayer
            
            let newImage = imageView.image?.imageClipWithBezierPath(screenPath)
            imageView.image = newImage
            
            let cropped = PFObject(className: "cropped")
            let imageData = UIImagePNGRepresentation(imageView.image!)
            let imageFile = PFFile(name: "cropped", data: imageData!)
            cropped["image"] = imageFile
            cropped.saveInBackground()
            
            fingerPath.removeAllPoints()
            customLayer.removeFromSuperlayer()
            
            scrollImage.isScrollEnabled = true
            
            break
        default:
            scrollImage.isScrollEnabled = true
            break
        }
    }
    
    

   
    
    
    func shapeImageFromBezierPath (_ bezierPath: UIBezierPath, fillColor: UIColor?, strokeColor: UIColor?, strokeWidth: CGFloat) -> UIImage {
//        bezierPath.applyTransform(CGAffineTransformMakeTranslation(-bezierPath.bounds.origin.x, -bezierPath.bounds.origin.y))
        let size = CGSize(width: bezierPath.bounds.width, height: bezierPath.bounds.height)
        
        // Initialize Image Context with Bezier Path
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // Add Path
        context?.addPath(bezierPath.cgPath)
        
        // Set parameters and Draw
        if strokeColor != nil {
            strokeColor!.setStroke()
            context?.setLineWidth(strokeWidth)
        } else {
            UIColor.clear.setStroke()
        }
        
        fillColor?.setFill()
        context?.drawPath(using: .fillStroke)
        
        // Get Image from current image context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Restore context and Closet Everything
        context?.restoreGState()
        UIGraphicsEndImageContext()
        return image!
        
    }
    func maskImage(_ image: UIImage, maskImage: UIImage) -> UIImage {
        let imageReference = image.cgImage
        let maskReference = maskImage.cgImage
        
        let imageMask = CGImage(maskWidth: (maskReference?.width)!,
            height: (maskReference?.height)!,
            bitsPerComponent: (maskReference?.bitsPerComponent)!,
            bitsPerPixel: (maskReference?.bitsPerPixel)!,
            bytesPerRow: (maskReference?.bytesPerRow)!,
            provider: (maskReference?.dataProvider!)!, decode: nil, shouldInterpolate: true)
        
        
        let maskedImage = imageReference?.masking(imageMask!)
        let newImage = UIImage(cgImage: maskedImage!)
        
        UIGraphicsBeginImageContextWithOptions(newImage.size, false, 1.0)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        var renderedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        renderedImage = UIImage(data: UIImageJPEGRepresentation(renderedImage, 0.5)!)!
        
        return renderedImage
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollX = scrollImage.contentOffset.x
        scrollY = scrollImage.contentOffset.y
        print("X: \(scrollX), Y: \(scrollY)")
    }

    
    
    
    
    
    // MARK: Setup Navigation Items
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController4.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
    }
    func menuShow() {
        Window().showMenu()
    }

    

}

