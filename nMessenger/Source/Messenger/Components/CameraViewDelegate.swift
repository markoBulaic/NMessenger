//
//  CameraViewDelegate.swift
//  nMessenger
//
//  Created by Oleksandr Dodatko on 17/07/2017.
//  Copyright © 2017 Ebay Inc. All rights reserved.
//

import Foundation
import UIKit
import Photos


//MARK: CameraViewController
/**
 CameraViewDelegate protocol for NMessenger.
 Defines methods to be implemented inorder to use the CameraViewController
 */
public protocol CameraViewDelegate : class
{
    /**
     Should define behavior when a photo is selected.
     Is called together with `pickedImageAssets()`.
     
     Provides UIImage objects to update the GUI.
     */
    func pickedImages(_ image: [UIImage])
    
    /**
     Should define behavior when a photo is selected.
     Is called together with `pickedImages()`.
     
     Provides low level details and metadata to use with business logic.
     */
    func pickedImageAssets(_ assets: [PHAsset])
    
    /**
     Should define behavior cancel button is tapped
     */
    func cameraCancelSelection()
    
    func nmessengerDidShowPicker()
}


