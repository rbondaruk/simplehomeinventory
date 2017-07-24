//
//  ViewController.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/19/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class SignInVC: UIViewController {

    @IBOutlet weak var textEmail: UITextField!
    
    @IBOutlet weak var textPwd: UITextField!
    
    var userEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonFBLogin(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn (withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil {
                //print ("Facebook login failed. Error \(error)")
                self.popup(title: "Login Error", msg: "Facebook login failed")
            }
            else {
                let accessToken = FBSDKAccessToken.current().tokenString
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken!)
                self.firebaseAuth(credential)
            }
        }
    }

    @IBAction func buttonEmailLogin(_ sender: Any) {
        let email = textEmail.text
        let pwd = textPwd.text
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: pwd!, completion: {(user, error) in
            if error != nil {
                //print ("Authentication failed: Error \(error)")
                self.popup(title: "Login Error", msg: "Email login failed")
            }
            else {
                if let user = user {
                    let userData = ["provider": user.providerID, "email": user.email]
                    self.userEmail = user.email!
                    self.completeSignIn(user.uid, userData: userData as! Dictionary<String, String>)
                }
            }
        })
    }

    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase: Error \(error)")
                self.popup(title: "Login Error", msg: "System authentication failed")
            }
            else {
                if let user = user {
                    let userData = ["provider": credential.provider, "email": user.email ]
                    self.userEmail = user.email!
                    self.completeSignIn(user.uid, userData: userData as! Dictionary<String, String>)
                }
            }
        })
    }
    
    func completeSignIn(_ id: String, userData: Dictionary<String, String>) {
        // this line creates a user in the firebase db based on the FB user info
        DataService.ds.createFirebaseUser(id, userData: userData)
        
        //let keychainResult = KeychainWrapper.standard.set(id, forKey, KEY_UID)
        //print("Data saved to keychain \(keychainResult)")
        
        performSegue(withIdentifier: "segueToRooms", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToRooms" {
            guard let navVC = segue.destination as? UINavigationController,
                let destVC = navVC.topViewController as? roomsVC else {
                    return
            }
            
            destVC.userEmail = userEmail

        }
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
    
}



