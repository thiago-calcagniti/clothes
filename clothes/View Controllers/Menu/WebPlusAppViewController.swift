//
//  WebPlusAppViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 26/05/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit

class WebPlusAppViewController: UIViewController {
 
    override func viewDidLoad() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        createMenuButton()
        
        
        let webView = UIWebView()
        webView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        let url = URL(string: "http://www.plusapps.com.br")!
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        
        self.view.addSubview(webView)
    }
    
    
    // MARK: Setup Navigation Items
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MyLooks.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
    }
    func menuShow() {
        Window().showMenu()
    }

}
