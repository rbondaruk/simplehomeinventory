//
//  SignUpVC.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/19/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpVC: UIViewController {

    @IBOutlet weak var textEmail: UITextField!
    
    @IBOutlet weak var textPwd: UITextField!
    
    @IBOutlet weak var textPwd2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonSubmit(_ sender: Any) {
        if String(describing: textPwd.text) != String(describing: textPwd2.text) {
            popup(title: "Password Error", msg: "Sorry, the passwords do not match")
        }
        else {
            let email = textEmail.text
            let pass = textPwd.text
            
            FIRAuth.auth()?.createUser(withEmail: email!, password: pass!, completion: { (user, error) in
                if error != nil {
                    print("Unable to create user: \(error)")
                    self.popup(title: "Setup Error", msg: "Unable to create your user account")
                }
                else {
                    print("Successfully created user")
                    if let user = user {
                        let userdata = ["provider" : user.providerID, "email": user.email]
                        DataService.ds.createFirebaseUser(user.uid, userData: userdata as! Dictionary<String, String>)
                    }
                }
            })
            
        }
        dismiss(animated: true, completion: nil)  // dismisses the modal view
    }
    
    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // insert these two functions to close the keyboard on editing text fields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
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
