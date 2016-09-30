//
//  MyShop.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 22/05/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit

class MyShop: UIViewController {

    
    var containerView :UIView!
    var currentVc: UIViewController?
    
    override func viewDidLoad() {
        
        print("\n\n\nSHOP VIEW CONTROLLER IS BEING PRESENTED.")
        createBackground()
        createMenuButton()
        createShowcaseView()
        createSegmentedControl()
        addInitialViewControllerToContainer()
        
     
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Lojinha"
    }
    
    // MARK: Setup Screen
    func createBackground() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let background = UIImageView()
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.image = UIImage(named: "looksBackground.png")
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        self.edgesForExtendedLayout = UIRectEdge()
        print("Created Background.")
    }
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MyGarbage.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
        print("Created Menu Button.")
    }
    func menuShow() {
        Window().showMenuWithCustomTransition(sender: self)
    }
    func createSearchButton() {
        print("Created Button to Search for Ads.")
        let addClosetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(MyShop.searchAd))
        self.navigationItem.rightBarButtonItem = addClosetButton
    }
    func searchAd() {
        print("Search for ads that has text...")
    }
    func createShowcaseView() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        containerView = UIView()
        containerView.frame = CGRect(x: 0, y: (10 + screenHeight*0.05 + 10), width: screenWidth, height: screenHeight - (10 + screenHeight*0.05 + 10))
        containerView.backgroundColor = nil
        self.view.addSubview(containerView)
        print("Created Container View to work as showcase.")
    }
    func addInitialViewControllerToContainer() {
        currentVc = PurchaseViewController(nibName: "PurchaseViewController", bundle: nil)
        self.addChildViewController(currentVc!)
        containerView.addSubview(currentVc!.view)
        currentVc!.didMove(toParentViewController: self)
        print("Added \(currentVc!.nibName!) to Container View.")
    }
    
    // MARK: Segmented Control
    func createSegmentedControl() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let items = ["Comprar", "Vender"]
        let switchViewsControl = UISegmentedControl(items: items)
        switchViewsControl.frame = CGRect(x: screenWidth*0.1, y: 10, width: screenWidth*0.8, height: screenHeight*0.05)
        switchViewsControl.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.8))
        switchViewsControl.tintColor = AppCustomColor().pink
        switchViewsControl.layer.cornerRadius = CGFloat(3.5)
        switchViewsControl.layer.masksToBounds = true
        let attr = NSDictionary(object: UIFont(name: "Klavika", size: 16.0)!, forKey: NSFontAttributeName as NSCopying)
        switchViewsControl.setTitleTextAttributes(attr as! [AnyHashable: Any] , for: UIControlState())
        switchViewsControl.selectedSegmentIndex = 0
        switchViewsControl.addTarget(self, action: #selector(MyShop.switchViews(_:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(switchViewsControl)
        print("Created Segmented Control for Views.")
    }
    func switchViews(_ sender:UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            switchToView(PurchaseViewController(nibName: "PurchaseViewController", bundle: nil))
        case 1:
            switchToView(SalesViewController(nibName: "SalesViewController", bundle: nil))
        default:
            print("Switched to Purchase View Controller.")
        }
    }
    func switchToView(_ destinationVc: UIViewController) {
        if currentVc == destinationVc { return }
        currentVc!.willMove(toParentViewController: nil)
        self.addChildViewController(destinationVc)
        print("\nSwitched to \(destinationVc.nibName!).")
        containerView.addSubview(destinationVc.view)
        currentVc!.removeFromParentViewController()
        destinationVc.didMove(toParentViewController: self)
        currentVc = destinationVc
    }
    
    
    
    
    
    
    deinit {
        print("MyShopViewController has been deinitialized.")
        
    }
    
}
