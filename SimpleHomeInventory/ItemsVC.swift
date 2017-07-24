//
//  ItemsVC.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/20/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ItemsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
        
    @IBOutlet weak var bannerView: GADBannerView!
    
    let userID = FIRAuth.auth()?.currentUser?.uid
        
    //variable declarations
    var newUser:Bool = false
    var rows = [Item]()

    var roomKey = ""
    var userEmail = ""
    var removeAdsPurchaseMade = UserDefaults.standard.bool(forKey: "removeAdsPurchaseMade")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !removeAdsPurchaseMade {
            bannerView.isHidden = false
            
            print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
            //bannerView.adUnitID = "ca-app-pub-3809708679767353/4570568822"
            //next line for  testing with google generic ad unit ID - switch this line with above line to test with app specific id
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            
            bannerView.rootViewController = self
            
            //for testing - comment next 2 lines when in production
            let request = GADRequest()
            request.testDevices = ["20772f88b782089d08cebddb998568bfd30c"]
            
            bannerView.load(GADRequest())
        }
        else {
            bannerView.isHidden = true
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 30

        DataService.ds.REF_ITEMS.observe(.value, with: {snapshot in
            self.rows = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let item = Item(itemkey: key, dictionary: itemDict)
                        if item.roomkey == self.roomKey {
                            self.rows.append(item)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
        
    @IBAction func buttonNew(_ sender: Any) {
        let itemData = ["item": "", "value": "", "itemKey": "", "roomKey": roomKey]
        performSegue(withIdentifier: "segueToNewItem", sender: itemData)
    }
    
    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
            
        if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as? ItemCell {
            cell.configureCellS(item: row)
            return cell
        }
        else {
            return ItemCell()
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            let row = self.rows[indexPath.row]
            let itemData = ["item": row.item, "value": row.value, "itemKey": row.itemkey, "roomKey": row.roomkey]
            
            self.performSegue(withIdentifier: "segueToNewItem", sender: itemData)
            
        }
        edit.backgroundColor = UIColor.lightGray
        
        let del = UITableViewRowAction(style: .normal, title: "Del") { action, index in
            
            let row = self.rows[indexPath.row]
            let itemID = row.itemkey
            DataService.ds.REF_ITEMS.child(itemID).removeValue()
            tableView.reloadData()
            
        }
        del.backgroundColor = UIColor.red
        
        return [edit, del]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToNewItem" {
            guard let navVC = segue.destination as? UINavigationController,
                let destVC = navVC.topViewController as? NewItemVC else {
                    return
            }
            
            let itmdata = sender as? Dictionary<String, String>
            
            if itmdata != nil {
                destVC.item = (itmdata?["item"])!
                destVC.value = (itmdata?["value"])!
                destVC.itemKey = (itmdata?["itemKey"])!
                destVC.roomKey = (itmdata?["roomKey"])!
                destVC.userEmail = userEmail
            }
        }
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

}
