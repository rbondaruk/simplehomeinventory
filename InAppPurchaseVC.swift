//
//  InAppPurchaseVC.swift
//  SimpleHomeInventory
//
//  Created by fred on 7/20/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import StoreKit
import Firebase
import FirebaseDatabase

class InAppPurchaseVC: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let InventoryReportID = "com.bondaruk.SimpleHomeInventory.InventoryReport"
    let UnlimitedRoomsID = "com.bondaruk.SimpleHomeInventory.UnlimitedRooms"
    let RemoveAdsID = "com.bondaruk.SimpleHomeInventory.RemoveAds"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var unlimitedRoomsPurchaseMade = UserDefaults.standard.bool(forKey: "unlimitedRoomsPurchaseMade")
    var removeAdsPurchaseMade = UserDefaults.standard.bool(forKey: "removeAdsPurchaseMade")
    var inventoryReport = UserDefaults.standard.integer(forKey: "InventoryReport")
    
    @IBOutlet weak var labelUnlimitedPrice: UILabel!
    
    @IBOutlet weak var labelReportPrice: UILabel!
    
    @IBOutlet weak var labelRemoveAdsPrice: UILabel!
    
    @IBOutlet weak var unlimitedRoomButton: UIButton!
    
    @IBOutlet weak var removeAdsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("UNLIMITED ROOMS PURCHASE MADE: \(unlimitedRoomsPurchaseMade)")
        print("REMOVE ADS PURCHASE MADE: \(removeAdsPurchaseMade)")
        print("INVENTORY REPORT: \(inventoryReport)")
        
        if unlimitedRoomsPurchaseMade {
            unlimitedRoomButton.isHidden = true
            labelUnlimitedPrice.isHidden = true
        }
        else {
            unlimitedRoomButton.isHidden = false
            labelUnlimitedPrice.isHidden = false
        }
        
        if removeAdsPurchaseMade {
            removeAdsButton.isHidden = true
            labelRemoveAdsPrice.isHidden = true
        }
        else {
            removeAdsButton.isHidden = false
            labelRemoveAdsPrice.isHidden = false
        }
        
        fetchAvailableProducts()
        
        //labelUnlimitedPrice.text = "$4.99"
        //labelReportPrice.text = "$0.99"
        //labelRemoveAdsPrice.text = "$0.99"
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonUnlimited(_ sender: Any) {
        purchaseMyProduct(product: iapProducts[2])
    }

    @IBAction func buttonReport(_ sender: Any) {
        purchaseMyProduct(product: iapProducts[0])
    }
    
    @IBAction func buttonRemoveAds(_ sender: Any) {
        purchaseMyProduct(product: iapProducts[1])
    }
    
    @IBAction func buttonRestore(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        unlimitedRoomsPurchaseMade = true
        UserDefaults.standard.set(unlimitedRoomsPurchaseMade, forKey: "unlimitedRoomsPurchaseMade")
        removeAdsPurchaseMade = true
        UserDefaults.standard.set(removeAdsPurchaseMade, forKey: "removeAdsPurchaseMade")
        
        popup(title: "Info", msg: "You've successfully restored your purchases!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchAvailableProducts() {
        
        let productIdentifiers = NSSet(objects:
            InventoryReportID,
            UnlimitedRoomsID,
            RemoveAdsID
        )

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func popup(title: String, msg:String) {
        let alertVC = UIAlertController(
            title: title,
            message: msg,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            
            // 1st IAP Product (Consumable) ------------------------------------
            let firstProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            
            // Show its description the following line of code can be used to localize button descriptions
            //labelReportPrice.text = firstProduct.localizedDescription + "\nfor just \(price1Str!)"
            labelReportPrice.text = price1Str
            // ------------------------------------------------
            
            // 2nd IAP Product (Non-Consumable) ------------------------------
            let secondProd = response.products[1] as SKProduct
            
            // Get its price from iTunes Connect
            numberFormatter.locale = secondProd.priceLocale
            let price2Str = numberFormatter.string(from: secondProd.price)
            
            // Show its description
            labelRemoveAdsPrice.text = price2Str
            // ------------------------------------
            
            // 3rd IAP Product (Consumable) ------------------------------
            let thirdProd = response.products[2] as SKProduct
            
            // Get its price from iTunes Connect
            numberFormatter.locale = thirdProd.priceLocale
            let price3Str = numberFormatter.string(from: thirdProd.price)
            
            // Show its description
            labelUnlimitedPrice.text = price3Str
            // ------------------------------------
        }
    }
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
            
            // IAP Purchases disabled on the Device
        } else {
            popup(title: "Info", msg: "Purchases are disabled in your device!")
        }
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Consumable product Inventory Report has been purchased
                    if productID == InventoryReportID {
                        
                        // insert code later to generate the inventory report
                        
                        popup(title: "Info", msg: "Report Purchased")
                        
                    // The Non-Consumable product Unlimited Rooms has been purchased!
                    } else if productID == UnlimitedRoomsID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        unlimitedRoomsPurchaseMade = true
                        UserDefaults.standard.set(unlimitedRoomsPurchaseMade, forKey: "unlimitedRoomsPurchaseMade")
                        
                        popup(title: "Info", msg: "Unlimited rooms unlocked!")
                        
                    } else if productID == RemoveAdsID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        removeAdsPurchaseMade = true
                        UserDefaults.standard.set(removeAdsPurchaseMade, forKey: "removeAdsPurchaseMade")
                        
                        popup(title: "Info", msg: "Ads Removed")
                        
                    }
                    
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
