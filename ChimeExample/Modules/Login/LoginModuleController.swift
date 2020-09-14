//
//  LoginController.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import Foundation

class User {
    var name: String
    var appointments: [Appointment]
    
    init(name: String, appointments: [Appointment] = []) {
        self.name = name
        self.appointments = appointments
    }
}

struct Appointment {
    let date: Date
    let doctor: String
    let meetingID = UUID()
}

class LoginModuleController {
    var loginHandler: ((User) -> Void)?
    var invalidNameHandler: ((Bool) -> Void)?
    
    func login(withUsername username: String) {
        guard !username.isEmpty else {
            invalidNameHandler?(false)
            return
        }
        let user = User(name: username)
        loginHandler?(user)
    }
}
