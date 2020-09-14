//
//  MeetingModel.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/14/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import AmazonChimeSDK
import AVFoundation
import Foundation

class MeetingModel: NSObject {
    // Dependencies
    let meetingId: String
    let selfName: String
    let meetingSessionConfig: MeetingSessionConfiguration
    lazy var currentMeetingSession = DefaultMeetingSession(configuration: meetingSessionConfig, logger: logger)
    
    // Utils
    let logger = ConsoleLogger(name: "MeetingModel")
    let activeSpeakerObserverId = UUID().uuidString
    
    // Sub models
    lazy var videoModel = VideoModel(audioVideoFacade: currentMeetingSession.audioVideo)
    let uuid = UUID()
    
    // States
    private var isMuted = false {
        didSet {
            if isMuted {
                if currentMeetingSession.audioVideo.realtimeLocalMute() {
                    logger.info(msg: "Microphone has been muted")
                }
            } else {
                if currentMeetingSession.audioVideo.realtimeLocalUnmute() {
                    logger.info(msg: "Microphone has been unmuted")
                }
            }
            isMutedHandler?(isMuted)
        }
    }
    
    private var isEnded = false {
        didSet {
            currentMeetingSession.audioVideo.stop()
            isEndedHandler?()
        }
    }
    
    var audioDevices: [MediaDevice] {
        return currentMeetingSession.audioVideo.listAudioDevices()
    }
    
    var isLocalVideoActive = false {
        didSet {
            if isLocalVideoActive {
                startLocalVideo()
            } else {
                stopLocalVideo()
            }
        }
    }
    
    var isFrontCameraActive: Bool {
        if let activeCamera = currentMeetingSession.audioVideo.getActiveCamera() {
            return activeCamera.type == .videoFrontCamera
        }
        return false
    }
    
    // Handlers
    var notifyHandler: ((String) -> Void)?
    var isMutedHandler: ((Bool) -> Void)?
    var isEndedHandler: (() -> Void)?
    
    init(meetingSessionConfig: MeetingSessionConfiguration, meetingId: String, selfName: String) {
        self.meetingId = meetingId
        self.selfName = selfName
        self.meetingSessionConfig = meetingSessionConfig
        super.init()
    }
    
    func bind(videoRenderView: VideoRenderView, tileId: Int) {
        currentMeetingSession.audioVideo.bindVideoView(videoView: videoRenderView, tileId: tileId)
    }
    
    func startMeeting() {
        configureAudioSession()
        startAudioVideoConnection()
        currentMeetingSession.audioVideo.startRemoteVideo()
    }
    
    
    func endMeeting() {
        isEnded = true
    }
    
    func setMute(isMuted: Bool) {
        self.isMuted = isMuted
    }
    
    func getVideoTileDisplayName(for indexPath: IndexPath) -> String {
        var displayName = ""
        if indexPath.item == 0 {
            if isLocalVideoActive {
                displayName = selfName
            } else {
                displayName = "Turn on your video"
            }
        } else {
//            if let videoTileState = videoModel.getVideoTileState(for: indexPath) {
                //                displayName = rosterModel.getAttendeeName(for: videoTileState.attendeeId) ?? ""
//            }
        }
        return displayName
    }
    
    func chooseAudioDevice(_ audioDevice: MediaDevice) {
        currentMeetingSession.audioVideo.chooseAudioDevice(mediaDevice: audioDevice)
    }
    
    private func notify(msg: String) {
        logger.info(msg: msg)
        notifyHandler?(msg)
    }
    
    private func logWithFunctionName(fnName: String = #function, message: String = "") {
        logger.info(msg: "[Function] \(fnName) -> \(message)")
    }
    
    private func setupAudioVideoFacadeObservers() {
        let audioVideo = currentMeetingSession.audioVideo
        audioVideo.addVideoTileObserver(observer: self)
        audioVideo.addAudioVideoObserver(observer: self)
        audioVideo.addActiveSpeakerObserver(policy: DefaultActiveSpeakerPolicy(),
                                            observer: self)
    }
    
    private func removeAudioVideoFacadeObservers() {
        let audioVideo = currentMeetingSession.audioVideo
        audioVideo.removeVideoTileObserver(observer: self)
        audioVideo.removeAudioVideoObserver(observer: self)
        audioVideo.removeActiveSpeakerObserver(observer: self)
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if audioSession.category != .playAndRecord {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                             options: AVAudioSession.CategoryOptions.allowBluetooth)
            }
            if audioSession.mode != .voiceChat {
                try audioSession.setMode(.voiceChat)
            }
        } catch {
            logger.error(msg: "Error configuring AVAudioSession: \(error.localizedDescription)")
            endMeeting()
        }
    }
    
    private func startAudioVideoConnection() {
        do {
            setupAudioVideoFacadeObservers()
            try currentMeetingSession.audioVideo.start(callKitEnabled: false)
        } catch {
            logger.error(msg: "Error starting the Meeting: \(error.localizedDescription)")
            endMeeting()
        }
    }
    
    private func startLocalVideo() {
        //        MeetingModule.shared().requestVideoPermission { success in
        //            if success {
        //                do {
        //                    try self.currentMeetingSession.audioVideo.startLocalVideo()
        //                } catch {
        //                    self.logger.error(msg: "Error starting local video: \(error.localizedDescription)")
        //                }
        //            }
        //        }
    }
    
    private func stopLocalVideo() {
        currentMeetingSession.audioVideo.stopLocalVideo()
    }
}

