//
//  NewRoomVC.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/19/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class NewRoomVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // need to add code to handle editing the room
    // need to load new pic to firebase and delete old one when pic changed
    // need to update save data in firebase on edit of room using roomID
    // need to only childByAutoId for save on new room

    @IBOutlet weak var textRoom: UITextField!
    
    @IBOutlet weak var textLocation: UITextField!
    
    @IBOutlet weak var imgRoom: UIImageView!

    @IBOutlet weak var bannerView: GADBannerView!
    
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    var newRoom = true
    
    // variables to receive data from the tableview
    var room = ""
    var loc = ""
    var imgURL = ""
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

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        textRoom.text = room
        textLocation.text = loc
        
        // use the following code to get image data from firebase storage
        if imgURL != "" {
            let ref = FIRStorage.storage().reference(forURL: imgURL)
            ref.data(withMaxSize: 2*1024*1024, completion: { (data, error) in
                if error != nil {print("Unable to download image")}
                else {
                    if let imageData = data {
                        if let img = UIImage(data: imageData) {
                            self.imgRoom.image = img
                            self.newRoom = false
                        }
                    }
                }
            })
        }
        else {
            print("ImageUrl is nil")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonSubmit(_ sender: Any) {
        
        guard let room = textRoom.text, room != "" else {
            popup(title: "Missing Data", msg: "Sorry, please enter a room name")
            return
        }
        
        guard let loc = textLocation.text, loc != "" else {
            popup(title: "Missing Data", msg: "Sorry, please enter a location")
            return
        }
        
        let img = imgRoom?.image
        if imageSelected == true {
            if let imgData = UIImageJPEGRepresentation(img!, 0.2) {
                let imgUid = NSUUID().uuidString
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                DataService.ds.REF_ROOM_PICS.child(imgUid).put(imgData, metadata:metaData as FIRStorageMetadata?) {(metadata, error) in
                    
                    if error != nil {
                        print("Image was not uploaded to Firebase")
                    }
                    else {
                        print("Image successfully uploaded to Firebase")
                        let downloadUrl = metadata?.downloadURL()?.absoluteString
                        if let url = downloadUrl {
                            
                            self.postToFirebase(imgUrl: url)
                        }
                    }
                }
            }
            
        }
        else {
            // when the user doens't add an image need to send nothing to firebase
            let url = ""
            self.postToFirebase(imgUrl: url)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker,animated: true,completion: nil)
        } else {
            //no Camera
            popup(title: "No Camera", msg: "Sorry, this device has no camera")
        }
    }

    @IBAction func buttonLibrary(_ sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.modalPresentationStyle = .currentContext
        present(imagePicker, animated: true, completion: nil)
        imagePicker.popoverPresentationController?.barButtonItem = sender
    }
    
    @IBAction func imageTouched(_ sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker,animated: true,completion: nil)
        } else {
            //no Camera
            popup(title: "No Camera", msg: "Sorry, this device has no camera")
        }
    }
    
    //the next two function are to dismiss the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textRoom.resignFirstResponder()
        textLocation.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgRoom?.image = image
            imageSelected = true
        }
        else {
            popup(title: "Photo Error", msg: "There was error getting your picture")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func postToFirebase(imgUrl:String) {
        
        //first we create a dictionary
        var room: Dictionary<String, AnyObject> = [
            "room": textRoom.text! as AnyObject,
            "location": textLocation.text! as AnyObject,
            "userEmail": userEmail as AnyObject
        ]
        
        if imageSelected == true {
            room["imageUrl"] = imgUrl as AnyObject
        }
        else {
            room["imageUrl"] = "" as AnyObject
        }
        
        DataService.ds.REF_ROOMS.childByAutoId().setValue(room)
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
