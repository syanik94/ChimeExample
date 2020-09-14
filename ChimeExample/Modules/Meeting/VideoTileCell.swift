//
//  VideoTileCell.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import AmazonChimeSDK
import UIKit

class VideoTileCell: UITableViewCell {
    static let id = "VideoTileCellID"
    
    let attendeeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "User A"
        return label
    }()
    let videoRenderView: DefaultVideoRenderView! = DefaultVideoRenderView()
    let videoStateImageView: UIImageView = {
        let image = UIImage(systemName: "video.slash.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)

        addSubview(attendeeNameLabel)
        attendeeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        attendeeNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        attendeeNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        attendeeNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        addSubview(videoRenderView)
        videoRenderView.translatesAutoresizingMaskIntoConstraints = false
        videoRenderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        videoRenderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        videoRenderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        videoRenderView.bottomAnchor.constraint(equalTo: attendeeNameLabel.topAnchor).isActive = true
        
        addSubview(videoStateImageView)
        videoStateImageView.translatesAutoresizingMaskIntoConstraints = false
        videoStateImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        videoStateImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        videoStateImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        videoStateImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        attendeeNameLabel.text = nil
        videoRenderView.mirror = false
        videoRenderView.renderFrame(frame: nil)
    }
}
