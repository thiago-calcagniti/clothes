//
//  MenuViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 06/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//  

import UIKit
import Parse

var veryLastController: UIViewController?


class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChangeProfilePicture {

    var profilePicture = UIImageView()
    var myViewControllers: [UIViewController] = []
    var myMenuImages: [String] = []


    override func viewDidLoad() {
        print("\n\n\nMENU VIEW CONTROLLER IS BEING PRESENTED.")
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        self.view.backgroundColor = AppCustomColor().darkGray
        profilePicture.image = getUserPicture()
        
        print("Preparing connections for other pages...")
        let myVC1 = MyClosets(nibName: "MyClosets", bundle: nil)
        let myVC2 = MyLooks(nibName: "MyLooks", bundle: nil)
        let myVC3 = MyGarbage(nibName: "MyGarbage", bundle: nil)
        let myVC4 = MyShop(nibName: "MyShop", bundle: nil)
        let myVC5 = LogOut(nibName: "LogOut", bundle: nil)
        let myVC6 = WebPlusAppViewController(nibName: "WebPlusAppViewController", bundle: nil)
        let myVC7 = MyEvents(nibName: "MyEvents", bundle: nil)
        let myVC8 = ProfileViewController(delegate: self, profilePicture: profilePicture.image!)
        let myVC9 = IAPViewController(nibName: "IAPViewController", bundle: nil)
        
        myVC1.title = "Meus Armários"
        myVC2.title = "Meus Looks"
        myVC3.title = "Meu Cesto"
        myVC4.title = "Lojinha"
        myVC5.title = "Log Out"
        myVC6.title = "PlusApp"
        myVC7.title = "Minha Agenda"
        myVC8.title = "Meu Perfil"
        myVC9.title = "Teste IAP"
        
        let VC1image = "menuCloset.png"
        let VC2image = "menuLooks.png"
        let VC3image = "menuBasket.png"
        let VC4image = "menuShop.png"
        let VC5image = "menuLogout.png"
        let VC6image = "menuPlusApp.png"
        let VC7image = "menuCalendar.png"
        let VC8image = "menuProfile.png"

        
        myViewControllers = [myVC1, myVC2, myVC3, myVC4, myVC5]
        myMenuImages = [VC1image, VC2image, VC3image, VC4image, VC5image]
        

        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = AppCustomColor().darkGray
        tableView.separatorColor = UIColor.black.withAlphaComponent(CGFloat(0.05))
        tableView.separatorStyle = .none    
        self.view.addSubview(tableView)
        print("Table Selector created.")
        
        
    }


