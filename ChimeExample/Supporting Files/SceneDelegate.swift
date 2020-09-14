//
//  SceneDelegate.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/9/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = LoginViewController()
            self.window = window
            window.makeKeyAndVisible()
        }
    }

}

