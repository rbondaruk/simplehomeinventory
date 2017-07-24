//
//  Item.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/20/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Item {
    private var _item: String!
    private var _value: String!
    
    private var _itemkey: String!
    private var _roomkey: String!
    private var _userEmail: String!
    
    private var _itemRef: FIRDatabaseReference!
    
    var item: String {
        return _item
    }
    
    var value: String {
        return _value
    }
    
    var itemkey: String {
        return _itemkey
    }
    
    var roomkey: String {
        return _roomkey
    }
    
    var userEmail: String {
        return _userEmail
    }
    
    init(item:String, value:String, userID:String) {
        self._item = item
        self._value = value
        self._roomkey = roomkey
        self._userEmail = userEmail
    }
    
    init(itemkey: String, dictionary: Dictionary<String, AnyObject>) {
        self._itemkey = itemkey
        
        if let itm = dictionary ["item"] as? String {
            self._item = itm
        }
        
        if let val = dictionary ["value"] as? String {
            self._value = val
        }
        
        if let rk = dictionary ["roomkey"] as? String {
            self._roomkey = rk
        }
        
        if let usr = dictionary ["userEmail"] as? String {
            self._userEmail = usr
        }
        
        self._itemRef = DataService.ds.REF_ITEMS.child(self._itemkey)
    }
}
