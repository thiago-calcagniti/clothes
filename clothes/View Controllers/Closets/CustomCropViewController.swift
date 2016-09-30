//
//  CustomCropViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 29/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

class CustomCropViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    var fingerPath = UIBezierPath()
    var customLayer = CAShapeLayer()
    var imageView = UIImageView()
    var scrollImage = UIScrollView()
    var cutProcess: Bool = false
    
    // Path and Controls Offset
    var scrollX = CGFloat(0.0)
    var scrollY = CGFloat(0.0)
    var lastScrollX = CGFloat(0.0)
    var lastScrollY = CGFloat(0.0)
    
    // Crop Path Values
    var lastPoint: CGPoint!
    var deltaFingerX = CGFloat(0)
    var deltaFingerY = CGFloat(0)
    var pointsFromPath = Array<CGPoint>()
    
    // Scissor Parameters
    var rotationValues = Array<Double>()
    var lastRotationDiff = Double(0)
    var rotationAverage = Double(0)
    var rotationDiff = CGFloat(0)
    var scissorImage = UIImageView()
    var scissorControlPoints = Array<UIImageView>()
    
    
    var cloth: Cloth!
    

    // Initializers
    init(cloth: Cloth) {
        self.cloth = cloth
        super.init(nibName: "CustomCropViewController", bundle: nil)
        self.title = "Recorte"
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let alert = SCLAlertView(newWindowWidth: screenWidth*0.8)
        alert?.shouldDismissOnTapOutside = true
        alert?.showInfo("Pressione na tela", subTitle: "Pressione continuamente o dedo por uma fração de segundos para iniciar o corte ou continuar o corte. Utilize os pontos de controles da tesoura para auxílio, sempre pressionando continuamente antes de iniciar o corte", closeButtonTitle: nil, duration: 15.0)
        

        // Image View Creation
        var imageToBeCropped = cloth.getImage()
        imageToBeCropped = imageToBeCropped.resizeImage(CGFloat(screenWidth*2))
        let scale = (imageToBeCropped.size.width / UIScreen.main.bounds.width)/2
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth*2, height: (imageToBeCropped.size.height/scale)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageToBeCropped
        
        // Long Press Gesture to Start the Crop Process
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CustomCropViewController.createCustomCrop(_:)))
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.minimumPressDuration = 0.4
        
        // ScrollView for Image
        scrollImage = UIScrollView()
        scrollImage.frame = UIScreen.main.bounds
        scrollImage.delegate = self
        scrollImage.contentSize = CGSize(width: imageView.bounds.width + 100, height: imageView.bounds.height + 100)
        scrollImage.panGestureRecognizer.require(toFail: longPressGesture)
        self.view.addSubview(scrollImage)
        
        scrollImage.addSubview(imageView)
        scrollImage.addGestureRecognizer(longPressGesture)
        
        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        self.edgesForExtendedLayout = UIRectEdge()
        
    }
    

    // Crop Functions
    func createCustomCrop(_ gesture: UILongPressGestureRecognizer) {
        scrollImage.isScrollEnabled = false
        switch gesture.state {
        case .began:
            if var location:CGPoint = gesture.location(in: self.view) {

                
                // Check if cutting process is already initiated
                if !cutProcess {
                    customLayer.fillColor = UIColor.white.withAlphaComponent(CGFloat(0.2)).cgColor
                    customLayer.path = fingerPath.cgPath
                    customLayer.strokeColor = AppCustomColor().pink.cgColor
                    customLayer.lineDashPattern = [10,10]
                    customLayer.lineWidth = 3.0
                    self.view.layer.addSublayer(customLayer)
                    fingerPath.move(to: location)
                    cutProcess = true
                    
                    
                    
                    // Create Scissor
                    scissorImage.image = UIImage(named: "scissors.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    scissorImage.tintColor = AppCustomColor().pink
                    scissorImage.frame = CGRect(x: 10, y: 80, width: 40, height: 40)
                    scissorImage.contentMode = .scaleAspectFit
                    scissorImage.tag = 0
                    scissorImage.center = location
                    self.view.addSubview(scissorImage)
                    
                    
                    
                    // Create Control Points
                    let offset = CGFloat(100)
                    let size = CGFloat(40)
                    let cpImage = UIImage(named: "controlPoint.png")

                    let cp1 = UIImageView()
                    cp1.image = cpImage
                    cp1.contentMode = .scaleAspectFit
                    cp1.frame = CGRect(x: 0,y: 0,width: size,height: size)
                    cp1.center = scissorImage.center
                    cp1.center.x = scissorImage.center.x + offset
                    scissorControlPoints.append(cp1)
                    
                    let cp2 = UIImageView()
                    cp2.image = cpImage
                    cp2.contentMode = .scaleAspectFit
                    cp2.frame = CGRect(x: 0,y: 0,width: size,height: size)
                    cp2.center = scissorImage.center
                    cp2.center.x = scissorImage.center.x - offset
                    scissorControlPoints.append(cp2)
                    
                    let cp3 = UIImageView()
                    cp3.image = cpImage
                    cp3.contentMode = .scaleAspectFit
                    cp3.frame = CGRect(x: 0,y: 0,width: size,height: size)
                    cp3.center = scissorImage.center
                    cp3.center.y = scissorImage.center.y + offset
                    scissorControlPoints.append(cp3)
                    
                    let cp4 = UIImageView()
                    cp4.image = cpImage
                    cp4.contentMode = .scaleAspectFit
                    cp4.frame = CGRect(x: 0,y: 0,width: size,height: size)
                    cp4.center = scissorImage.center
                    cp4.center.y = scissorImage.center.y - offset
                    scissorControlPoints.append(cp4)
                    
                    for controlPoint in scissorControlPoints {
                        self.view.addSubview(controlPoint)
                    }
              
                    
                    
                    
                } else {
                    
                    deltaFingerX = fingerPath.currentPoint.x - location.x
                    deltaFingerY = fingerPath.currentPoint.y - location.y
                    
                    location.x = location.x + deltaFingerX
                    location.y = location.y + deltaFingerY
                    
                    fingerPath.addLine(to: location)
                    customLayer.path = fingerPath.cgPath
                    self.view.setNeedsDisplay()
                    
                    updateScissorAndControlPointsPosition(location)
                }
                
                
                

            }
            
            break
        case .changed:
                if var location: CGPoint = gesture.location(in: self.view) {
                    let pointBefore = fingerPath.currentPoint
                    
                    location.x = location.x + deltaFingerX
                    location.y = location.y + deltaFingerY
                    fingerPath.addLine(to: location)
                    customLayer.path = fingerPath.cgPath
                    updateScissorAndControlPointsPosition(location)
                    let rotation = angleFromLine(pointBefore, pointAfter: fingerPath.currentPoint)
                    rotateScissor(rotation)

                    self.view.setNeedsDisplay()
                    
                    if pointsFromPath.count < 20 {
                        pointsFromPath.append(location)
                    } else if pointsFromPath.count == 20 {
                        createEndCutProcessButton()
                    }

                    
                    
                    
                    
            }
  
            break
        case .ended:
            scrollImage.isScrollEnabled = true

            break
        default:
            scrollImage.isScrollEnabled = true
            break
        }
    }
    func createEndCutProcessButton() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(CustomCropViewController.cancelCutProcess))
        let endCutButton = UIBarButtonItem(title: "Cortar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CustomCropViewController.endCut))
        self.navigationItem.setRightBarButtonItems([endCutButton,cancelButton], animated: true)
    }
    func cancelCutProcess() {
        self.navigationItem.setRightBarButtonItems([], animated: true)
        cutProcess = false
        fingerPath.removeAllPoints()
        customLayer.removeFromSuperlayer()
        removeScissorAndControlPoints()
        dismissViewController()
    }
    func endCut() {
        
        fingerPath.apply(CGAffineTransform(translationX: scrollX, y: scrollY))
        fingerPath.close()
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        fingerPath.addClip()
        UIColor.white.setFill()
        fingerPath.fill()
        context?.restoreGState()
        
        
        if let newImage = imageView.image?.imageClipWithBezierPath(fingerPath) {
            imageView.image = newImage
        }

        fingerPath.removeAllPoints()
        customLayer.removeFromSuperlayer()
        removeScissorAndControlPoints()
        
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(CustomCropViewController.saveNewImage))
        self.navigationItem.rightBarButtonItem = saveButton


    }
    
    func saveNewImage() {
        cloth.setImage(imageView.image!)
        
        // Save Edited Image to Parse
        let imageData = UIImagePNGRepresentation(imageView.image!)
        let imageFile = PFFile(name: "cropped", data: imageData!)
        let clothQuery = PFQuery(className: "Clothes")
        clothQuery.whereKey("ownerId", equalTo: (PFUser.current()?.objectId)!)
        clothQuery.getObjectInBackground(withId: cloth.getId()) { (object, error) -> Void in
            if let object = object {
                object["image"] = imageFile
                object.saveInBackground()
            }
        }
        dismissViewController()
    }
    
    
    func removeScissorAndControlPoints() {
        scissorImage.removeFromSuperview()
        for controlPoint in scissorControlPoints {
            controlPoint.removeFromSuperview()
        }
        scissorControlPoints.removeAll()
    }
    func angleFromLine(_ pointBefore: CGPoint, pointAfter: CGPoint) -> Double {
        
        let diffX: Double = Double(pointAfter.x) - Double(pointBefore.x)
        let diffY: Double = Double(pointAfter.y) - Double(pointBefore.y)
        let angleInRadians = atan2(diffY, diffX)
        return angleInRadians
    }
    func rotateScissor(_ rotationAngleInRadians: Double) {
        rotationValues.append(rotationAngleInRadians)
        if rotationValues.count == 15 {
            rotationAverage = rotationValues.reduce(0) { $0 + $1 } / Double(rotationValues.count)
            let futureAngleInDegrees = Int((rotationAverage > 0 ? rotationAverage : (2*M_PI + rotationAverage)) * 360 / (2*M_PI))
            let lastAngleInDegrees = Int((lastRotationDiff > 0 ? lastRotationDiff : (2*M_PI + lastRotationDiff)) * 360 / (2*M_PI))
            
            rotationDiff =  futureAngleInDegrees.degreesToRadians - lastAngleInDegrees.degreesToRadians
            
            scissorImage.transform = scissorImage.transform.rotated(by: CGFloat(rotationDiff))
            lastRotationDiff = rotationAverage
            
            rotationValues.removeAll()
        }
    }
    func updateScissorAndControlPointsPosition(_ newPosition: CGPoint) {
        for controlPoint in scissorControlPoints {
            let offsetX = controlPoint.center.x - scissorImage.center.x
            let offsetY = controlPoint.center.y - scissorImage.center.y
            controlPoint.center.x = newPosition.x + offsetX
            controlPoint.center.y = newPosition.y + offsetY
        }
        scissorImage.center = newPosition
    }

    
    // Scroll Updates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollX = scrollImage.contentOffset.x
        scrollY = scrollImage.contentOffset.y
        
        let dx:CGFloat = lastScrollX - scrollX
        let dy:CGFloat = lastScrollY - scrollY
        
        lastScrollX = scrollX
        lastScrollY = scrollY

        if let _:UIBezierPath = fingerPath {
            fingerPath.apply(CGAffineTransform(translationX: dx, y: dy))
            customLayer.path = fingerPath.cgPath
        }
        
        
        if let _:UIImageView = scissorImage {
            let newX = scissorImage.center.x + dx
            let newY = scissorImage.center.y + dy
            let newPosition = CGPoint(x: newX, y: newY)
            updateScissorAndControlPointsPosition(newPosition)
            
        }
    }
    
   
    
    func dismissViewController() {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}






// MARK: Extension for special functions with images
extension UIImage {
    func imageClipWithBezierPath(_ bezierPath: UIBezierPath) -> UIImage {
        let frame = CGRect(x: 0,y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        bezierPath.addClip()
        self.draw(in: frame)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        return newImage!
    }
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}





// MARK: Extension for special operation with Int
extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}
