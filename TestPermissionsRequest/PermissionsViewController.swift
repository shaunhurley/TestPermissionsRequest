//
//  PermissionsViewController.swift
//  AxePayments
//
//  Created by Shaun on 7/13/20.
//  Copyright © 2020 Shaun Hurley. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

protocol PermissionsViewControllerDelegate: class {
    /// Called when the user grants all required permissions
    func permissionsViewControllerDidObtainRequiredPermissions(_ permissionsViewController: PermissionsViewController)
}

class PermissionsViewController: UIViewController {

    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    private lazy var locationManager = CLLocationManager()

    public weak var delegate: PermissionsViewControllerDelegate?
    
    /// Returns true if all required permissions have been granted by the user.
    static var areRequiredPermissionsGranted: Bool {
        let locationStatus = CLLocationManager.authorizationStatus()
        let isLocationAccessGranted = (locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways)
        let isMicrophoneAccessGranted = AVAudioSession.sharedInstance().recordPermission == .granted
        return (isLocationAccessGranted && isMicrophoneAccessGranted)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("PermissionsViewController: obtaining required permissions...")
        // Do any additional setup after loading the view.
        updateMicrophoneButton()
        updateLocationButton()
        
        // The user may be directed to the Settings app to change their permissions.
        // When they return, update the button titles.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMicrophoneButton),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLocationButton),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            openSettings()
        case .notDetermined:
            requestLocationAccess()
        case .authorizedAlways, .authorizedWhenInUse:
            return
        }
    }
    
    private func requestLocationAccess() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @objc private func updateLocationButton() {
        let title: String
        let isEnabled: Bool
        
        print("updateLocationButton(): called...")
        
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            title = "Enable Location in Settings"
            isEnabled = true
        case .authorizedAlways, .authorizedWhenInUse:
            title = "Location Access Granted"
            isEnabled = false
        case .notDetermined:
            title = "Enable Location Access"
            isEnabled = true
        }
        
        locationButton.setTitle(title, for: [])
        locationButton.isEnabled = isEnabled
    }

    
    
    
    @IBAction func microphoneButtonTapped(_ sender: Any) {
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            openSettings()
        case .undetermined:
            requestMicrophoneAccess()
        case .granted:
            return
        }
    }
        
    func requestMicrophoneAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async {
                self.updateMicrophoneButton()
                
                if PermissionsViewController.areRequiredPermissionsGranted {
                    print("requestMicrophoneAccess(): microphone permissions were granted!")
                    self.delegate?.permissionsViewControllerDidObtainRequiredPermissions(self)
                }
            }
        }
    }
    
    @objc func updateMicrophoneButton() {
        let title: String
        let isEnabled: Bool
        
        print("updateMicrophoneButton(): called...")

        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            title = "Enable Microphone in Settings"
            isEnabled = true
        case .granted:
            title = "Microphone Access Enabled"
            isEnabled = false
        case .undetermined:
            title = "Enable Microphone Access"
            isEnabled = true
        }
        
        microphoneButton.setTitle(title, for: [])
        microphoneButton.isEnabled = isEnabled
    }
    
}

// MARK: - locationManager delegate protocol

extension PermissionsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("PermissionsViewController: locationManager didChangeAuthorization status delegate called...")
        updateLocationButton()
        
        if PermissionsViewController.areRequiredPermissionsGranted {
            delegate?.permissionsViewControllerDidObtainRequiredPermissions(self)
        }
    }
    
    
}
