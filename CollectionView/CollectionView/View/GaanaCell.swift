//
//  GaanaCell.swift
//  CollectionView
//
//  Created by Mac on 10/31/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import UIKit

class GaanaCell: UICollectionViewCell {
    
    @IBOutlet  weak var containerView: UIView!
    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var albumLbl: UILabel!
    @IBOutlet weak var tempImageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }

}
