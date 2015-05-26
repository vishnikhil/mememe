//
//  MemeEditorViewController.swift
//  MemeMe1
//
//  Created by Vishruti Kekre on 5/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeEditorNavBar: UINavigationBar!
    @IBOutlet weak var memeEditorToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var memeEditorShareButton: UIBarButtonItem!
    
    var memePassedIn : Meme?

    let defaultTopText    = "TOP"
    let defaultBottomText = "BOTTOM"
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
//        NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName : -3.0 // Negative values result in text that is both stroked and filled
    ]
    
    override func viewDidLoad() {
    super.viewDidLoad()
    // Only enable the camera button if the device has a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        topTextField.delegate    = self
        bottomTextField.delegate = self
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment    = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
        
        topTextField.text    = defaultTopText
        bottomTextField.text = defaultBottomText
        
        if let meme = memePassedIn {
            // A meme was passed in from the outside for editing, so
            //  copy its properties out here
            imagePickerView.image = meme.originalImage
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
        }
            memePassedIn = nil
    }
    
    // Don't show the status bar while in the meme editor
    override func prefersStatusBarHidden() -> Bool {
    return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe to keyboard notification, to allow the view to be moved up when the keyboard shows
        self.subscribeToKeyboardNotifications()
        
        if imagePickerView.image == nil {
            memeEditorShareButton.enabled = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.unsubscribeFromKeyboardNotifications()
    }
    
    var currentKeyboardOffset : CGFloat = 0
    func keyboardWillShow(notification: NSNotification) {
        // If the bottom text field is selected, move the view up so
        //  the bottom text will not be covered by the keyboard
        if bottomTextField.isFirstResponder() {
            // The origin (0, 0) is at the top of the screen,
            //  so subtract the keyboardHeight to move the view up.
            //  But first, undo the currentKeyboardOffset. This needs to be done
            //  in case the user is showing or hiding the predictive-text
            //  portion of the keyboard.
            self.view.frame.origin.y += currentKeyboardOffset
            let keyboardHeight = getKeyboardHeight(notification)
            self.view.frame.origin.y -= keyboardHeight
            currentKeyboardOffset = keyboardHeight
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // If the bottom text field is selected, move the view back
        //  to its normal position
        if bottomTextField.isFirstResponder() {
            // The origin (0, 0) is at the top of the screen,
            //  so add the height of the keyboard to move the view down
            self.view.frame.origin.y += getKeyboardHeight(notification)
            currentKeyboardOffset = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of a CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Clear the default text
        if (textField === topTextField && textField.text == defaultTopText) ||
            (textField === bottomTextField && textField.text == defaultBottomText) {
                textField.text = ""
        }
        // Set style here to prevent bug where it is possible to lose the text outline
        //    if the user repeatedly presses enter in a blank text field
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Make sure the text in the text field is always all-caps
        
        // Figure out what the new text will be
        var newText: NSString = textField.text
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        // Manually set the text field to the uppercase version of newText
        textField.text = newText.uppercaseString
        
        // returning false, because we manually changed the text field's text above
        return false;
    }
    

    @IBAction func pickAnImage(sender: UIBarButtonItem) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if sender.title == "Album" {
            // User tapped the Album button
            pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        } else {
            // User tapped the camera button
            pickerController.sourceType = UIImagePickerControllerSourceType.Camera
            pickerController.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        }
        self.presentViewController(pickerController, animated: true, completion: nil)
     }

    func createMemedImage() -> UIImage {
        
        // hide toolbar and navbar so they are not shown in the meme image
        memeEditorNavBar.hidden = true
        memeEditorToolbar.hidden = true
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0.0)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        memeEditorNavBar.hidden = false
        memeEditorToolbar.hidden = false
        
        return memedImage
    }
    
    func saveMeme() {
        if let originalImage = imagePickerView.image {
           let meme = Meme(topText: topTextField.text,
            bottomText: bottomTextField.text,
            originalImage: originalImage,
            memedImage: self.createMemedImage() )
             // Add it to the savedMemes array in the App Delegate
             let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
             appDelegate.savedMemes.append(meme)
            } else {
              println("In saveMeme(), imagePickerView.image is nil")
        }
    }
    
    func activityCompletionHandler(activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError: NSError!) {
        
        if completed {
            self.saveMeme()
            // Dismiss the meme editor, so the user is taken back to the sent memes view
        self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            println("Activity did not complete")
        }
        if activityError != nil {
            println("activity error \(activityError.description) occurred")
        }
    }

    @IBAction func shareButtonPressed(sender: AnyObject) {
        
        let activityVC = UIActivityViewController(activityItems: [self.createMemedImage()], applicationActivities: nil)
        activityVC.completionWithItemsHandler = activityCompletionHandler
        self.presentViewController(activityVC, animated: true, completion: nil)
        
}
    
    @IBAction  func cancelButtonPressed(sender: AnyObject) {
        
        // Dismiss the meme editor, so the user will be back in the
        //   sent memes table view or collection view
        self.dismissViewControllerAnimated(true, completion: nil)
  }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = pickedImage
            memeEditorShareButton.enabled = true
        } else {
            println("In imagePickerController didFinishPickingMediaWithInfo, image optional was nil")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


