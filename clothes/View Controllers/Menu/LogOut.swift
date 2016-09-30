//
//  ViewController5.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 29/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import UIKit

class LogOut: UIViewController {

    override func viewDidLoad() {
        createMenuButton()
        createLogOutButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Configurações"
    }
    
    // MARK: Setup Navigation Items
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(LogOut.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
    }
    func menuShow() {
        Window().showMenuWithCustomTransition(sender: self)
    }
    
    
    
    func createLogOutButton() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let logOutButton: UIButton = UIButton(type: UIButtonType.system)
        logOutButton.frame  = CGRect(x: screenWidth*0.3, y: screenHeight*0.5, width: screenWidth*0.4, height: screenHeight*0.1)
        logOutButton.addTarget(self, action: #selector(LogOut.logOutApp), for: UIControlEvents.touchUpInside)
        logOutButton.setTitle("Log Out", for: UIControlState())
        self.view.addSubview(logOutButton)
    }
    
    func logOutApp() {
        User().logOut()
        Alert(controller: self).message("Deslogado", message: "Seu logout foi feito com sucesso!.", confirmationTitle: "Volto mais tarde!")
    }
}