// MARK: AudioVideoObserver

extension MeetingModel: AudioVideoObserver {
    func connectionDidRecover() {
        notifyHandler?("Connection quality has recovered")
        logWithFunctionName()
    }
    
    func connectionDidBecomePoor() {
        notifyHandler?("Connection quality has become poor")
        logWithFunctionName()
    }
    
    func videoSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus) {
        logWithFunctionName(message: "\(sessionStatus.statusCode)")
    }
    
    func audioSessionDidStartConnecting(reconnecting: Bool) {
        notifyHandler?("Audio started connecting. Reconnecting: \(reconnecting)")
        logWithFunctionName(message: "reconnecting \(reconnecting)")
    }
    
    func audioSessionDidStart(reconnecting: Bool) {
        notifyHandler?("Audio successfully started. Reconnecting: \(reconnecting)")
        logWithFunctionName(message: "reconnecting \(reconnecting)")
    }
    
    func audioSessionDidDrop() {
        notifyHandler?("Audio Session Dropped")
        logWithFunctionName()
    }
    
    func audioSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus) {
        logWithFunctionName(message: "\(sessionStatus.statusCode)")
        
        removeAudioVideoFacadeObservers()
        endMeeting()
    }
    
    func audioSessionDidCancelReconnect() {
        notifyHandler?("Audio cancelled reconnecting")
        logWithFunctionName()
    }
    
    func videoSessionDidStartConnecting() {
        logWithFunctionName()
    }
    
    func videoSessionDidStartWithStatus(sessionStatus: MeetingSessionStatus) {
        switch sessionStatus.statusCode {
        case .videoAtCapacityViewOnly:
            notifyHandler?("Maximum concurrent video limit reached! Failed to start local video")
            logWithFunctionName(message: "\(sessionStatus.statusCode)")
        default:
            logWithFunctionName(message: "\(sessionStatus.statusCode)")
        }
    }
}

// MARK: VideoTileObserver

extension MeetingModel: VideoTileObserver {
    func videoTileDidAdd(tileState: VideoTileState) {
        logger.info(msg: "Attempting to add video tile tileId: \(tileState.tileId)" +
            " attendeeId: \(tileState.attendeeId) with size \(tileState.videoStreamContentWidth)*\(tileState.videoStreamContentHeight)")
        
        if tileState.isLocalTile {
            videoModel.setSelfVideoTileState(tileState)
            videoModel.localVideoUpdatedHandler?()
        } else {
            videoModel.addRemoteVideoTileState(tileState, completion: { success in
                if success {
                    // If the video is not currently being displayed, pause it
                    if !self.videoModel.isRemoteVideoDisplaying(tileId: tileState.tileId) {
                        self.currentMeetingSession.audioVideo.pauseRemoteVideoTile(tileId: tileState.tileId)
                    }
                    self.videoModel.videoUpdatedHandler?()
                    
                } else {
                    self.logger.info(msg: "Cannot add more video tile tileId: \(tileState.tileId)")
                }
            })
        }
    }
    
    func videoTileDidRemove(tileState: VideoTileState) {
        logger.info(msg: "Attempting to remove video tile tileId: \(tileState.tileId)" +
            " attendeeId: \(tileState.attendeeId)")
        currentMeetingSession.audioVideo.unbindVideoView(tileId: tileState.tileId)
        
        if tileState.isLocalTile {
            videoModel.setSelfVideoTileState(nil)
            videoModel.localVideoUpdatedHandler?()
        } else {
            videoModel.removeRemoteVideoTileState(tileState, completion: { success in
                if success {
                    self.videoModel.revalidateRemoteVideoPageIndex()
                    self.videoModel.videoUpdatedHandler?()
                } else {
                    self.logger.error(msg: "Cannot remove unexisting remote video tile for tileId: \(tileState.tileId)")
                }
            })
        }
    }
    
    func videoTileDidPause(tileState: VideoTileState) {}
    func videoTileDidResume(tileState: VideoTileState) {}
    func videoTileSizeDidChange(tileState: VideoTileState) {}
}

// MARK: ActiveSpeakerObserver

extension MeetingModel: ActiveSpeakerObserver {
    var observerId: String {
        return activeSpeakerObserverId
    }
    
    var scoresCallbackIntervalMs: Int {
        return 5000 // 5 second
    }
    
    func activeSpeakerDidDetect(attendeeInfo: [AttendeeInfo]) {
        videoModel.updateRemoteVideoStatesBasedOnActiveSpeakers(activeSpeakers: attendeeInfo)
        videoModel.videoUpdatedHandler?()
    }
    
    func activeSpeakerScoreDidChange(scores: [AttendeeInfo: Double]) {
        let scoresInString = scores.map { (score) -> String in
            let (key, value) = score
            return "\(key.externalUserId): \(value)"
        }.joined(separator: ",")
        logWithFunctionName(message: "\(scoresInString)")
    }
}

