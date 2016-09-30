//
//  IAPViewController.swift
//  clothes
//
//  Created by Thiago Calcagniti on 23/09/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
// 

import UIKit
import StoreKit

class IAPViewController: UIViewController, SKProductsRequestDelegate, UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver {

    var productsIDs: Array<String> = []
    var productsArray: Array<SKProduct> = []
    var tableView: UITableView! = UITableView()
    
    var selectedProductIndex: Int!
    var transactionInProgress: Bool = false
    
    override func viewDidLoad() {
        
        productsIDs.append("planoBronze")
        requestProductInfo()
        SKPaymentQueue.default().add(self)
        
        
        tableView = UITableView(frame: CGRect(x: 0 ,y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.5 ) , style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.blue.withAlphaComponent(CGFloat(0.5))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
    }
    
    //MARK: In App Purchase
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productsIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot Perform In App Purchases.")
        }
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product as SKProduct)
                print("Product Name:\(product.localizedTitle)\nDescription: \(product.localizedDescription)")
            }
            tableView.reloadData()
            
        }
        else if response.invalidProductIdentifiers.count != 0 {
            print("It was not possible to retrieve products.")
            print(response.invalidProductIdentifiers.description)
        }
    }
    func showActions() {
        if transactionInProgress {
            return
        }
        
        let actionSheetController = UIAlertController(title: "IAP Demo", message: "What would you like to do.", preferredStyle: UIAlertControllerStyle.actionSheet)
        let buyAction = UIAlertAction(title: "Buy?", style: UIAlertActionStyle.default) { (action) -> Void in
            let payment = SKPayment(product: self.productsArray[self.selectedProductIndex] as SKProduct)
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) { (action) -> Void in
            
        }
        actionSheetController.addAction(buyAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true, completion: nil)
        
        
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions as! [SKPaymentTransaction] {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction Completed Sucessfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
            case SKPaymentTransactionState.failed:
                print("Transaction failed.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                print(transaction.error )
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    
    
    //MARK: UITableView DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        cell.textLabel?.text = "\(productsArray[indexPath.item].localizedTitle)\(productsArray[indexPath.item].localizedDescription)"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProductIndex = indexPath.row
        showActions()
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
}
