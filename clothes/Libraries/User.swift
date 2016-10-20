//
//  User.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 19/08/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import Foundation
import UIKit
import Parse

class User {
    
    fileprivate var spot: Int!
    fileprivate var email: String!
    fileprivate var password: String!
    
    init() {
        self.spot = 0
        self.email = ""
        self.password = ""
    }
    
    // Setters
    func setEmail(_ email: String) {
        self.email = email
        print("User email is \(self.email)")
    }
    func setPassword(_ password: String) {
        self.password = password
    }
    func setSpot(_ newSpot: Int) {
        let user = PFUser.current()!
        user["spot"] = newSpot
        user.saveInBackground(block: { (success, error) -> Void in
            if success {
                self.spot = newSpot
                print("Saved new spot value of \(self.spot)")
            }
        })
    }
    
    // Getters
    func getEmail() -> String {
        return self.email
    }
    func getPassword() -> String {
        return self.password
    }
    func getSpot() -> Int {
        let user = PFUser.current()!
        if let userSpot = user["spot"] as? Int {
            self.spot = userSpot
            return spot
        } else {
            return 0
        }
    }
    
    // Actions
    func loginIn(_ loginController: UIViewController) {
        print("\nSEARCHING USER IN SERVER")
        let query = PFUser.query()
        query?.whereKey("email", equalTo: self.email)
        query?.findObjectsInBackground { (objects, error) -> Void in
            if let objects = objects {
                if objects.count == 0 {
                    print("User email: \(self.getEmail()) not found in server.")
                    Alert(controller: loginController).message("Ops!", message: "Usuário não encontrado", confirmationTitle: "Digitarei novamente")
                }
            }
            if error != nil {
                print("Error while searching user: \(error)")
                
            } else if let users = objects {
                if let user = users[0] as? PFUser {
                    print("User \(user.username) has been found in server.\nLogging In ... Please Wait.")
                    PFUser.logInWithUsername(inBackground: user.username!, password: self.password) { (user, error) -> Void in
                        if user != nil {
                            print("User logged in successfully.")
                            Alert(controller: loginController).loginSucessful()
                            self.enterInApp()
                        } else {
                            print("It was not possible to log in user because password is incorrect or user is already logged.")
                            Alert(controller: loginController).message("Ops!", message: "Senha incorreta ou Usuário já está logado", confirmationTitle: "Hum...")
                        }
                    }
                }
            }
        }
    }
    func signIn(_ loginController: UIViewController) {
        print("\nSIGNING UP USER IN SERVER")
        
        print("Verifying that fields are filled.")
        if (email == "" || password == "") {
            print("Not possible to register, one or both fields are blank.")
            Alert(controller: loginController).message("Ops!", message: "Preencha os dois campos", confirmationTitle: "Entendido!")
        }
        else {
            
            let user = PFUser()
            user.email = email
            user.password = password
            user.username = email
            user.signUpInBackground(block: { (success, error) -> Void in
                print("Setting user fields. \n Signing up \(user.email)")
                if let error = error {
                    let errorString = error._userInfo as? NSString
                    Alert(controller: loginController).message("Ops", message: "\(errorString)", confirmationTitle: "=(")
                    print("Error message while trying to signing up user: \(error)")
                } else {
                    Alert(controller: loginController).message("Yeahhh", message: "Você se tornou nosso amigo!", confirmationTitle: "Sim!")
                    User().enterInApp()
                    print("Sign up sucessfull.")
                }
            })
            
        }
    }
    func returnUserData(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print(result)
            }
        })
    }
    func facebookLoginIn() {
        let permissionArray = ["public_profile"]
        PFFacebookUtils.logInInBackground(withReadPermissions: permissionArray) { (user, error) -> Void in
            
            if let error = error {
                print("errour: \(error)")
            } else {
                if let user = user {
                    print("usuario: \(user)")
                    self.enterInApp()
                }
            }
        }
        
        
    }
    func enterInApp() {
        print("\nPREPARING WINDOW")
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        let navigationController = UINavigationController()
        print("Created NavigationController for MyClosets.")
        
        let myVC1 = MyClosets(nibName: "MyClosets", bundle: nil)
        print("Created View Controller for MyClosets.")
        
        print("Adding MyClosetsViewController to Navigation Controller.")
        navigationController.viewControllers = [myVC1]
        navigationController.isNavigationBarHidden = false
        navigationController.navigationBar.barTintColor = AppCustomColor().darkGray
        navigationController.navigationBar.tintColor = AppCustomColor().pink
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController.toolbar.barTintColor = AppCustomColor().darkGray
        navigationController.toolbar.tintColor = AppCustomColor().pink
        navigationController.navigationBar.barStyle = .blackTranslucent
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.init(name: "Klavika", size: 30)!
        ]
        
        navigationController.navigationBar.titleTextAttributes = attributes
        window?.rootViewController = navigationController
        print("Set Navigation Controller as Root View for Window.")
    }
    func forgotPassword(_ loginController: UIViewController) {
        print("\n USER FORGOT PASSWORD.")
        
        print("Verify that email field is filled to send email.")
        if (email == "") {
            Alert(controller: loginController).message("Hum...", message: "Preencha o campo de email com seu email", confirmationTitle: "Vou preencher")
        } else {
            
            PFUser.requestPasswordResetForEmail(inBackground: email, block: { (success, error) in
                if success {
                    let resetPasswordMailSentPrompt = UIAlertController(title: "Solicitação Enviada", message: "Enviamos um link de reset de password para seu email", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    resetPasswordMailSentPrompt.addAction(okButton)
                    loginController.present(resetPasswordMailSentPrompt, animated: true, completion: nil)
                    print("Mail with new password sent to email.")
                }
            })
        }
    }
    func logOut() {
        print("\nLOG OUT")
        PFUser.logOut()
        print("User logged out.")
        
        print("Destroying all View Controllers inside Window")
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        if let _ = window {
            for view in window!.subviews {
                view.removeFromSuperview()
            }
        }
        
        print("Setting LoginViewController as Root View for Window")
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        window?.rootViewController = loginViewController
        
    }
    

    deinit {
        if self.email == "" {
            print("User instance has been deinitialized.")
        } else {
            print("User \(self.email) has been deinitialized.")
        }
    }
    


    
}
