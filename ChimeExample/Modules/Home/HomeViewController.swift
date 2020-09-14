//
//  ContentView.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/9/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import UIKit

final class HomeViewController: UITableViewController {
    static let appointmentCellID = "AppointmentCellID"
    
    // Dependencies
    var controller: HomeModuleController!
    
    // Views
    let spinner = UIActivityIndicatorView(style: .medium)
    
    // View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
        navigationBarSetup()
        configureHandlers()
        startLoading(true)
        controller.loadAppointments()
    }
    
    fileprivate func configureHandlers() {
        controller.appointmentLoadHandler = { [weak self] isLoading in
            self?.startLoading(isLoading)
            self?.tableView.reloadData()
        }
        controller.joinMeetingHandler = { [weak self] username, meetingID, meetingConfig in
            if let meetingConfig = meetingConfig {
                let meetingVC = MeetingViewController()
                meetingVC.controller = MeetingModuleController(username: username,
                                                               meetingID: meetingID,
                                                               meetingConfiguration: meetingConfig)
                meetingVC.modalPresentationStyle = .fullScreen
                self?.present(meetingVC, animated: true, completion: nil)
            } else {
                self?.presentSingleActionAlert(title: "Error",
                                               message: "Unable to join meeting",
                                               actionTitle: "Ok")
            }
        }
    }
    
    // View Setup
    fileprivate func startLoading(_ isLoading: Bool) {
        if isLoading {
            spinner.startAnimating()

            view.addSubview(spinner)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        } else {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
    
    fileprivate func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.appointmentCellID)
    }
    
    fileprivate func navigationBarSetup() {
        let signOutButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOutTap))
        navigationItem.leftBarButtonItem = signOutButton
    }
    
    // Actions
    @objc fileprivate func handleSignOutTap() {
        self.dismiss(animated: true, completion: nil)
    }
}

// TableView Methods
extension HomeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.user.appointments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appointmentCell = UITableViewCell(style: .subtitle, reuseIdentifier: Self.appointmentCellID)
        let appointment = controller.user.appointments[indexPath.row]
        appointmentCell.textLabel?.text = "\(appointment.date)"
        appointmentCell.detailTextLabel?.text = "\(appointment.doctor)"
        return appointmentCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HomeSectionHeaderView()
        headerView.titleLabel.text = "Hello, \(controller.user.name)"
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAppointment = controller.user.appointments[indexPath.row]
        controller.joinMeeting(from: selectedAppointment)
    }
}
