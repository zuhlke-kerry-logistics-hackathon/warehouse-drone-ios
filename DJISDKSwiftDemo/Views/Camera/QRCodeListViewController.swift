//
//  QRCodeListViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 28/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

final class QRCodeListViewController: UIViewController {
    static let storyboardIdentifier = "QRCodeListViewController"
    @IBOutlet var closeButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    private static let cellIdentifier = "QRCell"
    var dataSource = [CIQRCodeFeature]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    private func setupUI() {
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: QRCodeListViewController.cellIdentifier)
        tableview.estimatedRowHeight = 44.0
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }

    @objc
    @IBAction private func closeButtonDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension QRCodeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

extension QRCodeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QRCodeListViewController.cellIdentifier, for: indexPath)            
        let qrCodeFeature = dataSource[indexPath.row]
        cell.textLabel?.text = qrCodeFeature.messageString ?? ""
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
