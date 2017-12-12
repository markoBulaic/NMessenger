//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import UIKit



public protocol IModalAlertUtilities
{
    func postGenericErrorModal(fromController controller: UIViewController)
    
    func postGoToSettingToEnableCameraAndLibraryModal(
        fromController controller: UIViewController)

    func postGoToSettingToEnableCameraModal(fromController controller: UIViewController)

    func postGoToSettingToEnableLibraryModal(fromController controller: UIViewController)
}


//MARK: ModalAlertUtilities class
/**
 Custom alerts for NMessenger
 */
public struct ModalAlertUtilities: IModalAlertUtilities
{
    public let errorAlertTitle        : String
    public let errorAlertMessage      : String
    public let errorAlertDismissButton: String
    public let cameraAndLibraryMessage: String
    public let cameraOnlyMessage      : String
    public let libraryOnlyMessage     : String
    public let cancelButton           : String
    public let openSettingsMessage    : String
    
    public init()
    {
        self.errorAlertTitle   = "Error"
        self.errorAlertMessage = "An error occurred. Please try again later"
        self.errorAlertDismissButton = "Okay"
        
        self.cameraAndLibraryMessage =
        "Allow access to your camera & photo library to start uploading photos with N1"
        
        self.cameraOnlyMessage =
        "Allow access to your camera to start taking photos and uploading photos from your library with N1"
        
        self.libraryOnlyMessage =
        "Allow access to your photo library to start uploading photos from you library with N1"
        
        self.cancelButton = "Cancel"
        self.openSettingsMessage = "Go to Settings"
    }
    
    public init(
        errorAlertTitle: String,
        errorAlertMessage: String,
        errorAlertDismissButton: String,
        cameraAndLibraryMessage: String,
        cameraOnlyMessage: String,
        libraryOnlyMessage: String,
        cancelButton: String,
        openSettingsMessage: String)
    {
        self.errorAlertTitle         = errorAlertTitle
        self.errorAlertMessage       = errorAlertMessage
        self.errorAlertDismissButton = errorAlertDismissButton
        self.cameraAndLibraryMessage = cameraAndLibraryMessage
        self.cameraOnlyMessage       = cameraOnlyMessage
        self.libraryOnlyMessage      = libraryOnlyMessage
        self.cancelButton            = cancelButton
        self.openSettingsMessage     = openSettingsMessage
    }
    
    /**
     General error alert message
     - parameter controller: Must be UIViewController. Where to present to alert.
     */
    public func postGenericErrorModal(fromController controller: UIViewController)
    {
        let alert =
            UIAlertController(
                title: self.errorAlertTitle,
                message: self.errorAlertMessage,
                preferredStyle: .alert)
        
        
        let cancelAction =
            UIAlertAction(
            title: self.errorAlertDismissButton,
            style: .cancel,
            handler: nil)

        
        alert.addAction(cancelAction)
        DispatchQueue.main.async
        {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /**
     Camera permission alert message
     - parameter controller: Must be UIViewController. Where to present to alert.
     Alert tells user to go into setting to enable permission for both camera and photo library
     */
    public func postGoToSettingToEnableCameraAndLibraryModal(
                                        fromController controller: UIViewController)
    {
        // TODO: should be localized or injected from app
        //
        let message = self.cameraAndLibraryMessage
        
        let alert =
            UIAlertController(
                title: "",
                message: message,
                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: self.cancelButton, style: .destructive)
        {
            (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let settingsAction = UIAlertAction(title: self.openSettingsMessage, style: .default)
        {
            (alertAction) in
            
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString)
            {
                UIApplication.shared.openURL(appSettings)
            }
        }
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async
        {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    /**
     Camera permission alert message
     - parameter controller: Must be UIViewController. Where to present to alert.
     Alert tells user to go into setting to enable permission for camera
     */
    public func postGoToSettingToEnableCameraModal(fromController controller: UIViewController)
    {
        let alert =
            UIAlertController(
                title: "",
                message: self.cameraOnlyMessage,
                preferredStyle: .alert)
        
        let cancelAction =
            UIAlertAction(
                title: self.cancelButton,
                style: .destructive,
                handler: nil)

        let settingsAction = UIAlertAction(title: self.openSettingsMessage, style: .default)
        {
            (alertAction) in
            
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString)
            {
                UIApplication.shared.openURL(appSettings)
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async
        {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    /**
     Camera permission alert message
     - parameter controller: Must be UIViewController. Where to present to alert.
     Alert tells user to go into setting to enable permission for photo library
     */
    public func postGoToSettingToEnableLibraryModal(fromController controller: UIViewController)
    {
        let alert =
            UIAlertController(
                title: "",
                message: self.libraryOnlyMessage,
                preferredStyle: .alert)
        
        let cancelAction =
            UIAlertAction(
                title: self.cancelButton,
                style: .destructive,
                handler: nil)

        let settingsAction = UIAlertAction(title: self.openSettingsMessage, style: .default)
        {
            (alertAction) in
            
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString)
            {
                UIApplication.shared.openURL(appSettings)
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async
        {
            controller.present(alert, animated: true, completion: nil)
        }
    }
}
