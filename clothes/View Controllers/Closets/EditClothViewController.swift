//
//  EditClothViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 05/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit



class EditClothViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChangeClothesProperties {

    
    var occasions: [String] = []
    var cloth: Cloth!
    var tableView: UITableView!
    var badgeViews = [AnyObject]()
   

    
    
    // Initialiers
    init(cloth: Cloth) {
        self.cloth = cloth
        super.init(nibName: "EditClothViewController", bundle: nil)
        self.title = "Perfil da Roupa"
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        createBackground()
        occasions = Enumerators().getOccasionTypes().sorted()
        badgeViews = createClothBadge()
        createOccasionsTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isToolbarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    
    
    
    // MARK: Setup Things
    func createBackground() {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let background = UIImageView()
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.image = UIImage(named: "looksBackground.png")
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        
        self.edgesForExtendedLayout = UIRectEdge()
        print("Created Background.")
    }
    func createClothBadge() -> [AnyObject] {
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let clothView = UIButton(type: UIButtonType.custom)
        clothView.frame = CGRect(x: 10, y: 10, width: screenWidth*0.40, height: screenWidth*0.40)
        clothView.layer.cornerRadius = CGFloat(clothView.frame.size.height/2)
        clothView.layer.masksToBounds = true
        clothView.layer.borderColor = AppCustomColor().pink.cgColor
        clothView.layer.borderWidth = CGFloat(10)
        clothView.imageView?.contentMode = .scaleAspectFill
        clothView.setImage(cloth.getImage(), for: UIControlState())
        clothView.addTarget(self, action: #selector(EditClothViewController.changeClothProperties), for: UIControlEvents.touchUpInside)
        
        let clothStrip = UIView()
        clothStrip.frame = CGRect(x: 0, y: 0, width: screenWidth, height: clothView.frame.size.height*0.8)
        clothStrip.center = CGPoint(x: screenWidth/2, y: clothView.frame.origin.y + (clothView.frame.size.height/2))
        clothStrip.backgroundColor = AppCustomColor().darkGray.withAlphaComponent(CGFloat(0.7))
        self.view.addSubview(clothStrip)
        self.view.addSubview(clothView)
        
        let clothTypeIcon = UIImageView()
        clothTypeIcon.frame = CGRect(x: clothView.frame.origin.x + clothView.frame.size.width + 4,
                                         y: clothView.frame.origin.y + clothView.frame.size.height*0.3,
                                         width: clothView.frame.size.height*0.2, height: clothView.frame.size.height*0.2)
        clothTypeIcon.image = UIImage(named: Enumerators().getImageForClothType(cloth.getType()))?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        clothTypeIcon.contentMode = .scaleAspectFit
        clothTypeIcon.tintColor = UIColor.white
        self.view.addSubview(clothTypeIcon)
        
        let clothTypeLabel = UILabel()
        clothTypeLabel.frame = CGRect(x: clothTypeIcon.frame.origin.x + clothTypeIcon.frame.size.width + 7,
                                          y: clothTypeIcon.frame.origin.y,
                                          width: screenWidth - (clothTypeIcon.frame.origin.x + clothTypeIcon.frame.size.width + 4) - 7,
                                          height: clothView.frame.size.height*0.2)
        clothTypeLabel.text = cloth.getType()
        clothTypeLabel.textColor = UIColor.white
        clothTypeLabel.font = UIFont(name: (clothTypeLabel.font?.fontName)!, size: CGFloat(20))
        self.view.addSubview(clothTypeLabel)
        
        let clothNameLabel = UILabel()
        clothNameLabel.frame = CGRect(x: clothTypeIcon.frame.origin.x,
                                          y: clothTypeLabel.frame.origin.y + clothTypeLabel.frame.size.height-4, width: clothTypeLabel.frame.width,
                                          height: clothTypeLabel.frame.height)
        clothNameLabel.text = cloth.getName()
        clothNameLabel.textColor = AppCustomColor().pink
        clothNameLabel.font = UIFont(name: "Klavika", size: CGFloat(25))
        self.view.addSubview(clothNameLabel)
        
        return [clothTypeIcon,clothTypeLabel,clothNameLabel]
    }
    func changeClothProperties() {
        let destinationController = ChangeClothPropertiesViewController(delegate: self, cloth: cloth)
        if let navigation = navigationController {
            navigation.pushViewController(destinationController, animated: true)
        }
    }
    func updateClothBadge() {
            print("Updating cloth badges.")
            let icon = badgeViews[0] as! UIImageView
            let type = badgeViews[1] as! UILabel
            let name = badgeViews[2] as! UILabel
            
            icon.image = UIImage(named: Enumerators().getImageForClothType(cloth.getType()))!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            type.text = cloth.getType()
            name.text = cloth.getName()

    }
    

    
    // MARK: Table View Data Source and Delegate
    func createOccasionsTableView() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        tableView = UITableView(frame: CGRect(x: 0, y: screenWidth*0.40 + 10, width: screenWidth, height: screenHeight - (screenWidth*0.40 + 50)), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = AppCustomColor().darkGray
        self.view.addSubview(tableView)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return occasions.count

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedCellView = UIView()
        selectedCellView.backgroundColor = AppCustomColor().lightGray
        
        let cell = OccasionCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        let runTimeOccasion = occasions[(indexPath as NSIndexPath).item]
        cell.textLabel?.text = runTimeOccasion
        for occasion in cloth.getOccasions() {
            if runTimeOccasion == occasion {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        cell.backgroundColor = AppCustomColor().gray
        cell.textLabel?.textColor = AppCustomColor().pink
        cell.textLabel?.font = UIFont(name: cell.textLabel!.font!.fontName , size: CGFloat(17))
        cell.selectedBackgroundView = selectedCellView
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
            if let cell = tableView.cellForRow(at: indexPath) {
                let occasion = occasions[(indexPath as NSIndexPath).row]
                
                if cell.accessoryType == UITableViewCellAccessoryType.none {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    cloth.addOccasion(occasion)
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    cloth.removeOccasion(occasion)
                }
            }
    

        

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth*0.12

    }
    
    
    func dismissViewControllerBackToClosets() {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}



class ClothTitleCell: UITableViewCell {
    
    var clothImage: UIImageView!
    var clothType: UILabel!
    var clothName: UILabel!
    var menuArrow: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let cellWidth = self.frame.width
        let cellHeight = CGFloat(80)

        clothImage = UIImageView()
        clothImage.frame = CGRect(x: cellWidth*0.04, y: cellHeight*0.05, width: cellHeight*0.9, height: cellHeight*0.9)
        clothImage.layer.cornerRadius = CGFloat(7)
        clothImage.layer.masksToBounds = true
        clothImage.contentMode = .scaleAspectFill
        self.contentView.addSubview(clothImage)
        
        clothType = UILabel()
        clothType.frame = CGRect(x: clothImage.frame.origin.x + clothImage.frame.width + cellWidth*0.03, y: cellHeight*0.2, width: cellWidth*0.8, height: cellHeight*0.3)
        clothType.textColor = UIColor.white
        clothType.font = UIFont(name: clothType.font!.fontName , size: CGFloat(20))
        self.contentView.addSubview(clothType)
        
        clothName = UILabel()
        clothName.frame = CGRect(x: clothImage.frame.origin.x + clothImage.frame.width + cellWidth*0.03, y: cellHeight*0.5, width: cellWidth*0.8, height: cellHeight*0.3)
        clothName.textColor = AppCustomColor().pink
        clothName.font = UIFont(name: "Klavika" , size: CGFloat(25))
        self.contentView.addSubview(clothName)
        
        menuArrow = UIImageView()
        menuArrow.frame = CGRect(x: cellWidth*0.85, y: cellHeight*0.35, width: cellHeight*0.3, height: cellHeight*0.3)
        menuArrow.image = UIImage(named: "menuArrow.png")
        menuArrow.contentMode = .scaleAspectFill
        menuArrow.tintColor = AppCustomColor().twiceLightGray
        self.contentView.addSubview(menuArrow)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
    
}



class OccasionCell: UITableViewCell {

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}
