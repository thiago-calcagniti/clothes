//
//  AccountViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 23/05/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import Parse


protocol ChangeAccount {
    func changeEmail(_ newEmail:String)
}

class AccountViewController: UIViewController, UITextFieldDelegate {

    let numberMobile = UITextField()
    let emailAddress = UITextField()
    var email: String!
    var delegate: ChangeAccount?

    
    // Initializers
    init(delegate: ChangeAccount, email: String) {
        self.delegate = delegate
        self.email = email
        super.init(nibName: "AccountViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        setupView()
        getMobileNumber()

        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Minha Conta"
    }
    
    
    
    // MARK: Setup View
    func setupView() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let background = UIImageView()
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        background.image = UIImage(named: "looksBackground.png")
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        
        let board = UIView()
        board.frame = CGRect(x: screenWidth*0.015, y: screenWidth*0.015, width: screenWidth*0.97, height: screenHeight*0.95 - 45)
        board.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(0.6))
        board.layer.cornerRadius = CGFloat(7)
        self.view.addSubview(board)
        
        // Email and login frame
        let updateEmailContainer = UIView()
        updateEmailContainer.frame = CGRect(x: screenWidth*0.015, y: screenWidth*0.015, width: screenWidth*0.97, height: screenHeight*0.29)
        self.view.addSubview(updateEmailContainer)
        let border = updateEmailContainer.frame.size.width
        
        let emailTitleField = UILabel()
        emailTitleField.frame = CGRect(x: border*0.025, y: border*0.025, width: border*0.95, height: screenHeight*0.037)
        emailTitleField.text = "Email de Contato e Login"
        emailTitleField.font = UIFont(name: "klavika", size: CGFloat(20))
        updateEmailContainer.addSubview(emailTitleField)
        
