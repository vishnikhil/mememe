//
//  MemeCollectionViewCell.swift
//  MemeMe1
//
//  Created by Vishruti Kekre on 5/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectionOverlay: UIView!
    
    func setSelectionOverlayVisible(state : Bool) {
        self.selectionOverlay.hidden = !state
    }

}
