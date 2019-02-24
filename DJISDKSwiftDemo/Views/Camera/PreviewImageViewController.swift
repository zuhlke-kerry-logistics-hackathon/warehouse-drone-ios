//
//  PreviewMediaViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 23/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJISDK

final class PreviewImageViewController: UIViewController {

    static let storyboardIdentifier = "PreviewImageViewController"

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!

    fileprivate var dataSource = [DJIMediaFile]()
    fileprivate weak var mediaManager: DJIMediaManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMediaManager(completion: { [weak self] in
            self?.loadMediaList()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMediaManager()
    }

    private func setupView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 150, height: 100)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 4
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical

        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        let cellNib = UINib(nibName: "PreviewImageCollectionViewCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: PreviewImageCollectionViewCell.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = false
    }

    private func setupMediaManager(completion: @escaping (() -> Void)) {
        guard let camera = DJISDKManager.product()?.fetchCamera(),
            let mediaManager = camera.mediaManager else {
            debugPrint("[Drone] Unable to get camera / media manager")
            return
        }

        camera.setMode(.mediaDownload) { error in
            guard error == nil else {
                debugPrint("[Drone] Fail to set camera mode to media download")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                completion()
            })
        }
        self.mediaManager = mediaManager
    }

    private func stopMediaManager() {
        guard let camera = DJISDKManager.product()?.fetchCamera() else {
            return
        }
        camera.setMode(.shootPhoto) { [weak self] error in
            guard error != nil else {
                debugPrint("[Drone] Fail to set camera mode to shoot photo")
                return
            }
            camera.delegate = nil
            self?.mediaManager?.delegate = nil
        }
    }

    private func loadMediaList() {
        guard let mediaManager = self.mediaManager else {
            return
        }

        if mediaManager.isSdCardBusy() {
            self.showAlert(title: nil, message: "sd card is busy")
        } else {
            mediaManager.refreshFileList(of: .sdCard) { [weak self] error in
                guard error == nil,
                    let mediaFiles = self?.mediaManager?.sdCardFileListSnapshot() else {
                        self?.showAlert(title: nil, message: "error:\(error?.localizedDescription ?? "")")
                    return
                }
                self?.retrieveMedia(mediaFiles: mediaFiles)
            }
        }
    }

    private func retrieveMedia(mediaFiles: [DJIMediaFile]) {
        dataSource.removeAll()
        debugPrint("[Drone] media file count:\(mediaFiles.count)")
        dataSource = mediaFiles
        guard let taskScheduler = mediaManager?.taskScheduler else {
            return
        }
        taskScheduler.suspendAfterSingleFetchTaskFailure = false
        taskScheduler.resume(completion: nil)
        for mediaFile in mediaFiles {
            guard mediaFile.mediaType == .JPEG else {
                // only interested in jpeg media type
                continue
            }
            if mediaFile.thumbnail == nil {
                let fetchTask = DJIFetchMediaTask(file: mediaFile, content: .thumbnail) { [weak self] (mediaFile, taskContent, error) in
                    self?.collectionView.reloadData()
                }
                taskScheduler.moveTask(toEnd: fetchTask)
            }
        }
    }

    @objc
    @IBAction private func closeButtonDidTap(_ sender: UIButton) {        
        self.dismiss(animated: true, completion: nil)
    }
}

extension PreviewImageViewController: UICollectionViewDelegate {
    
}

extension PreviewImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PreviewImageCollectionViewCell.cellIdentifier, for: indexPath)
        let mediaFile = dataSource[indexPath.row]
        guard let previewCell = cell as? PreviewImageCollectionViewCell else {
            return cell
        }
        if let thumbnail = mediaFile.thumbnail {
            previewCell.previewImageView.image = thumbnail
        }
        return previewCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
}
