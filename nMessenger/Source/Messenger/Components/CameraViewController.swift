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
import Photos
import AVFoundation




//MARK: SelectionType
/**
 SelectionType enum for NMessenger.
 Defines type of selection the user is making - camera of photo library
 */
public enum SelectionType
{
    case camera
    case library
}


//MARK: CameraViewController
/**
 CameraViewController class for NMessenger.
 Defines the camera view for NMessenger. This is where the user will take photos or select them from the library.
 */
open class CameraViewController: UIImagePickerController
                , ICameraViewController
                , UIImagePickerControllerDelegate
                , UINavigationControllerDelegate
{
    //MARK: Public Parameters
    //
    //
    
    //CameraViewDelegate that implemets the delegate methods
    //
    open weak var cameraDelegate: CameraViewDelegate?
    
    open var alertUtils: IModalAlertUtilities = ModalAlertUtilities()
    
    //SelectionType type of selection the user is making  - defualt is camera
    //
    open var selection = SelectionType.camera
    
    //AVAuthorizationStatus authorization status for the camera
    //
    open var cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    
    //PHAuthorizationStatus authorization status for the library
    //
    open var photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
    
    //MARK: Private Parameters
    //
    //
    
    //UIButton to change to gallery mode
    //
    fileprivate var gallery: UIButton!
    
    //UIImageView image from the gallery
    //
    fileprivate var galleryImage: UIImageView!
    
    //UIButton to take a photo
    //
    fileprivate var capturePictureButton: UIButton!
    
    //UIButton to flip camera between front and back
    //
    fileprivate var flipCamera:UIButton!
    
    //UIToolbar to hold buttons above the live camera view
    //
    fileprivate var cameraToolbar: UIToolbar!
    
    //UIButton to enable/disable flash
    //
    fileprivate var flashButton:UIButton!
    
    //CGFloat to define size for capture button
    //
    fileprivate let captureButtonSize:CGFloat = 80
    
    //CGFloat to define size for buttons under the live camera view
    //
    fileprivate let sideButtonSize:CGFloat = 50
    
    //CGFloat to define padding for bottom view
    //
    fileprivate let bottomPadding:CGFloat = 40
    
    //Bool if user gave permission for the camera
    //
    fileprivate let isCameraAvailable =
        UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear)
     || UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front)
    
    //MARK: View Lifecycle
    /**
     Ovreriding viewDidLoad to setup the controller
     Calls helper method
     */
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.allowsEditing = true
        self.delegate = self
        self.initView()
    }
    
    private func isCameraSourceAvailable() -> Bool
    {
        let result =
            UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        return result
    }
    
    private func isCameraSourceUnavailable() -> Bool
    {
        return !self.isCameraSourceAvailable()
    }
    
    private func isCameraSourceSelected() -> Bool
    {
        let result =
            (self.sourceType == UIImagePickerControllerSourceType.camera)
        
        return result
    }
    
    private func isCameraAuthorized() -> Bool
    {
        let result = (self.cameraAuthStatus == AVAuthorizationStatus.authorized)
        return result
    }
    
    private func isCameraNotAuthorized() -> Bool
    {
        let result = (self.cameraAuthStatus != AVAuthorizationStatus.authorized)
        return result
    }
    
    private func isPhotoLibraryUnauthorized() -> Bool
    {
        return !self.isPhotoLibraryAuthorized()
    }
    
    private func isPhotoLibraryAuthorized() -> Bool
    {
        let result =
            (self.photoLibAuthStatus == PHAuthorizationStatus.authorized)
        
        return result
    }
    
    private func isCameraAvailableAndAuthorized() -> Bool
    {
        let result =
            self.isCameraSourceAvailable()
         && self.isCameraAuthorized()
        
        return result
    }
    
    /**
     Ovreriding viewDidAppear to setup the camera view if there are permissions for the camera
     */
    override open func viewDidAppear(_ animated: Bool)
    {
        let isCameraAvailable = self.isCameraSourceAvailable()
        
        if (isCameraAvailable)
        {
            if (self.isCameraSourceSelected())
            {
                self.orientCamera(self.flipCamera)
                self.setFlash(self.flashButton)
            }
        }
    }
    
    //MARK: View Lifecycle helper methods
    /**
     Initialise the view and request for permissions if necessary
     */
    fileprivate func initView()
    {
        //check if the camera is available
        if (self.isCameraAvailableAndAuthorized())
        {
            self.sourceType = UIImagePickerControllerSourceType.camera
            self.showsCameraControls = false
            self.selection = SelectionType.camera
            self.renderCameraElements()
        }
        else
        {
            self.cameraAuthStatus =
                AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if (self.isPhotoLibraryUnauthorized())
            {
                self.requestPhotoLibraryPermissions(
                {
                    (granted) in
                    
                    if(granted)
                    {
                        self.sourceType = UIImagePickerControllerSourceType.photoLibrary
                        self.selection = SelectionType.library
                    }
                    else
                    {
                        self.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                        self.dismiss(animated: true)
                        {
                            let presentingViewController =
                                self.cameraDelegate as! NMessengerViewController
                            
                            self.alertUtils.postGoToSettingToEnableLibraryModal(
                                fromController: presentingViewController)
                        }
                    }
                })
            }
            else
            {
                self.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.selection = SelectionType.library
            }
        }
    }
    /**
     Adds all the buttons for the custom camera view
     */
    fileprivate func renderCameraElements()
    {
        self.addGalleryButton()
        //set gallery image thumbnail
        if (self.isPhotoLibraryUnauthorized())
        {
            requestPhotoLibraryPermissions(
            {
                (granted) in
                
                if(granted)
                {
                    self.getGalleryThumbnail()
                }
                else
                {
                    self.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                    self.alertUtils.postGoToSettingToEnableLibraryModal(fromController: self)
                }
            })
            
        }
        else
        {
            self.getGalleryThumbnail()
        }
        
        //CAPTURE BUTTON
        //
        self.addCaptureButton()
        
        //FLIP CAMERA BUTTON
        //
        self.addFlipCameraButton()
        
        //CAMERA TOOLBAR
        //
        self.addCameraToolBar()
        
        //Flash Button
        //
        self.addFlashButton()
        
        //ADD ELEMENTS TO SUBVIEW
        //
        self.addCameraElements()
    }
    
    //MARK: Camera Button Elements
    /**
     Adds the gallery button for the custom camera view
     */
    fileprivate func addGalleryButton()
    {
        //GALLERY BUTTON
        //
        
        let buttonSizeAndPadding = self.sideButtonSize + self.bottomPadding
        
        let buttonFrame =
            CGRect(x: self.view.frame.width  - buttonSizeAndPadding,
                   y: self.view.frame.height - buttonSizeAndPadding,
               width: self.sideButtonSize,
              height: self.sideButtonSize)
        self.gallery = UIButton(frame: buttonFrame)
        
        self.gallery.addTarget( self,
                        action: #selector(CameraViewController.changePictureMode),
                           for: .touchUpInside)
        
        let nmessengerBundle = self.getNmessengerBundle()
        
        let rawCameraRollIcon = UIImage(named: "cameraRollIcon",
                                           in: nmessengerBundle,
                               compatibleWith: nil)
        let cameraRollIcon = rawCameraRollIcon?.withRenderingMode(.alwaysTemplate)
        
        self.gallery.setImage(cameraRollIcon, for: UIControlState())
        self.gallery.tintColor = UIColor.white
        
        self.galleryImage = UIImageView(frame: self.gallery.frame)
            self.galleryImage.contentMode = .scaleAspectFill
            self.galleryImage.clipsToBounds = true
            self.galleryImage.isHidden = true
    }
    
    fileprivate func getNmessengerBundle() -> Bundle
    {
        let nmessengerBundle = Bundle(for: NMessengerViewController.self)
        return nmessengerBundle
    }
    
    /**
     Adds the gallery thumbnail for the custom camera view
     */
    fileprivate func getGalleryThumbnail()
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors =
            [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image,
                                           options: fetchOptions)
        let lastAsset = fetchResult.lastObject as PHAsset!
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        
        PHImageManager.default().requestImage(for: lastAsset!,
                                       targetSize: self.galleryImage.frame.size,
                                      contentMode: .aspectFill,
                                          options: requestOptions)
        {
            (image, info) -> Void in
            
            DispatchQueue.main.async
            {
                self.galleryImage.image = image
            }
        }
    }
    /**
     Adds the capture button for the custom camera view
     */
    fileprivate func addCaptureButton()
    {
        //CAPTURE BUTTON
        //
        
        let buttonSizeAndPadding = self.captureButtonSize + self.bottomPadding
        let buttonFrame =
            CGRect(x: self.view.frame.width/2 - self.bottomPadding  ,
                   y: self.view.frame.height  - buttonSizeAndPadding,
               width: self.captureButtonSize,
              height: self.captureButtonSize)
        
        self.capturePictureButton = UIButton(frame: buttonFrame)
        
        let nmessengerBundle = self.getNmessengerBundle()
        let rawButtonImage = UIImage(named: "shutterBtn",
                                        in: nmessengerBundle,
                            compatibleWith: nil)
        let buttonImage = rawButtonImage?.withRenderingMode(.alwaysTemplate)
        
        self.capturePictureButton.setImage(buttonImage, for: UIControlState())
        self.capturePictureButton.tintColor = UIColor.white
        
        //call the uiimagepickercontroller method takePicture()
        //
        self.capturePictureButton.addTarget( self,
                                     action: #selector(CameraViewController.capture(_:)),
                                        for: .touchUpInside)
        
    }
    /**
     Adds the flip button for the custom camera view
     */
    fileprivate func addFlipCameraButton()
    {
        //FLIP CAMERA BUTTON
        //
        
        let buttonSizeAndPadding = self.sideButtonSize + self.bottomPadding
        
        let buttonFrame =
            CGRect(x: self.bottomPadding,
                   y: self.view.frame.height - buttonSizeAndPadding,
               width: self.sideButtonSize,
              height: self.sideButtonSize)
        
        self.flipCamera = UIButton(frame: buttonFrame)
        self.flipCamera.addTarget( self,
                           action: #selector(CameraViewController.flipCamera(_:)),
                              for: .touchUpInside)
        
        let nmessengerBundle = self.getNmessengerBundle()
        let rawFlipCameraImage = UIImage(named: "flipCameraIcon",
                                            in: nmessengerBundle,
                                compatibleWith: nil)
        let flipCameraImage = rawFlipCameraImage?.withRenderingMode(.alwaysTemplate)
        
        self.flipCamera.setImage(flipCameraImage, for: UIControlState())
        self.flipCamera.tintColor = UIColor.white
    }
    /**
     Adds the toolbar for the custom camera view
     */
    fileprivate func addCameraToolBar()
    {
        //CAMERA TOOLBAR
        //
        
        let toolbarFrame =
            CGRect(x: 0,
                   y: 0,
               width: self.view.frame.width,
              height: 60)
        self.cameraToolbar = UIToolbar(frame: toolbarFrame)
            self.cameraToolbar.barStyle      = .blackTranslucent
            self.cameraToolbar.isTranslucent = true
        
        // button setup
        //
        let exitButtonFrame =
            CGRect(x: 20,
                   y: 10,
               width: 40,
              height: 40)
        let exitButton = UIButton(frame: exitButtonFrame)
        
        let nmessengerBundle = self.getNmessengerBundle()
        
        let rawExitButtonImage = UIImage(named: "exitIcon",
                                            in: nmessengerBundle,
                                compatibleWith: nil)
        let exitButtonImage = rawExitButtonImage?.withRenderingMode(.alwaysTemplate)
        
        exitButton.setImage(exitButtonImage, for: UIControlState())
        exitButton.tintColor = UIColor.white
        exitButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        exitButton.addTarget( self,
                      action: #selector(CameraViewController.exitButtonPressed),
                         for: .touchUpInside)
        self.cameraToolbar.addSubview(exitButton)
    }
    /**
     Adds the flash button for the custom camera view
     */
    open func addFlashButton()
    {
        //Flash Button
        //
        
        let flashButtonFrame =
            CGRect(x: self.view.frame.width - 60,
                   y: 10,
               width: 40,
              height: 40)
        self.flashButton = UIButton(frame: flashButtonFrame)
        
        let nmessengerBundle = self.getNmessengerBundle()
        
        let rawFlashButtonImage = UIImage(named: "flashIcon",
                                             in: nmessengerBundle,
                                 compatibleWith: nil)
        let flashButtonImage = rawFlashButtonImage?.withRenderingMode(.alwaysTemplate)
        
        self.flashButton.setImage(flashButtonImage, for: UIControlState())
        self.flashButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.flashButton.tintColor = UIColor.white
        
        self.flashButton.addTarget( self,
                            action: #selector(CameraViewController.toggleFlash(_:)),
                               for: .touchUpInside)
        self.cameraToolbar.addSubview(self.flashButton)
    }
    
    //MARK: ImagePickerDelegate Methods
    /**
     Implementing didFinishPickingMediaWithInfo to send the selected image to the cameraDelegate
     */
    open func imagePickerController(_ picker: UIImagePickerController,
          didFinishPickingMediaWithInfo info: [String : Any])
    {
        let myImage:UIImage? =
            PickedImageHelper.getImageFromPicker(self, completionOptions: info)
        
        if let myImageExisting = myImage
        {
            self.cameraDelegate?.pickedImages([myImageExisting])
            
            // TODO: 
            //
            //self.cameraDelegate?.pickedImageAssets([assetForMyImage])
        }
    }
    /**
     Implementing imagePickerControllerDidCancel to go back to camera view or close the view
     */
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        switch self.selection
        {
        case .camera where self.isCameraSourceUnavailable() :
            self.cameraDelegate?.cameraCancelSelection()
            
        case .library:
            self.changePictureMode()
            
        default:
            break
        }
    }
    
    //MARK: Selectors
    /**
     Changes between camera view and gallery view
     */
    @objc open func changePictureMode()
    {
        switch self.selection
        {
        case .camera:
            self.selection = SelectionType.library
            self.removeCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
        case .library where (self.isCameraAvailable && self.isCameraAuthorized()):
            self.selection = SelectionType.camera
            self.addCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.camera
            self.orientCamera(self.flipCamera)
            self.setFlash(self.flashButton)
            
        default:
            self.cameraDelegate?.cameraCancelSelection()
        }
    }
    
    
    /**
     Adds buttons for the camera view
     */
    fileprivate func addCameraElements()
    {
        if (self.selection == SelectionType.camera)
        {
            self.view.addSubview(self.galleryImage        )
            self.view.addSubview(self.gallery             )
            self.view.addSubview(self.flipCamera          )
            self.view.addSubview(self.capturePictureButton)
            self.view.addSubview(self.cameraToolbar       )
        }
    }
    /**
     Removes from the camera view
     */
    fileprivate func removeCameraElements()
    {
        if (self.selection != SelectionType.camera)
        {
            self.galleryImage        .removeFromSuperview()
            self.gallery             .removeFromSuperview()
            self.flipCamera          .removeFromSuperview()
            self.capturePictureButton.removeFromSuperview()
            self.cameraToolbar       .removeFromSuperview()
        }
    }
    /**
     Closes the view
     */
    @objc open func exitButtonPressed()
    {
        self.cameraDelegate?.cameraCancelSelection()
    }
    /**
     Takes a photo
     */
    @objc open func capture(_ sender: UIButton)
    {
        self.takePicture()
    }
    /**
     Enables/disables flash
     */
    @objc open func toggleFlash(_ sender: UIButton)
    {
        if (!sender.isSelected)
        {
            sender.tintColor = UIColor.n1ActionBlueColor()
            sender.isSelected = true
        }
        else
        {
            sender.tintColor = UIColor.white
            sender.isSelected = false
        }
        self.setFlash(sender)
    }
    /**
     Enables/disables flash
     */
    fileprivate func setFlash(_ sender: UIButton)
    {
        if (sender.isSelected)
        {
            self.cameraFlashMode = .on
        }
        else
        {
            self.cameraFlashMode = .off
        }
    }
    /**
     Changes the camera from front to back
     */
    @objc open func flipCamera(_ sender: UIButton)
    {
        if (!sender.isSelected)
        {
            sender.tintColor = UIColor.n1ActionBlueColor()
            sender.isSelected = true
        }
        else
        {
            sender.tintColor = UIColor.white
            sender.isSelected = false
        }
        self.orientCamera(sender)
    }
    /**
     Changes the camera from front to back
     */
    fileprivate func orientCamera(_ sender:UIButton)
    {
        if (sender.isSelected)
        {
            self.cameraDevice = .front
        }
        else
        {
            self.cameraDevice = .rear
        }
    }
    
    
    //MARK: Camera Permissions with completion
    /**
     Requests access for the camera and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    open func isCameraPermissionGranted(
        _ completion:@escaping CameraPermissionCallback)
    {
        let callbackHook: CameraPermissionCallback =
        {
            [weak weakSelf = self]
            (granted) in
            
            weakSelf?.cameraAuthStatus =
                AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            completion(granted)
        }
        
        self.requestAccessForCamera(callbackHook)
    }
    /**
     Requests access for the camera and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    open func requestAccessForCamera(
        _ completion:@escaping CameraPermissionCallback)
    {
        AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                 completionHandler: completion)
    }
    
    //MARK: Photolibrary Permissions
    /**
     Requests access for the library and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    open func requestPhotoLibraryPermissions(
        _ completion: @escaping PhotoLibraryPermissionCallback)
    {
        PHPhotoLibrary.requestAuthorization
        {
            [weak weakSelf = self]
            status in
     
            weakSelf?.photoLibAuthStatus =
                PHPhotoLibrary.authorizationStatus()
            
            switch status
            {
                case .authorized: completion(true)
                case .denied, .notDetermined, .restricted : completion(false)
            }
        }
    }
    
    open func cleanupSelectedAttachments()
    {
        // IDLE - multiple selection not supported by this class
    }
    
    public func removeSelectedAttachment(at index: Int) {
        // IDLE - Not supported here
    }
}
