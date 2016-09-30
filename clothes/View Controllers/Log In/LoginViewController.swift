//
//  LoginViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 26/12/15.
//  Copyright © 2015 Calcagniti. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class LoginViewController: UIViewController {


    var textFields = [UITextField]()
    var userNameTextField = UITextField()
    var passwordTextField = UITextField()
    var me:User = User()

    
    // MARK: View Controller Presentation
    override func viewDidLoad() {
        print("\nLOGIN VIEW CONTROLLER IS BEING LOADED.")
        createBackground()
        createIcon()
        createLoginFieldsAndButtons()
        print("Login View Controller loaded.")
        

    }
 

    
    // MARK: Create Screen for User to Login In
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    func createBackground() {
        // Get Screen Bounds
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        print("Creating background.")
        // Insert BackGround Image
        let backgroundImage = UIImageView(image: UIImage(named: "loginBackground02.png"))
        backgroundImage.frame = CGRect(x: -10,
            y: -10,
            width: screenWidth+20,
            height: screenHeight+20)
        backgroundImage.contentMode = UIViewContentMode.scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    func createIcon() {
        print("Creating Icon.")
        // Get Screen Bounds
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let iconImage = UIImageView(image: UIImage(named: "logoIcon.png"))
        iconImage.frame = CGRect(x: screenWidth*0.2, y: screenHeight*0.05, width: screenWidth*0.6, height: screenHeight*0.3)
        iconImage.contentMode = .scaleAspectFit
        self.view.addSubview(iconImage)
        
        let iconText = UIImageView(image: UIImage(named: "newLogoText.png"))
        iconText.frame = CGRect(x: screenWidth*0.02, y: screenHeight*0.3, width: screenWidth*0.96, height: screenHeight*0.2)
        iconText.contentMode = .scaleAspectFit
        self.view.addSubview(iconText)
    }
    func createLoginFieldsAndButtons() {
        // Get Screen Bounds
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Container for Login
        let loginContainer = UIView()
        loginContainer.frame = CGRect(x: 0, y: screenHeight*0.1, width: screenWidth, height: screenHeight)
        self.view.addSubview(loginContainer)
        
        // Insert White Rounded Rectangle
        let loginBackgroundImageView = UIImageView()
        loginBackgroundImageView.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.39, width: screenWidth*0.9, height: screenHeight*0.15)
        loginBackgroundImageView.backgroundColor = UIColor.white
        loginBackgroundImageView.layer.cornerRadius = 7
        loginContainer.insertSubview(loginBackgroundImageView, at: 2)
        
        // Insert Username Text Field
        userNameTextField.frame = CGRect(x: screenWidth*0.25, y: screenHeight*0.4, width: screenWidth*0.68, height: screenHeight*0.06)
        userNameTextField.backgroundColor = UIColor.white
        userNameTextField.layer.cornerRadius = CGFloat(7)
        userNameTextField.textAlignment = NSTextAlignment.left
        userNameTextField.placeholder = "Your Email"
        userNameTextField.keyboardType = UIKeyboardType.emailAddress
        userNameTextField.tag = 0
        userNameTextField.addTarget(nil, action: #selector(LoginViewController.firstResponderAction(_:)), for: .editingDidEnd)
        self.textFields.append(userNameTextField)
        loginContainer.insertSubview(userNameTextField, at: 3)
        
        // Insert Password Text Field
        passwordTextField.frame = CGRect(x: screenWidth*0.25, y: screenHeight*0.47, width: screenWidth*0.68, height: screenHeight*0.06)
        passwordTextField.backgroundColor = UIColor.white
        passwordTextField.layer.cornerRadius = CGFloat(7)
        passwordTextField.textAlignment = NSTextAlignment.left
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.tag = 1
        passwordTextField.addTarget(nil, action: #selector(LoginViewController.firstResponderAction(_:)), for: .editingDidEnd)
        self.textFields.append(passwordTextField)
        loginContainer.insertSubview(passwordTextField, at: 4)
        
        // Insert Username Image Icon
        let usernameImageView = UIImageView(image: UIImage(named: "usernameIcon.png"))
        usernameImageView.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.399, width: screenWidth*0.2, height: screenHeight*0.07)
        usernameImageView.contentMode = UIViewContentMode.scaleAspectFit
        loginContainer.insertSubview(usernameImageView, at: 5)
        
        // Insert Password Image Icon
        let passwordImageView = UIImageView(image: UIImage(named: "passwordIcon.png"))
        passwordImageView.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.47, width: screenWidth*0.2, height: screenHeight*0.06)
        passwordImageView.contentMode = UIViewContentMode.scaleAspectFit
        loginContainer.insertSubview(passwordImageView, at: 6)
        
        // Insert Buttons Container
        let container = UIView()
        container.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.545, width: screenWidth*0.90, height: screenWidth*0.16)
        container.layer.cornerRadius = CGFloat(5)
        container.backgroundColor = UIColor.white
        container.layer.masksToBounds = true
        loginContainer.insertSubview(container, at: 7)
        
        // Insert LogIn Button
        let logInButton = UIButton(type: UIButtonType.custom)
        logInButton.frame = CGRect(x: 0, y: 0, width: 2*container.frame.width/3, height: container.frame.height)
        logInButton.backgroundColor = UIColor(red: 146/255, green: 25/255, blue: 68/255, alpha: CGFloat(1))
        logInButton.setTitle("Login In", for: UIControlState())
        logInButton.addTarget(self, action: #selector(LoginViewController.loginIn), for: UIControlEvents.touchUpInside)
        container.addSubview(logInButton)
        
        // Insert Register Button
        let registerButton = UIButton(type: UIButtonType.custom)
        registerButton.frame = CGRect(x: 2*container.frame.width/3, y: 0, width: container.frame.width/3, height: container.frame.height)
        registerButton.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: CGFloat(1))
        registerButton.setTitle("Register", for: UIControlState())
        registerButton.addTarget(self, action: #selector(LoginViewController.signUpIn), for: UIControlEvents.touchUpInside)
        container.addSubview(registerButton)
        
        // Insert Forgot Password Button
        let forgotPasswordButton = UIButton(type: UIButtonType.custom)
        forgotPasswordButton.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.74, width: screenWidth*0.90, height: screenHeight*0.05)
        forgotPasswordButton.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: CGFloat(0))
        forgotPasswordButton.setTitle("Esqueci minha senha.", for: UIControlState())
        forgotPasswordButton.addTarget(self, action: #selector(LoginViewController.forgotPassword), for: UIControlEvents.touchUpInside)
        self.view.addSubview(forgotPasswordButton)
        
        
        // Insert Facebook Button
        let facebookSignInButton = UIButton(type: UIButtonType.custom)
        facebookSignInButton.frame = CGRect(x: screenWidth*0.05, y: screenHeight*0.7, width: screenWidth*0.90, height: screenWidth*0.16)
        facebookSignInButton.layer.cornerRadius = 7
        facebookSignInButton.setBackgroundImage(UIImage(named: "facebookSignInIcon.png"), for: UIControlState())
        facebookSignInButton.addTarget(self, action: #selector(LoginViewController.facebookLoginIn), for: UIControlEvents.touchUpInside)
        loginContainer.insertSubview(facebookSignInButton, at: 8)
        print("Created Login Fields and Buttons.")
    }
    func firstResponderAction(_ textField: UITextField!) -> Bool {
        // To turn off keyboard
        me.setEmail(userNameTextField.text!)
        me.setPassword(passwordTextField.text!)
        textField.resignFirstResponder()
        print("Keyboard Dismissed.")
        return true
    }

    
    
    // MARK: Login In Application

    func loginIn() {
        self.view.endEditing(true)
        me.loginIn(self)
    }
    func facebookLoginIn() {
        me.facebookLoginIn()
    }
    func signUpIn() {
        me.signIn(self)
    }
    func forgotPassword() {
        me.forgotPassword(self)
    }
    
    
    deinit {
        print("LoginViewController has been deinitialized.")
    }



}
