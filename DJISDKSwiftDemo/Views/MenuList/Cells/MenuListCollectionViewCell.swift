//
//  MenuListCollectionViewCell.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 31/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit

protocol MenuListCollectionViewCellDelegate: class {
    func menuButtonDidTap(viewModel: MenuListCellViewModel)
}

final class MenuListCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier: String = "MenuListCollectionViewCell"

    @IBOutlet weak private var menuButton: UIButton!
    weak var delegate: MenuListCollectionViewCellDelegate?
    fileprivate(set) var viewModel: MenuListCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        menuButton.setTitle("", for: .normal)
    }

    func setup(viewModel: MenuListCellViewModel) {
        self.viewModel = viewModel
        self.menuButton.setTitle(viewModel.title, for: .normal)
    }

    @IBAction func menuButtonDidTap(_ sender: UIButton) {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.menuButtonDidTap(viewModel: viewModel)
    }
}
