//
//  HomeModuleController.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import AmazonChimeSDK
import Foundation

class HomeModuleController {
    // Dependencies
    let user: User
    
    // State
    private(set) var isLoading = true {
        didSet {
            appointmentLoadHandler?(isLoading)
        }
    }
    
    // Handlers
    var appointmentLoadHandler: ((Bool) -> Void)?
    typealias MeetingID = String
    var joinMeetingHandler: ((String, MeetingID, MeetingSessionConfiguration?) -> Void)?

    init(user: User) {
        self.user = user
    }
    
    /// Simulate async appointment fetching for signed in user.
    func loadAppointments() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let loadedAppointments: [Appointment] = [
                .init(date: Date(), doctor: "Dr. Thompson")
            ]
            self.user.appointments = loadedAppointments
            self.isLoading = false
        }
    }
    
    func joinMeeting(from appointment: Appointment) {
        isLoading = true
        
        let username = user.name
        let meetingID = appointment.meetingID.uuidString
        JoinRequestService.postJoinRequest(meetingId: meetingID,
                                           name: username) { [weak self] meetingConfig in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.joinMeetingHandler?(username, meetingID, meetingConfig)
            }
        }
    }
}