    // MARK: Setup View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    func clearWindowFromTrashViews() {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if let window = appDelegate.window {
            let allViews = window.subviews
            if allViews.count > 4 {
                var index = 0
                for view in allViews {
                    if index < 3 {
                        view.removeFromSuperview()
                    }
                    index = index + 1
                }
            }
        }

    }
    

    
    
    // MARK: Get User Picture
    func getUserPicture() -> UIImage {
        var image = UIImage()
        let user = PFUser.current()!
        if let userPicture = user["profilePicture"] as? PFFile {
            userPicture.getDataInBackground(block: { (data, error) -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    self.profilePicture.image = downloadedImage
                    image = downloadedImage
                } else {
                    image = UIImage(named: "femaleIcon1.png")!
                }
            })
        } else {
            image = UIImage(named: "femaleIcon1.png")!
        }
        
        return image
    }
    
    
    
    // MARK: Edit Profile Picture
    func changeProfilePicture(_ newProfileImage: UIImage) {
        profilePicture.image = newProfileImage
    }
    
    
    // MARK: Setup Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myViewControllers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        let selectedCellView = UIView()
        selectedCellView.backgroundColor = AppCustomColor().lightGray
        cell.selectedBackgroundView = selectedCellView
        cell.backgroundColor = UIColor.white
        
        cell.menuImage.image = UIImage(named: myMenuImages[(indexPath as NSIndexPath).item])?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.menuName.text = myViewControllers[(indexPath as NSIndexPath).item].title
        

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = MenuCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        cell.menuImage.tintColor = AppCustomColor().pink
        cell.menuName.textColor = AppCustomColor().pink
        showViewController(myViewControllers[(indexPath as NSIndexPath).item])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth*0.12
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var screenHeight = UIScreen.main.bounds.height
        if Device().getType() == 60 {screenHeight = screenHeight*0.40*0.8}
        else if Device().getType() == 61 {screenHeight = screenHeight*0.35}
        else if Device().getType() == 50 {screenHeight = screenHeight*0.35}
        else {screenHeight = screenHeight*0.35}
        return screenHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let viewHeader = UIView()
        viewHeader.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*0.33)
        viewHeader.layer.masksToBounds = true
        
        var plusScreenRatio = CGFloat(1)
        if Device().getType() >= 61 {
            plusScreenRatio = CGFloat(1.3)
        }
        
        let profileDetailSize2 = CGFloat(300)*plusScreenRatio
        let profileDetail2: UIView = UIView()
        profileDetail2.frame = CGRect(x: ((screenWidth/2))-(profileDetailSize2/2), y: -(profileDetailSize2/2)+(90*plusScreenRatio), width: profileDetailSize2, height: profileDetailSize2)
        profileDetail2.layer.cornerRadius = CGFloat(profileDetailSize2/2)
        profileDetail2.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.3))
        viewHeader.addSubview(profileDetail2)
        
        let profileDetailSize = CGFloat(200)*plusScreenRatio
        let profileDetail: UIView = UIView()
        profileDetail.frame = CGRect(x: ((screenWidth/2))-(profileDetailSize/2), y: -(profileDetailSize/2)+(100*plusScreenRatio), width: profileDetailSize, height: profileDetailSize)
        profileDetail.layer.cornerRadius = CGFloat(profileDetailSize/2)
        profileDetail.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.3))
        viewHeader.addSubview(profileDetail)
        
        let size = CGFloat(120)*plusScreenRatio
        profilePicture.image = getUserPicture()
        profilePicture.tintColor = AppCustomColor().pink
        profilePicture.contentMode = .scaleAspectFit
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.borderWidth = 2.0
        profilePicture.frame = CGRect(x: ((screenWidth/2))-(size/2), y: 40, width: size, height: size)
        profilePicture.layer.cornerRadius = CGFloat(size/2)
        profilePicture.isUserInteractionEnabled = true
        viewHeader.addSubview(profilePicture)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.acessProfileMenu(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        profilePicture.addGestureRecognizer(tapGesture)
        
        let clothesLogo = UIImageView(image: UIImage(named: "clothesIconForMenu.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        clothesLogo.frame = CGRect(x: (screenWidth/2)-(screenWidth*0.6/2), y: 120*plusScreenRatio, width: screenWidth*0.6, height: screenHeight*0.09)
        clothesLogo.tintColor = AppCustomColor().pink
        clothesLogo.contentMode = .scaleAspectFit
        viewHeader.addSubview(clothesLogo)
        
        
        var screenRatio = CGFloat(1)
        let deviceType = Device().getType()
        if deviceType < 61 {
            screenRatio = screenRatio*0.8
        }
        
        let appLabel = UILabel()
        appLabel.frame = CGRect(x: (screenWidth/2)-(screenWidth*0.7/2), y: 120*plusScreenRatio + clothesLogo.frame.size.height/2.1, width: screenWidth*0.7, height: screenHeight*0.125*screenRatio)
        appLabel.textColor = AppCustomColor().pink
        appLabel.textAlignment = NSTextAlignment.center
        appLabel.text = "O melhor App em Moda"
        appLabel.font = UIFont(name: "Klavika", size: CGFloat(20)*screenRatio)
        viewHeader.addSubview(appLabel)

        
        return viewHeader
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let viewFooter = UIView()
        viewFooter.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*0.33)
        viewFooter.layer.masksToBounds = true
        
        let layer2 = UIView()
        layer2.frame = CGRect(x: screenWidth*0.15, y: 0, width: screenWidth*0.66, height: 500)
        layer2.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.3))
        viewFooter.addSubview(layer2)
        
        let layer1 = UIView()
        layer1.frame = CGRect(x: screenWidth*0.33, y: 0, width: screenWidth*0.33, height: 500)
        layer1.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.3))
        viewFooter.addSubview(layer1)
        
        
        
        return viewFooter
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 300
    }


    
    // MARK: Setup Navigation Controller from Views of Menu
    func showViewController(_ viewController: UIViewController) {
        
        print("\nUser selected to access \(viewController.nibName!).")
        
        profilePicture.removeFromSuperview()
        myViewControllers.removeAll()
        myMenuImages.removeAll()
        
        
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [viewController]
        navigationController.isNavigationBarHidden = false
        navigationController.navigationBar.barTintColor = AppCustomColor().darkGray
        navigationController.navigationBar.tintColor = AppCustomColor().pink
        navigationController.toolbar.barTintColor = AppCustomColor().darkGray
        navigationController.toolbar.tintColor = AppCustomColor().pink
        navigationController.navigationBar.barStyle = .blackTranslucent

        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Klavika", size: 30)!
        ]
        navigationController.navigationBar.titleTextAttributes = attributes
        Window().showPage(sender: self, toViewController: navigationController)
        
      
        
        
        
    }
    
    
    
    func acessProfileMenu(_ gesture: UITapGestureRecognizer) {
        let myProfile = ProfileViewController(delegate: self, profilePicture: profilePicture.image!)
        showViewController(myProfile)
    }
    
    
    deinit {
        print("MenuViewController has been deinitialised.")
    }


    
    
    

}


// MARK: Custom Menu Cell
class MenuCell: UITableViewCell {
    
    var menuImage: UIImageView!
    var menuName: UILabel!
    var menuArrow: UIImageView!
    var body: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = self.frame.width
        let cellHeight = CGFloat(screenWidth*0.12)
        
        var screenRatio = CGFloat(1)
        let deviceType = Device().getType()
        if deviceType < 61 {
            screenRatio = screenRatio*0.8
        }
        
        menuImage = UIImageView()
        menuImage.frame = CGRect(x: cellWidth*0.25, y: cellHeight*0.25, width: cellHeight*0.5, height: cellHeight*0.5)
        menuImage.layer.masksToBounds = true
        menuImage.contentMode = .scaleAspectFit
        menuImage.tintColor = AppCustomColor().lightGray
        self.contentView.addSubview(menuImage)
        
        menuName = UILabel()
        menuName.frame = CGRect(x: menuImage.frame.origin.x + menuImage.frame.width + cellWidth*0.08, y: cellHeight*0.33, width: cellWidth*0.8, height: cellHeight*0.45)
        menuName.textColor = AppCustomColor().lightGray
        menuName.font = UIFont(name: (menuName?.font.fontName)!, size: CGFloat(20)*screenRatio)
        self.contentView.addSubview(menuName)
        
        
        menuArrow = UIImageView()
        menuArrow.frame = CGRect(x: cellWidth*0.95, y: cellHeight*0.34, width: cellHeight*0.3, height: cellHeight*0.3)
        menuArrow.image = UIImage(named: "menuArrow.png")
        menuArrow.contentMode = .scaleAspectFill
        menuArrow.tintColor = AppCustomColor().twiceLightGray
//        self.contentView.addSubview(menuArrow)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}





