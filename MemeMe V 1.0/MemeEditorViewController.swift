//
//  MemeEditorViewController.swift
//  MemeMe V 1.0
//
//  Created by Mateo Villagomez on 1/30/16.
//  Copyright © 2016 Mateo Villgomez. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageRetrieved: UIImageView!
    @IBOutlet weak var upperTextField: UITextField!
    @IBOutlet weak var lowerTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the delegates as reviewr asked becuase:
        //upperTextField.delegate = self
        //lowerTextField.delegate = self
        // is repetitive and needs a method
        func setDelegates(delegate: UITextFieldDelegate, textFields: [UITextField]) {
            for i in textFields {
                i.delegate = delegate
            }
        }
        setDelegates(self, textFields: [upperTextField, lowerTextField])
        
        // Default text of textFields
        upperTextField.text = "TOP"
        lowerTextField.text = "BOTTOM"
        
        // Default text Attributes
        let textAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        // Text Configuration Method
        func configureTextFields(textField: [UITextField]) {
            for i in textField {
                i.defaultTextAttributes = textAttributes
                i.textAlignment = .Center
            }
        }
        configureTextFields([upperTextField, lowerTextField])
    }
    
    override func viewWillAppear(animated: Bool) {
        // Cheching if sourceTypeAvailable
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // Cheching for an existing image
        if (imageRetrieved.image != nil) {
            shareButton.enabled = true
        } else {
            shareButton.enabled = false
        }
        
        // Subscribe to keyboard notifications
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
        upperTextField.text = "TOP"
        lowerTextField.text = "BOTTOM"
        shareButton.enabled = false
    }
    // Presenting Views
    @IBAction func presentView(sender: AnyObject) {
        // Couldnt create a method that accepts as an argument 'UIImagePickerControllerSourceType' to avoid repetition
        // Something like this?
        /*func presentView(type: UIImagePickerControllerSourceType) {
            controller.sourceType = type
        }*/
        let controller = UIImagePickerController()
        controller.delegate = self
        // Photo
        if sender.tag == 0 {
            controller.sourceType = .PhotoLibrary
            presentViewController(controller, animated: true, completion: nil)
        }
        // Camera
        if sender.tag == 1 {
            controller.sourceType = .Camera
            presentViewController(controller, animated: true, completion: nil)
        }
        // Activity View
        if sender.tag == 2 {
            let activityC = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
            self.presentViewController(activityC, animated: true, completion: nil)
            activityC.completionWithItemsHandler = { activityType, completed, returnedItems, error -> () in
                if completed {
                    self.save()
                    print("completed")
                }
            }
        }
    }
    // Displaying selected image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageRetrieved.contentMode = .ScaleAspectFit
            imageRetrieved.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    // Returning keyboard with return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // Close keyboard toaching on the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
        if lowerTextField.isFirstResponder(){
            self.view.frame.origin.y = getKeyboardHeight(notification)  * (-1);
            navBar.hidden = true
        }
        else if upperTextField.isFirstResponder(){
            self.view.frame.origin.y = 0
        }
    }
    // Returning the view to it original state
    func keyboardWillHide(notification: NSNotification) {
        if lowerTextField.isFirstResponder() {
            view.frame.origin.y = 0
            navBar.hidden = false
        }
    }
    // Unsubscribing
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func generateMemedImage() -> UIImage {
        // Hiding Toolbar and Nav bar
        navBar.hidden = true
        toolbar.hidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Show 
        navBar.hidden = false
        toolbar.hidden = false
        return memedImage
    }
    func save() {
        //Create the meme
        let meme = Meme(topText: self.upperTextField.text!, lowerText: self.lowerTextField.text!, originalImage:
            self.imageRetrieved.image!, memedImage: generateMemedImage())
    }
}











