//
//  NewItemVC.swift
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

class NewItemVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var lblValue: UILabel!
    
    @IBOutlet weak var pickerItem: UIPickerView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var pData = [ItemValue]()
    var pickerData: [String] = []
    var newItem = true
    var cnt = -1
    var pickerrow = 0
    
    // variables to receive data from the tableview
    var item = ""
    var value = ""
    var roomKey = ""
    var itemKey = ""
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
        
        DataService.ds.REF_ITEM_VALUES.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let pickDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let itv = ItemValue(itemValuekey: key, dictionary: pickDict)
                        self.pickerData.append(itv.item)
                        self.pData.append(itv)
                    }
                }
            }
        })
        
        pickerItem.dataSource = self
        pickerItem.delegate = self

        lblValue.text = value
        
        if itemKey == "" {
            newItem = true
        }
        else {
            newItem = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        pickerData = pickerData.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        if newItem == true {
            item = pickerData.first!
            pickerrow = 0
            for p in pData {
                if p.item == item {
                    lblValue.text = p.value
                    value = p.value
                }
            }
        }
        else {
            for pick in pickerData {
                cnt += 1
                if pick == item {
                    pickerrow = cnt
                }
            }
        }
        
        pickerItem.reloadAllComponents()
        pickerItem.selectRow(pickerrow, inComponent: 0, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSubmit(_ sender: Any) {

        self.postToFirebase()
        dismiss(animated: true, completion: nil)
    }
    
    //to dismiss the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func postToFirebase() {
        
        //first we create a dictionary
        let item: Dictionary<String, AnyObject> = [
            //"item": textItem.text! as AnyObject,
            "item": self.item as AnyObject,
            "value": self.value as AnyObject,
            "roomkey": roomKey as AnyObject,
            "userEmail": userEmail as AnyObject
        ]
        
        if newItem {
            DataService.ds.REF_ITEMS.childByAutoId().setValue(item)
        }
        else {
            DataService.ds.REF_ITEMS.child(itemKey).setValue(item)
        }
    }
    
    // setup the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
        //return picker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
        //return picker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        item = pickerData[row]
        
        for p in pData {
            if p.item == item {
                lblValue.text = p.value
                value = p.value
            }
        }
        
        //item = picker[row]
    }
    
    // The number of columns in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
