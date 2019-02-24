//
//  PreviewImageCollectionViewCell.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 23/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit

class PreviewImageCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier: String = "PreviewImageCollectionViewCell"
    
    @IBOutlet var previewImageView: UIImageView!

    override func prepareForReuse() {
        previewImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
