//
//  MemeCollectionViewController.swift
//  MemeMe1
//
//  Created by Vishruti Kekre on 5/25/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, MemeDetailViewDeleteDelegate {

    var memes : [Meme]!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var memeCollectionView: UICollectionView!
    @IBOutlet weak var toolBarWithTrashButton: UIToolbar!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var addMemeButton: UIBarButtonItem!
    
    
    
    var editModeEnabled = false
    var selectedIndexPaths = Set<NSIndexPath>()
    
    var detailViewIndexPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memeCollectionView.allowsMultipleSelection = true
    }
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func reloadCollectionView() {
        // Update our copy of the shared model
        memes = getAppDelegate().savedMemes
        memeCollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCollectionView()
        
        self.editButton.enabled = (memes.count > 0)
        
        detailViewIndexPath = nil
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        
        self.editModeEnabled = !self.editModeEnabled
        
        if self.editModeEnabled {
            // "Edit" was pressed
            self.editModeStart()
        } else {
            // "Cancel" was pressed
            self.editModeEnd()
        }
    }
    
    func editModeStart() {
        // The view has entered Edit mode,
        //  so the button should now function as a "Cancel"
        self.editButton.title = "Cancel"
        
        // Hide the tab bar and show toolbar with delete button
        self.tabBarController?.tabBar.hidden = true
        self.toolBarWithTrashButton.hidden = false
        
        // We begin with no items selected, so disable the trash button for now
        self.trashButton.enabled = false
        
        self.navBar.title = "Select Items"
        self.addMemeButton.enabled = false
    }
    
    func editModeEnd() {
        // User has either cancelled editing,
        //  or confirmed deletion, so set things back
        //  to how they were before Edit was tapped
        
        //  Make sure the previously selected memes are all deselected
        for indexPath in self.selectedIndexPaths {
            self.memeCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
            
            if let cell = self.memeCollectionView.cellForItemAtIndexPath(indexPath) as? MemeCollectionViewCell {
                cell.setSelectionOverlayVisible(false)
            }
        }
        
        self.selectedIndexPaths.removeAll(keepCapacity: false)
        
        self.editModeEnabled = false
        
        // The button should go back to saying "Edit"
        self.editButton.title = "Edit"
        self.editButton.enabled = (self.memes.count > 0)
        
        // hide tool bar with delete button and show tab bar
        self.tabBarController?.tabBar.hidden = false
        self.trashButton.enabled = false
        self.toolBarWithTrashButton.hidden = true
        
        self.navBar.title = "Sent Memes"
        self.addMemeButton.enabled = true
    }
    
    func updateModelAndDeleteItemsFromCollectionView(collectionView: UICollectionView, indexPathsToDelete: [NSIndexPath]) {
        
        for indexPath in indexPathsToDelete {
            // Delete the meme from the shared model
            getAppDelegate().savedMemes.removeAtIndex(indexPath.item)
        }
        // Update our copy of the shared model
        memes = getAppDelegate().savedMemes
        
        collectionView.deleteItemsAtIndexPaths(indexPathsToDelete)
    }
    
    func doDelete() {
        let appDelegate = getAppDelegate()
        
        // When deleting multiple memes at once,
        //    we have to delete items from the memes array in order from
        //    highest to lowest index, to prevent attempts to delete
        //    an index that is out of range.
        // Create an array with the contents of our selectedIndexPaths set.
        // Sort the array from highest to lowest item index.
        var sortedArray = Array(self.selectedIndexPaths)
        sortedArray.sort { (indexPath1 : NSIndexPath, indexPath2 : NSIndexPath) -> Bool in
            return indexPath1.item > indexPath2.item
        }
        
        updateModelAndDeleteItemsFromCollectionView(memeCollectionView, indexPathsToDelete: sortedArray)
        
        self.editModeEnd()
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        // Present an alert asking the user if they are sure they want to delete
        
        let selectedCount = self.selectedIndexPaths.count
        
        let controller = UIAlertController()
        controller.title = "Are you sure you want to delete the selected meme"
        controller.title = controller.title! + ((selectedCount > 1) ? "s?" : "?")
        
        let deleteButtonTitle = (selectedCount > 1) ? "Delete \(selectedCount) Memes" : "Delete Meme"
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: UIAlertActionStyle.Destructive) {
            action in self.doDelete()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.addAction(deleteAction)
        controller.addAction(cancelAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionViewCellReuseId", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.item]
        cell.imageView.image = meme.memedImage
        
        if self.selectedIndexPaths.contains(indexPath) {
            cell.setSelectionOverlayVisible(true)
        } else {
            cell.setSelectionOverlayVisible(false)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.editModeEnabled {
            // Add the selected meme to our list of items that will potentially be deleted,
            //   and show the selection overlay over this item in the collection view
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            
            // The cell should be selected for deletion
            cell.setSelectionOverlayVisible(true)
            self.selectedIndexPaths.insert(indexPath)
            
            self.trashButton.enabled = true
            
        } else {
            // Show the detail view of the selected meme
            
            detailViewIndexPath = indexPath
            
            let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewStoryboardId") as! MemeDetailViewController
            detailVC.meme = self.memes[indexPath.item]
            detailVC.deletionDelegate = self
            detailVC.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(detailVC, animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.editModeEnabled {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MemeCollectionViewCell {
                cell.setSelectionOverlayVisible(false)
            }
            self.selectedIndexPaths.remove(indexPath)
            self.trashButton.enabled = (self.selectedIndexPaths.count > 0)
        }
    }
    
    func deleteMemeDetailViewItem() {
        println("In collection view, deleteMemeDetailViewItem()")
        
        if let indexPath = detailViewIndexPath {
            
            // Delete the meme from the shared model
            getAppDelegate().savedMemes.removeAtIndex(indexPath.item)
            // Update our copy of the shared model
            memes = getAppDelegate().savedMemes
            
            detailViewIndexPath = nil
            
        } else {
            println("!! In collection view deleteMemeDetailViewItem(), detailViewIndexPath is nil !!")
        }
    }
    
}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

