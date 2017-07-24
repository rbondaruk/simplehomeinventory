//
//  RoomsVC.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/19/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

/*
 To Do List
 
 DONE - 0. Only show rooms for the current user
 DONE - 1. Setup the image view on the NewRoomVC to open the camera by default
 DONE - 2. Make the items list a picker of default items
 Done - 3. Setup code to pull the value based on the item picked in step 2 above
 Done - 4. Look into Admob to run adds in the tableviews
 5. Create a video to show how to use the app
 6. How to use Blade to setup images
 7. Deploy app to Apple App Store
 DONE - 10. Add labels to the NewItemVC
 11. Change the background color of the app to something other than white
 DONE - 14. Fix Items in Firebase to have userEmail and not userID on NewItemVC
 DONE - 15. Fix room filter for email login
 16. Limit users to 4 pics unless they buy the app
 DONE - 18. Initcap on the Room and Location fields
 DONE - 19. Center the value field on NewItem VC. Add a $ to the value.  Make the text size match the picker
 23. Autoprocess Facebook Login
 
 
 HOLD
 13. Fix back button on navigation to work on all VCs
 20. Add in a splash screen showing the # of rooms, # of items, and $$ value
 21. Add in a report pack for inApp purchase
  8. Close room and item selection for edit/delete after option is selected
  9. Tap on pic in RoomsVC tableview list to open room
  12. Make Admin screen to bulk upload ITEM_VALUES data to Firebase as well as edit individual data nodes
  17. Buildout reporting capabilities
 22. Fix ads to work in landscape mode
 23. Check-boxes for items
 
 */

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class roomsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonAdmin: UIBarButtonItem!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var buttonAddRoom: UIBarButtonItem!
    
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    //variable declarations
    var userEmail = ""
    var newUser:Bool = false
    var rows = [Room]()
    var rowsR = [Room]() // needed for sort the special posts by date
    var tblCnt = 0
    var unlimitedRoomsPurchaseMade = UserDefaults.standard.bool(forKey: "unlimitedRoomsPurchaseMade")
    var removeAdsPurchaseMade = UserDefaults.standard.bool(forKey: "removeAdsPurchaseMade")
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
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
        
        buttonAdmin.isEnabled = false
        buttonAdmin.tintColor = UIColor.clear
        
        if userEmail == "bondarukdev@gmail.com" {
            buttonAdmin.isEnabled = true
            buttonAdmin.tintColor = nil
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        
        DataService.ds.REF_ROOMS.observe(.value, with: {snapshot in
            self.rows = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let roomDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let room = Room(roomkey: key, dictionary: roomDict)
                        if room.userEmail == self.userEmail as String {
                            self.rows.append(room)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

    @IBAction func buttonAdmin(_ sender: Any) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell") as? RoomCell {
            if let img = roomsVC.imageCache.object(forKey: row.imgURL as NSString) {
                cell.configureCellS(room: row, img: img)
            }
            else {
                cell.configureCellS(room: row)
            }
            return cell
        }
        else {
            return RoomCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let add = UITableViewRowAction(style: .normal, title: "Items") { action, index in
            
            let row = self.rows[indexPath.row]
            let roomKey = row.roomkey
            
            self.performSegue(withIdentifier: "segueToItems", sender: roomKey)
        }
        add.backgroundColor = UIColor.blue
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
         
            let row = self.rows[indexPath.row]
            let roomData = ["room": row.room, "loc": row.location, "imgurl": row.imgURL]
 
            self.performSegue(withIdentifier: "segueToNewRoom", sender: roomData)
        
            //self.performSegue(withIdentifier: "segueToNewRoom", sender: nil)
        }
        edit.backgroundColor = UIColor.lightGray
        
        let del = UITableViewRowAction(style: .normal, title: "Del") { action, index in
            
            let row = self.rows[indexPath.row]
            let roomID = row.roomkey
            DataService.ds.REF_ROOMS.child(roomID).removeValue()
            tableView.reloadData()
            
            DataService.ds.REF_ITEMS.observe(.value, with: {snapshot in
                
                if let iSnapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for iSnap in iSnapshots {
                        if let itemDict = iSnap.value as? Dictionary<String, AnyObject> {
                            let key = iSnap.key
                            let item = Item(itemkey: key, dictionary: itemDict)
                            if item.roomkey == roomID {
                                DataService.ds.REF_ITEMS.child(item.itemkey).removeValue()
                            }
                        }
                    }
                }
             })
        }
        del.backgroundColor = UIColor.red
        
        return [add, edit, del]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToNewRoom" {
            
            tblCnt = getAllRowCount()
            
            if tblCnt >= 2 && !unlimitedRoomsPurchaseMade {
                popup(title: "Info",msg: "The free version of the app is limited to 2 rooms.  You can purchase more rooms with an in-app purchase.")
            }
            else {
            
            guard let navVC = segue.destination as? UINavigationController,
                let destVC = navVC.topViewController as? NewRoomVC else {
                    return
            }
            
            let rmdata = sender as? Dictionary<String, String>
            
            destVC.userEmail = userEmail
            
            if rmdata != nil {
                destVC.room = (rmdata?["room"])!
                destVC.loc = (rmdata?["loc"])!
                destVC.imgURL = (rmdata?["imgurl"])!
            }
            }
        }
        else if segue.identifier == "segueToItems" {
            guard let navVC = segue.destination as? UINavigationController,
                let destVC = navVC.topViewController as? ItemsVC else {
                    return
            }
            
            let rmkey = sender as? String
            destVC.roomKey = rmkey!
            destVC.userEmail = userEmail
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
    
    func getAllRowCount()->Int{
        var rowCount = 0
        for index in 0...self.tableView.numberOfSections-1{
            rowCount += self.tableView.numberOfRows(inSection: index)
        }
        return rowCount
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
