//
//  AdminVC.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/21/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AdminVC: UIViewController {
    
    let dictItemValues = [
    "King Bed":"$1000",
    "Queen Bed":"$800",
    "Double Bed":"$600",
    "Twin Bed":"$400",
    "Dressor":"$500",
    "Mirror":"$200",
    "Nightstand":"$200",
    "Refridgerator":"$1000",
    "Stove":"$600",
    "Dishwasher":"$600",
    "Microwave":"$200",
    "Dinning Table":"$700",
    "Dinning Chairs":"$500",
    "Hutch":"$700",
    "Fine China":"$500",
    "Couch":"$1000",
    "Chair":"$400",
    "Coffee Table":"$300",
    "Television":"$1000",
    "Game System":"$300",
    "Bookcase":"$400",
    "Stereo System":"$200",
    "Artwork":"$100",
    "Pool Table":"$500",
    "Desk":"$500",
    "Computer":"$1000",
    "Filing Cabinet":"$200",
    "Bike":"$400",
    "Exercise Equipment":"$200",
    "Car":"$20000",
    "Motorcycle":"$5000",
    "Camping Gear":"$500",
    "Washing Machine":"$500",
    "Dryer":"$500"
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonIVSubmit(_ sender: Any) {
        
        for (item, value) in dictItemValues {
            //first we create a dictionary
            let itemvalue: Dictionary<String, AnyObject> = [
                "item": item as AnyObject,
                "value": value as AnyObject
            ]
            
            DataService.ds.REF_ITEM_VALUES.childByAutoId().setValue(itemvalue)
        }
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
