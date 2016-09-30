//
//  GenderViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 17/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse

protocol ChangeGender {
    func changeGender(_ newGender: String)
}

class GenderViewController: UIViewController {

    let possibleGenders = ["Masculino","Feminino"]
    let genderPicture = UIImageView()
    var delegate : ChangeGender?
    var gender : String?
    
    
    
    // Initializers
    init(delegate: ChangeGender, gender: String) {
        self.delegate = delegate
        self.gender = gender
        super.init(nibName: "GenderViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.backgroundColor = AppCustomColor().darkGray
        
        
        var genderImage = UIImage()
        if gender == "Masculino" {
           genderImage = UIImage(named: "maleIcon1.png")!
        } else if gender == "Feminino" {
            genderImage = UIImage(named: "femaleIcon1.png")!
        }
        
        
        genderPicture.frame = CGRect(x: screenWidth*0.1, y: screenHeight*0.2, width: screenWidth*0.8, height: screenHeight*0.4)
        genderPicture.image = genderImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        genderPicture.tintColor = AppCustomColor().pink
        genderPicture.contentMode = . scaleAspectFit
        self.view.addSubview(genderPicture)
        
        let segmentedGenderControl = UISegmentedControl(items: possibleGenders)
        segmentedGenderControl.frame = CGRect(x: screenWidth*0.1, y: screenHeight*0.65, width: screenWidth*0.8, height: screenHeight*0.1)
        segmentedGenderControl.layer.cornerRadius = CGFloat(7)
        segmentedGenderControl.tintColor = AppCustomColor().pink
        segmentedGenderControl.addTarget(self, action: #selector(GenderViewController.changeGenderPicture(_:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(segmentedGenderControl)

        if gender == "Masculino" {
            segmentedGenderControl.selectedSegmentIndex = 0
        } else if gender == "Feminino" {
            segmentedGenderControl.selectedSegmentIndex = 1
        }
        
        
        

    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Meu Sexo"
    }

    
    
    
    // MARK: Segmented Control Functions
    func changeGenderPicture (_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            genderPicture.image = UIImage(named: "maleIcon1.png")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            break
        case 1:
            genderPicture.image = UIImage(named: "femaleIcon1.png")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            break
        default : break
        }
        genderPicture.tintColor = AppCustomColor().pink
        genderPicture.contentMode = . scaleAspectFit
        
        
        let user = PFUser.current()!
        user["gender"] = possibleGenders[sender.selectedSegmentIndex]
        user.saveInBackground(block: { (success, error) -> Void in
            if success {
                self.delegate?.changeGender(self.possibleGenders[sender.selectedSegmentIndex])
            }
        })
        


    }

}
