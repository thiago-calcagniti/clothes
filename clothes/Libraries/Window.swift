//
//  Window.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 30/08/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import Foundation

class Window {
    
    
    func showMenuWithCustomTransition(sender: UIViewController) {
        let transitionManager: TransitionManager = TransitionManager()
        let toViewController = MenuViewController(nibName: "MenuViewController", bundle: nil)
        toViewController.transitioningDelegate = transitionManager
        sender.present(toViewController, animated: true) {
            sender.willMove(toParentViewController: nil)
            sender.removeFromParentViewController()
        }
    }
    
    func showPage(sender: UIViewController, toViewController: UIViewController) {
        let transitionManager: TransitionManager2 = TransitionManager2()
        toViewController.transitioningDelegate = transitionManager
        sender.present(toViewController, animated: true) {
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = appDelegate.window
            let maxIndex = (window?.subviews.count)! - 1
            var index = 0
            for view in (window?.subviews)! {
                if index != maxIndex {
                view.removeFromSuperview()
                index += 1
                } else {
                    break
                }
            }
            sender.willMove(toParentViewController: nil)
            sender.removeFromParentViewController()

            window?.rootViewController = toViewController
        }
    }
    

    func showPage2(destinationController: UIViewController) {
        print("Preparing Window to receive MenuViewController.")
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        
        
        for view in (window?.subviews)! {
            view.removeFromSuperview()
            break
        }
        
        print("Set MenuViewController as root of Window.")
        UIView.transition(
            from: (window?.rootViewController!.view)!,
            to: destinationController.view,
            duration: 0.65,
            options: UIViewAnimationOptions.curveLinear ,
            completion: {
                finished in window?.rootViewController = destinationController
        })
        
        
    }
    
    func showMenu() {
        print("Preparing Window to receive MenuViewController.")
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        let destinationController = MenuViewController(nibName: "MenuViewController", bundle: nil)
        
        print("Set MenuViewController as root of Window.")
        UIView.transition(
            from: (window?.rootViewController!.view)!,
            to: destinationController.view,
            duration: 0.25,
            options: UIViewAnimationOptions.transitionFlipFromLeft ,
            completion: {
                finished in window?.rootViewController = destinationController
        })
    }
    

  
    
    
    
    
    
}
