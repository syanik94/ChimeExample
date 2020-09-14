//
//  HomeModuleController.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

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
    var joinMeetingHandler: (() -> Void)?

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
        
        JoinRequestService.postJoinRequest(meetingId: appointment.doctor,
                                           name: user.name) { [weak self] meetingConfig in
            self?.isLoading = false
            self?.joinMeetingHandler?()
        }
    }
}