        let emailTitleDescription = UILabel()
        emailTitleDescription.frame = CGRect(x: border*0.025, y: -border*0.01 + emailTitleField.frame.size.height, width: border*0.95, height: screenHeight*0.12)
        emailTitleDescription.numberOfLines = 0
        emailTitleDescription.text = "Mantenha seu email sempre atualizado. Este é seu meio de contato para vendas na lojinha e login."
        emailTitleDescription.font = UIFont(name: "klavika", size: CGFloat(15))
        emailTitleDescription.textColor = AppCustomColor().lightGray
        updateEmailContainer.addSubview(emailTitleDescription)
        
        
        emailAddress.frame = CGRect(x: border*0.025, y: border*0.06 + emailTitleDescription.frame.size.height, width: border*0.95, height: screenHeight*0.04)
        emailAddress.text = "\(email)"
        emailAddress.font = UIFont(name: "klavika", size: CGFloat(20))
        emailAddress.textColor = AppCustomColor().blue
        emailAddress.addTarget(nil, action: #selector(AccountViewController.firstResponderAction(_:)), for: .editingDidEndOnExit)
        updateEmailContainer.addSubview(emailAddress)
        
        let emailLine = UILabel()
        emailLine.frame = CGRect(x: border*0.025, y: border*0.06 + emailTitleDescription.frame.size.height + emailAddress.frame.size.height, width: border*0.95, height: 2)
        emailLine.backgroundColor = AppCustomColor().pink
        updateEmailContainer.addSubview(emailLine)
        
        let emailUpdateButton = UIButton(type: UIButtonType.custom)
        emailUpdateButton.frame = CGRect(x: border*0.025, y: border*0.085 + screenHeight*0.16, width: border*0.95, height: 40)
        emailUpdateButton.backgroundColor = AppCustomColor().lightGray
        emailUpdateButton.setTitle("ATUALIZAR EMAIL", for: UIControlState())
        emailUpdateButton.titleLabel?.font = UIFont(name: "klavika", size: CGFloat(20))
        emailUpdateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        emailUpdateButton.setTitleColor(UIColor.white, for: UIControlState())
        emailUpdateButton.layer.cornerRadius = CGFloat(5)
        emailUpdateButton.layer.masksToBounds = true
        emailUpdateButton.addTarget(self, action: #selector(AccountViewController.updateEmail), for: UIControlEvents.touchUpInside)
        updateEmailContainer.addSubview(emailUpdateButton)
        
        // Update Mobile Number
        let updateNumberContainer = UIView()
        updateNumberContainer.frame = CGRect(x: screenWidth*0.015, y: screenWidth*0.015 + updateEmailContainer.frame.size.height, width: screenWidth*0.97, height: screenHeight*0.26)
        self.view.addSubview(updateNumberContainer)
        
        let numberTitleField = UILabel()
        numberTitleField.frame = CGRect(x: border*0.025, y: border*0.025, width: border*0.95, height: screenHeight*0.037)
        numberTitleField.text = "Atualizar Telefone"
        numberTitleField.font = UIFont(name: "klavika", size: CGFloat(20))
        updateNumberContainer.addSubview(numberTitleField)
        
        let numberTitleDescription = UILabel()
        numberTitleDescription.frame = CGRect(x: border*0.025, y: numberTitleField.frame.size.height, width: border*0.95, height: screenHeight*0.08)
        numberTitleDescription.numberOfLines = 0
        numberTitleDescription.text = "Este telefone será visualizado nas suas compras e vendas."
        numberTitleDescription.font = UIFont(name: "klavika", size: CGFloat(15))
        numberTitleDescription.textColor = AppCustomColor().lightGray
        updateNumberContainer.addSubview(numberTitleDescription)
        

        numberMobile.frame = CGRect(x: border*0.025, y: border*0.06 + numberTitleDescription.frame.size.height, width: border*0.95, height: screenHeight*0.04)
        numberMobile.font = UIFont(name: "klavika", size: CGFloat(20))
        numberMobile.textColor = AppCustomColor().blue
        numberMobile.keyboardType = UIKeyboardType.numberPad
        updateNumberContainer.addSubview(numberMobile)
        
        let numberMobileLine = UILabel()
        numberMobileLine.frame = CGRect(x: border*0.025, y: border*0.07 + numberMobile.frame.size.height + numberTitleDescription.frame.size.height, width: border*0.95, height: 1)
        numberMobileLine.backgroundColor = AppCustomColor().gray
        updateNumberContainer.addSubview(numberMobileLine)
        
        let numberUpdateButton = UIButton(type: UIButtonType.custom)
        numberUpdateButton.frame = CGRect(x: border*0.025, y: border*0.025 + numberTitleField.frame.size.height + numberTitleDescription.frame.size.height + numberMobile.frame.size.height + numberMobileLine.frame.size.height , width: border*0.95, height: 40)
        numberUpdateButton.backgroundColor = AppCustomColor().lightGray
        numberUpdateButton.setTitle("ATUALIZAR NÚMERO", for: UIControlState())
        numberUpdateButton.titleLabel?.font = UIFont(name: "klavika", size: CGFloat(20))
        numberUpdateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        numberUpdateButton.setTitleColor(UIColor.white, for: UIControlState())
        numberUpdateButton.layer.cornerRadius = CGFloat(5)
        numberUpdateButton.layer.masksToBounds = true
        numberUpdateButton.addTarget(self, action: #selector(AccountViewController.updateMobileNumber), for: UIControlEvents.touchUpInside)
        updateNumberContainer.addSubview(numberUpdateButton)
        
        // Update Password
        let updatePasswordContainer = UIView()
        updatePasswordContainer.frame = CGRect(x: screenWidth*0.015, y: screenWidth*0.015 + updateEmailContainer.frame.size.height + updateNumberContainer.frame.size.height, width: screenWidth*0.97, height: screenHeight*0.2)
        self.view.addSubview(updatePasswordContainer)
        
        let passwordTitleField = UILabel()
        passwordTitleField.frame = CGRect(x: border*0.025, y: border*0.025, width: border*0.95, height: screenHeight*0.037)
        passwordTitleField.text = "Atualizar Senha"
        passwordTitleField.font = UIFont(name: "klavika", size: CGFloat(20))
        updatePasswordContainer.addSubview(passwordTitleField)
        
        let passwordTitleDescription = UILabel()
        passwordTitleDescription.frame = CGRect(x: border*0.025, y: passwordTitleField.frame.size.height, width: border*0.95, height: screenHeight*0.08)
        passwordTitleDescription.numberOfLines = 0
        passwordTitleDescription.text = "Clique no botão abaixo para receber um email com detalhes para reset da sua senha."
        passwordTitleDescription.font = UIFont(name: "klavika", size: CGFloat(15))
        passwordTitleDescription.textColor = AppCustomColor().lightGray
        updatePasswordContainer.addSubview(passwordTitleDescription)
        
        let passwordUpdateButton = UIButton(type: UIButtonType.custom)
        passwordUpdateButton.frame = CGRect(x: border*0.025, y: passwordTitleField.frame.size.height + passwordTitleDescription.frame.size.height, width: border*0.95, height: 40)
        passwordUpdateButton.backgroundColor = AppCustomColor().lightGray
        passwordUpdateButton.setTitle("RESETAR SENHA", for: UIControlState())
        passwordUpdateButton.titleLabel?.font = UIFont(name: "klavika", size: CGFloat(20))
        passwordUpdateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        passwordUpdateButton.setTitleColor(UIColor.white, for: UIControlState())
        passwordUpdateButton.layer.cornerRadius = CGFloat(5)
        passwordUpdateButton.layer.masksToBounds = true
        passwordUpdateButton.addTarget(self, action: #selector(AccountViewController.resetPassword), for: UIControlEvents.touchUpInside)
        updatePasswordContainer.addSubview(passwordUpdateButton)

        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    
    // MARK: Gather user Parameters
    func getMobileNumber() {
        let user = PFUser.current()!
        if let userMobileNumber = user["phoneNumber"] as? String {
            self.numberMobile.text = userMobileNumber
        } else {
            numberMobile.text = ""
        }
    }
    
    // MARK: Update Information
    func updateEmail() {
        if let _ = emailAddress.text {
            let user = PFUser.current()!
            user.email = emailAddress.text! as String
            user.username = user.email
            user.saveInBackground(block: { (success, error) in
                if success {
                    self.delegate?.changeEmail(self.emailAddress.text!)
                    let emailChangedPrompt = UIAlertController(title: "Successo!", message: "Seu email foi modificado para \(self.emailAddress.text!)", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    emailChangedPrompt.addAction(okButton)
                    self.present(emailChangedPrompt, animated: true, completion: nil)
                    print("Email modified with success")
                } else {
                    let emailChangedPrompt = UIAlertController(title: "Ops!", message: "Seu endereco de email é inválido", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    emailChangedPrompt.addAction(okButton)
                    self.present(emailChangedPrompt, animated: true, completion: nil)
                    print("Email couldnt be modified")
                    self.emailAddress.text = ""
                    self.delegate?.changeEmail(self.emailAddress.text!)
                    
                }
            })
        }
    }
    func updateMobileNumber() {
        if let mobileNumber = numberMobile.text {
        let user = PFUser.current()!
        user["phoneNumber"] = mobileNumber as String
        user.saveInBackground(block: { (success, error) in
            if success {
                let mobileNumberChangedPrompt = UIAlertController(title: "Successo!", message: "Seu telefone foi modificado para \(self.numberMobile.text!)", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                mobileNumberChangedPrompt.addAction(okButton)
                self.present(mobileNumberChangedPrompt, animated: true, completion: nil)
            } else {
                print("Mobile Number couldnt be updated")
            }
        })
        }
    }
    func resetPassword() {
        if let _ = email {
            PFUser.requestPasswordResetForEmail(inBackground: email, block: { (success, error) in
                if success {
                    let resetPasswordMailSentPrompt = UIAlertController(title: "Solicitação Enviada", message: "Enviamos um link de reset de password para seu email \(self.emailAddress.text!)", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    resetPasswordMailSentPrompt.addAction(okButton)
                    self.present(resetPasswordMailSentPrompt, animated: true, completion: nil)
                    print("Mail with new password sent to \(self.email)")
                }
            })

        }
    }

    
    // MARK: Keyboard Properties
    func firstResponderAction(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        numberMobile.resignFirstResponder()
    }

    


    
}
