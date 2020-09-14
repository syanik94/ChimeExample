//
//  MeetingModuleController.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import AmazonChimeSDK
import AVFoundation
import Foundation

class MeetingModuleController {
    // Dependencies
    let username: String
    let meetingModel: MeetingModel
    
    var videoPermissionHandler: ((Bool) -> Void)?
    
    init(username: String, meetingID: String, meetingConfiguration: MeetingSessionConfiguration) {
        self.username = username
        self.meetingModel = MeetingModel(
            meetingSessionConfig: meetingConfiguration,
            meetingId: meetingID,
            selfName: username)
    }
    
    func requestVideoPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
//            logger.error(msg: "User did not grant video permission, it should redirect to Settings")
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if authorized {
                    completion(true)
                } else {
//                    self.logger.error(msg: "User did not grant video permission")
                    completion(false)
                }
            }
        case .authorized:
            completion(true)
        @unknown default:
//            logger.error(msg: "AVCaptureDevice authorizationStatus unknown case detected")
            completion(false)
        }
    }
}
