//
//  ItemValue.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/22/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class ItemValue {
    private var _item: String!
    private var _value: String!
    private var _itemValuekey: String!
    
    private var _itemValueRef: FIRDatabaseReference!
    
    var item: String {
        return _item
    }
    
    var value: String {
        return _value
    }
    
    var itemValuekey: String {
        return _itemValuekey
    }
    
    init(item:String, value:String) {
        self._item = item
        self._value = value
    }
    
    init(itemValuekey: String, dictionary: Dictionary<String, AnyObject>) {
        self._itemValuekey = itemValuekey
        
        if let itm = dictionary ["item"] as? String {
            self._item = itm
        }
        
        if let val = dictionary ["value"] as? String {
            self._value = val
        }
        
        self._itemValueRef = DataService.ds.REF_ITEMS.child(self._itemValuekey)
    }
}
