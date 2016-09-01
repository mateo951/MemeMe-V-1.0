//
//  ViewController.swift
//  MemeMe V 1.0
//
//  Created by Mateo Villagomez on 1/30/16.
//  Copyright © 2016 Mateo Villgomez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageRetrieved: UIImageView!
    @IBOutlet weak var upperTextField: UITextField!
    @IBOutlet weak var lowerTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    struct Meme {
        let topText: String
        let lowerText: String
        let originalImage: UIImage
        let memedImage: UIImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the delegates
        self.upperTextField.delegate = self
        self.lowerTextField.delegate = self
        // Default text of textFields
        upperTextField.text = "Up"
        lowerTextField.text = "Down"
        // Default text Attributes
        let textAttributes = [
            NSStrokeColorAttributeName: UIColor.whiteColor(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: 0
        ]
        upperTextField.defaultTextAttributes = textAttributes
        lowerTextField.defaultTextAttributes = textAttributes
        // Align text
        upperTextField.textAlignment = .Center
        lowerTextField.textAlignment = .Center
    }
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if (imageRetrieved.image != nil) {
            shareButton.enabled = true
        } else {
            shareButton.enabled = false
        }
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    // Cancel Button 
    @IBAction func cancelButton(sender: AnyObject) {
        imageRetrieved.image = nil
        upperTextField.text = "Up"
        lowerTextField.text = "Down"
    }
    
    // Presenting Views
    @IBAction func presentView(sender: AnyObject) {
        let controller = UIImagePickerController()
        // Image Picker
        if sender.tag == 0 {
            controller.delegate = self
            controller.sourceType = .PhotoLibrary
            presentViewController(controller, animated: true, completion: nil)
        }
        // Camera Picker
        if sender.tag == 1 {
            controller.delegate = self
            controller.sourceType = .Camera
            presentViewController(controller, animated: true, completion: nil)
        }
        // Activity View 
        if sender.tag == 2 {
            let controller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
            self.presentViewController(controller, animated: true, completion: nil)
            controller.completionWithItemsHandler = { activityType, completed, returnedItems, error -> () in
                self.save()
            }
        }
    }
    // Displaying selected image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageRetrieved.contentMode = .ScaleAspectFill
            imageRetrieved.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // Subscribing class to recieve the notification
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    // Getting keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    // Shifting view's frame up
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    // Returning the view to it original state
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    // Unsubscribing
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func generateMemedImage() -> UIImage {
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("memedImage generated")
        return memedImage
    }
    
    func save() {
        //Create the meme
        let meme = Meme(topText: self.upperTextField.text!, lowerText: self.lowerTextField.text!, originalImage:
            self.imageRetrieved.image!, memedImage: generateMemedImage())
        print("meme saved")
    }
}











