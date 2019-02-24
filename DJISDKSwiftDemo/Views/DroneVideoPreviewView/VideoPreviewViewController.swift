//
//  DummyViewController.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 20/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit

class VideoPreviewViewController: BaseViewController {

    var isVideoPreviewSetupCompleted: Bool = false
    var droneVideoPreviewView: DroneVideoPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()        
    }

    private func setup() {
        droneVideoPreviewView = DroneVideoPreviewView(frame: .zero)
        droneVideoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(droneVideoPreviewView)

        NSLayoutConstraint.activate([
            droneVideoPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            droneVideoPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            droneVideoPreviewView.topAnchor.constraint(equalTo: view.topAnchor),
            droneVideoPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(onDidProductConnected(_:)), name: .didProductConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidProductDisConnected(_:)), name: .didProductDisConnected, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVideoPreview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopVideoPreview()
    }

    private func setupVideoPreview() {
        guard isVideoPreviewSetupCompleted == false else {
            return
        }
        droneVideoPreviewView.setup()
        isVideoPreviewSetupCompleted = true
    }

    private func stopVideoPreview() {
        guard isVideoPreviewSetupCompleted == true else {
            return
        }
        droneVideoPreviewView.stop()
        isVideoPreviewSetupCompleted = false
    }

    @objc
    private func onDidProductConnected(_ notification: Notification) {
        setupVideoPreview()
    }

    @objc
    private func onDidProductDisConnected(_ notification: Notification) {
        stopVideoPreview()
    }
}
