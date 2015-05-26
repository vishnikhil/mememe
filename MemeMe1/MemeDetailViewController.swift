//
//  MemeDetailViewController.swift
//  MemeMe1
//
//  Created by Vishruti Kekre on 5/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

protocol MemeDetailViewDeleteDelegate {
    func deleteMemeDetailViewItem()
}



class MemeDetailViewController: UIViewController {
    var meme : Meme!
    var selectedMemedImage : UIImage!
    var deletionDelegate : MemeDetailViewDeleteDelegate?
    var passedImage:UIImage!
    var navAndStatusBarHidden = false
    var selectedMemeIndex: Int?
     private var selectedMeme: Meme?
    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var deletionToolBar: UIToolbar!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
        var button = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "handleEditButton:")
        self.navigationItem.rightBarButtonItem = button
        
        if deletionDelegate == nil {
            // There is no delegate, so don't show
            // the toolbar containing the delete button
            deletionToolBar.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        memeImageView.image = meme.memedImage
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navAndStatusBarHidden
    }
    
    func fadeNavAndStatusBar() {
        // Toggle the nav bar and status bar to fade in or out
        
        // For this to behave properly and for the navbar to stay hidden
        //  even after the device orientation is changed, we need to first
        //  fade the alpha value of the navbar to 0.0, and then set its hidden property to true.
        // When fading back in, make sure hidden is false and fade alpha back to 1.0
        
        navAndStatusBarHidden = !navAndStatusBarHidden
        
        if self.navigationController!.navigationBar.hidden {
            self.navigationController!.navigationBar.hidden = false
        }
        
        let durationSeconds = 0.33
        let alpha = navAndStatusBarHidden ? 0.0 : 1.0
        
        UIView.animateWithDuration(durationSeconds)
            {
                self.setNeedsStatusBarAppearanceUpdate()
                self.navigationController!.navigationBar.alpha = CGFloat(alpha)
                
                if self.deletionDelegate != nil {
                    self.deletionToolBar.alpha = CGFloat(alpha)
                }
        }
        
        if navAndStatusBarHidden {
            // This timer ensures that the navBar will be hidden only after the alpha fade is complete.
            // (Prevents some weird jerky behavior)
            NSTimer.scheduledTimerWithTimeInterval(durationSeconds, target: self, selector: Selector("hideNavBar"), userInfo: nil, repeats: false)
        }
    }
    
    func hideNavBar() {
        self.navigationController!.navigationBar.hidden = navAndStatusBarHidden
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            fadeNavAndStatusBar()
        }
    }
    
    func handleEditButton(sender: UIBarButtonItem) {
        // Pass the meme that is being viewed into the meme editor
        
        let editorVC = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorStoryboardId") as! MemeEditorViewController
        editorVC.memePassedIn = meme
        self.presentViewController(editorVC, animated: true, completion: nil)
    }
    
    func doDelete() {
        if let delegate = deletionDelegate {
            // Delete the meme and go back to the previous view
            delegate.deleteMemeDetailViewItem()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    
    
    @IBAction func handleDeleteButton(sender: AnyObject) {
        
        // Present an alert asking the user if they are sure they want to delete
        
        let controller = UIAlertController()
        controller.title = "Are you sure you want to delete this meme?"
        
        let deleteAction = UIAlertAction(title: "Delete Meme", style: UIAlertActionStyle.Destructive) {
            action in self.doDelete()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.addAction(deleteAction)
        controller.addAction(cancelAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMemeEditor" {
            var memeEditorVC = segue.destinationViewController as? MemeEditorViewController
            memeEditorVC?.memePassedIn = selectedMeme
        }
    }

    
    
    
    

    }
    
    
    
    
    
    
    
    
    

