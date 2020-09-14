//
//  MeetingViewController.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import UIKit

class MeetingViewController: UIViewController {
    var controller: MeetingModuleController!
    
    // Views
    let videoTableView = UITableView(frame: .zero, style: .plain)
    let accessoryView = UIView()
    
    lazy var micButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.setImage(UIImage(systemName: "mic.slash.fill"), for: .selected)
        button.addTarget(self, action: #selector(handleMicToggleTap), for: .touchUpInside)
        return button
    }()
    lazy var videoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "video"), for: .normal)
        button.setImage(UIImage(systemName: "video.slash"), for: .selected)
        button.addTarget(self, action: #selector(handleToggleVideoTap), for: .touchUpInside)
        return button
    }()
    lazy var endCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "phone.down.fill")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                               for: .normal)
        button.addTarget(self, action: #selector(handleEndCallTap), for: .touchUpInside)
        return button
    }()
    
    // View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutContent()
        configureAccessoryView()
        configureTableView()
        configureHandlers()
        
        controller.requestAVPermissions { [weak self] in
            self?.controller.startMeeting()
        }
    }
    
    // Configuration
    private func configureHandlers() {
        controller.isMutedHandler = { [weak self] isMuted in
            self?.micButton.isSelected = isMuted
        }
        controller.isEndedHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: nil)
//                MeetingModule.shared().dismissMeeting(meetingModel)
            }
        }
        controller.videoModel.localVideoUpdatedHandler = {
            self.videoTableView.reloadRows(at: [[0,0]], with: .automatic)
        }
        controller.videoModel.videoUpdatedHandler = { [weak self] in
            self?.controller.videoModel.resumeAllRemoteVideosInCurrentPageExceptUserPausedVideos()
            self?.videoTableView.reloadData()
        }
    }
    
    // View Setup
    fileprivate func configureTableView() {
        videoTableView.delegate = self
        videoTableView.dataSource = self
        videoTableView.isScrollEnabled = false
        videoTableView.showsVerticalScrollIndicator = false
        videoTableView.register(VideoTileCell.self, forCellReuseIdentifier: VideoTileCell.id)
    }
        
    fileprivate func configureAccessoryView() {
        let stackView = UIStackView(arrangedSubviews: [micButton, videoButton, endCallButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        accessoryView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: accessoryView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: accessoryView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: accessoryView.layoutMarginsGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: accessoryView.layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    fileprivate func layoutContent() {
        view.addSubview(accessoryView)
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        accessoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        accessoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        accessoryView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        view.addSubview(videoTableView)
        videoTableView.translatesAutoresizingMaskIntoConstraints = false
        videoTableView.bottomAnchor.constraint(equalTo: accessoryView.topAnchor).isActive = true
        videoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        videoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        videoTableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
    }
    
    // Actions
    @objc fileprivate func handleMicToggleTap(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc fileprivate func handleToggleVideoTap(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc fileprivate func handleEndCallTap() {
        controller.endMeeting()
    }
}

extension MeetingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.videoModel.videoTileCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoTileCell.id,
                                                       for: indexPath) as? VideoTileCell,
        indexPath.item < controller.videoModel.videoTileCount else {
            return VideoTileCell()
        }
        let isSelf = indexPath.item == 0
        let videoTileState = controller.videoModel.getVideoTileState(for: indexPath)
        let displayName = controller.getVideoTileDisplayName(for: indexPath)
        
        if let tileState = videoTileState {
            if tileState.isLocalTile, controller.isFrontCameraActive {
                cell.videoRenderView.mirror = true
            }
            controller.bind(videoRenderView: cell.videoRenderView, tileId: tileState.tileId)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 2
    }
}
