//
//  MenuListViewController.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 31/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit

final class MenuListViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var menuItems = [MenuListCellViewModel]()

    struct CellLayout {
        static let cellItemSize = CGSize(width: 100.0, height: 100.0)
        static let minimumInteritemSpacing = CGFloat(4)
        static let minimumLineSpacing = CGFloat(4)
        static let edgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }

    override class func storyboardIdentifier() -> String {
        return "MenuListViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupMenu()
        // Do any additional setup after loading the view.
    }

    private func setupUI() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CellLayout.cellItemSize
        flowLayout.minimumInteritemSpacing = CellLayout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = CellLayout.minimumLineSpacing
        flowLayout.sectionInset = CellLayout.edgeInsets
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical

        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        let cellNib = UINib(nibName: "MenuListCollectionViewCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: MenuListCollectionViewCell.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = false
    }

    private func setupMenu() {
        self.menuItems = [
            MenuListCellViewModel(title: "Warehouse\n Mission", type: .warehouseMission),
            MenuListCellViewModel(title: "Auto Fly", type: .autoFly),
            MenuListCellViewModel(title: "QR Cam", type: .qrCamera),            
            MenuListCellViewModel(title: "Info", type: .info),
            MenuListCellViewModel(title: "Mission", type: .mission),
            MenuListCellViewModel(title: "Test QR", type: .testQr),
            MenuListCellViewModel(title: "Test RC", type: .testRc),
        ]
    }
}

extension MenuListViewController: UICollectionViewDelegate {

}

extension MenuListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let menuCell = cell as? MenuListCollectionViewCell else {
            return
        }
        let cellViewModel = menuItems[indexPath.row]
        menuCell.setup(viewModel: cellViewModel)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: MenuListCollectionViewCell.cellIdentifier, for: indexPath)
        guard let menuCell = cell as? MenuListCollectionViewCell else {
            return cell
        }
        menuCell.delegate = self
        return menuCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
}

extension MenuListViewController: MenuListCollectionViewCellDelegate {
    func menuButtonDidTap(viewModel: MenuListCellViewModel) {
        let storyboardId = viewModel.type.toStoryboardIdentifier()
        guard !storyboardId.isEmpty else {
            return
        }
        self.navigateToViewController(storyboardIdentifier: storyboardId)
    }
}
