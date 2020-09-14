//
//  LoginController.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import Foundation

struct User {
    var name: String
    let appointments: [Appointment]
}

struct Appointment {
    let date: Date
    let doctor: String
}

class LoginModuleController {
    var loginHandler: ((User) -> Void)?
    var invalidNameHandler: ((Bool) -> Void)?
    
    func login(withUsername username: String) {
        guard !username.isEmpty else {
            invalidNameHandler?(false)
            return
        }
        let user = User(name: username, appointments: [])
        loginHandler?(user)
    }
}
