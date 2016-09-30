//
//  Alert.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 05/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    let controller:UIViewController
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    // Standard Messages
    func message(_ title: String, message: String, confirmationTitle: String) {
        let windowWidth = CGFloat(UIScreen.main.bounds.width*0.8)
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: windowWidth)
        alert.showNotice(controller, title: title, subTitle: message, closeButtonTitle: confirmationTitle, duration: 3.0)
    }
    
    
//    func message(title: String, message: String, confirmationTitle: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        let ok = UIAlertAction(title: confirmationTitle, style: UIAlertActionStyle.Cancel, handler: nil)
//        alert.addAction(ok)
//        controller.presentViewController(alert, animated: true, completion: nil)
//    }
    
    func loginSucessful() {
        let windowWidth = CGFloat(UIScreen.main.bounds.width*0.8)
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: windowWidth)
        let titles: Array<String> = ["Olááá!", "Sua Linda!", "Saudades de você"]
        let subtitles: Array<String> = ["Seu login foi efetuado com sucesso", "Aproveite o App!!", "Que bom que voltou"]
        let closeButtonTitles: Array<String> = ["Sim!", "Owwunn", "Esse app é demais!", "Partiu criar looks"]
        let title = titles[Int(arc4random_uniform(UInt32(titles.count)))]
        let subtitle = subtitles[Int(arc4random_uniform(UInt32(subtitles.count)))]
        let closeButtonTitle = closeButtonTitles[Int(arc4random_uniform(UInt32(closeButtonTitles.count)))]
        alert.backgroundType = .Blur
        alert.showSuccess(controller, title: title, subTitle: subtitle, closeButtonTitle: closeButtonTitle, duration: 2.0)
    }
    
    
//    func loginSucessful() {
//        let alert = UIAlertController(title: "Logado com sucesso", message: "Aproveite o app =)!", preferredStyle: UIAlertControllerStyle.Alert)
//        let ok = UIAlertAction(title: "Concerteza", style: UIAlertActionStyle.Cancel, handler: nil)
//        alert.addAction(ok)
//        controller.presentViewController(alert, animated: true, completion: nil)
//    }
    
    
    // Actions with clothes
    func tellUserClothWasSucessfullyAdded(_ type: String) {
        let windowWidth = CGFloat(UIScreen.main.bounds.width*0.8)
        let imageName = Enumerators().getImageForClothType(type)
        let image = UIImage(named: imageName)
        let titles: Array<String> = ["Uaaaaauu", "Nossa!", "Que Lindaaa!"]
        let subtitles: Array<String> = ["está no guarda roupa!", "já se encontra no armário!"]
        let closeButtonTitles: Array<String> = ["Adorei!", "Amei!!", "Esse app é demais!", "S2"]
        var title = titles[Int(arc4random_uniform(UInt32(titles.count)))]
        var subtitle = subtitles[Int(arc4random_uniform(UInt32(subtitles.count)))]
        var closeButtonTitle = closeButtonTitles[Int(arc4random_uniform(UInt32(closeButtonTitles.count)))]
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(windowWidth))
        alert.showAnimationType = .SlideInFromBottom
        alert.backgroundType = .Blur
        alert.hideAnimationType = .SlideOutToBottom
        alert.showCustom(controller, image: image, color: AppCustomColor().pink, title: title, subTitle: "Novo \(type) \(subtitle)!", closeButtonTitle: closeButtonTitle, duration: 3.0)
    }

    
    func tellUserClothNameWasChanged(_ newName: String) {
        let alert = UIAlertController(title: "Nome Alterado", message: "Seu armário se chama \(newName) agora !", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "Demais !!", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func tellUserClothWasRemoved() {
        let windowWidth = UIScreen.main.bounds.width*0.8
        let closeButtonTitles: Array<String> = ["Não gostava dela!", "Tava horrível!", "Ufa!"]
        let closeButtonTitle = closeButtonTitles[Int(arc4random_uniform(UInt32(closeButtonTitles.count)))]
        let alert: SCLAlertView = SCLAlertView(newWindowWidth: CGFloat(windowWidth))
        alert.showWarning(controller, title: "Roupa Removida", subTitle: "Aquela roupa foi removida do seu armário", closeButtonTitle: closeButtonTitle, duration: 3.0)
    }



    
    

}
