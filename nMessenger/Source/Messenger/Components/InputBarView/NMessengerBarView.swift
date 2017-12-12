//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AVFoundation
import Photos

//MARK: InputBarView
/**
 InputBarView class for NMessenger.
 Define the input bar for NMessenger. This is where the user would type text and open the camera or photo library.
 */
open class NMessengerBarView: InputBarView
    , UITextViewDelegate
    , CameraViewDelegate
{
    //MARK: IBOutlets
    //@IBOutlet for InputBarView
    @IBOutlet open weak var inputBarView: UIView!
    
    @IBOutlet open weak var photoPickerButton: UIButton!
    @IBOutlet open weak var badgeLabel: UILabel?
    
    @IBOutlet open weak var inputTextPlaceholderLabel: UILabel?
    
    //@IBOutlet for send button
    @IBOutlet open weak var sendButton: UIButton!
    //@IBOutlets NSLayoutConstraint input area view height
    @IBOutlet open weak var textInputAreaViewHeight: NSLayoutConstraint!
    //@IBOutlets NSLayoutConstraint input view height
    @IBOutlet open weak var textInputViewHeight: NSLayoutConstraint!
    
    @IBOutlet open weak var textInputViewTopMargin   : NSLayoutConstraint?
    @IBOutlet open weak var textInputViewBottomMargin: NSLayoutConstraint?
    
    @IBOutlet weak var symbolsCounterLabel: UILabel?
    
    private var isEmptyInputText: Bool = true
    
    public var text: String
    {
        if self.isEmptyInputText
        {
            return ""
        }
        
        if let text = self.textInputView.text
        {
            return text
        }
        
        return ""
    }
    
    //MARK: Public Parameters
    //Reference to CameraViewController
    open lazy var cameraVC: UIViewController /*protocol<ICameraViewController>*/ = CameraViewController()
    
    open var cameraVcProto: ICameraViewController
    {
        return self.cameraVC as! ICameraViewController
    }
    
    open var alertUtils: IModalAlertUtilities = ModalAlertUtilities()
    {
        didSet
        {
            self.cameraVcProto.alertUtils = self.alertUtils
        }
    }
    
    //CGFloat to the fine the number of rows a user can type
    open var numberOfRows: CGFloat = 3
    open var maxSymolsCountInMessage: Int? = nil
    open var minSymbolsToShowCounter: Int? = nil
    open var isSendingEmptyTextAllowed: Bool = false
    open var isPickerDismissedImplicitly: Bool = true
    
    open var canSendMessage: Bool = true
    
    //String as placeholder text in input view
    open var inputTextViewPlaceholder: String =
        Bundle.main.localizedString(forKey: "Chat.InputField.PlaceholderText",
                                     value: "==Write a message==",
                                     table: nil)
    {
        willSet {
            
            // legacy code support
            if let inputTextPlaceholderLabel = inputTextPlaceholderLabel
            {
                inputTextPlaceholderLabel.text = newValue
            }
            else
            {
                self.textInputView.text = newValue
            }
        }
    }
    
    //MARK: Private Parameters
    //CGFloat as defualt height for input view
    public var textInputViewHeightConst:CGFloat = 30
    
    // MARK: Initialisers
    /**
     Initialiser the view.
     */
    public required init()
    {
        super.init()
    }
    
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     Calls helper method to setup the view
     */
    public required init(controller:NMessengerViewController)
    {
        super.init(controller: controller)
        loadFromBundle()
    }
    
    public required init(controller: NMessengerViewController,
                            nibName: String,
                             bundle: Bundle)
    {
        super.init(controller: controller)
        
        self.loadFrom(bundle: bundle, nibName: nibName)
    }
    
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     - parameter frame: Must be CGRect. Sets frame for the view.
     Calls helper method to setup the view
     */
    public required init(controller: NMessengerViewController,
                              frame: CGRect)
    {
        super.init(controller: controller,
                        frame: frame)
        
        loadFromBundle()
    }
    /**
     - parameter aDecoder: Must be NSCoder
     Calls helper method to setup the view
     */
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        loadFromBundle()
    }
    
    // MARK: Initialiser helper methods
    /**
     Loads the view from nib file InputBarView and does intial setup.
     */
    fileprivate func loadFromBundle()
    {
        let nmessengerBundle = Bundle(for: NMessengerViewController.self)
        let nibName = "NMessengerBarView"
        
        
        self.loadFrom(bundle: nmessengerBundle, nibName: nibName)
    }
    
    fileprivate func loadFrom(bundle: Bundle,
                             nibName: String)
    {
        let nibObjects = bundle.loadNibNamed( nibName,
                                       owner: self,
                                     options: nil)
        /*let fileOwnerSelf*/ _ = nibObjects?[0] as! UIView
        
        self.addSubview(inputBarView)
        inputBarView.frame                = self.bounds
        textInputView.delegate            = self
        self.disableSendButton()
        self.cameraVcProto.cameraDelegate = self
        self.symbolsCounterLabel?.isHidden = true
        
        self.inputTextPlaceholderLabel?.isUserInteractionEnabled = false
    }
    
    //MARK: TextView delegate methods
    
    /**
     Implementing textViewShouldBeginEditing in order to set the text indictor at position 0
     */
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        // legacy code support
        if self.inputTextPlaceholderLabel == nil {
            
            textView.text = ""
            self.isEmptyInputText = true
            
            textView.textColor = UIColor.n1DarkestGreyColor()
            
            DispatchQueue.main.async
            {
                textView.selectedRange = NSMakeRange(0, 0)
            }
        }
        
        UIView.animate(withDuration: 0.1)
        {
            self.enableSendButton()
        }
        
        return true
    }
    
    /**
     Implementing textViewShouldEndEditing in order to re-add placeholder and hiding send button when lost focus
    */
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        if (nil != self.inputTextPlaceholderLabel)
        {
            let isNoText = self.textInputView.text.isEmpty
            
            if (isNoText)
            {
                UIView.animate(withDuration: 0.1)
                {
                    self.disableSendButton()
                }
            }
            else
            {
                // idle
            }
        }
        else
        {
            // legacy logic
            
            UIView.animate(withDuration: 0.1)
            {
                self.disableSendButton()
            }
        }
        
        self.textInputView.resignFirstResponder()
        return true
    }
    
    open func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String)
    -> Bool
    {
        //
        // Some logic deleted by A.Tyutin
        // to allow inserting "> 4k" symbols
        //
        //
        
        self.isEmptyInputText = false
        
        return true
    }
    
    
    private func updateSendButton() {
        
        var sendingAllowed = false
        
        let text = self.textInputView.text
        
        if text == nil || text!.isEmpty {
            sendingAllowed = false
            
        } else {
            
            if let maxSymolsCountInMessage = self.maxSymolsCountInMessage {
                
                guard let requiredText = text else { return }
                
                sendingAllowed = text!.characters.count <= maxSymolsCountInMessage
                sendingAllowed = sendingAllowed && self.containsSufficientSymbols(with: requiredText)
            }
        }
        
        UIView.animate(withDuration: 0.1) {
            
            self.updateSendButtonState(isSendingAllowed: sendingAllowed)
        }
    }
    
    private func getNumberOfLines(forText newText: String,
                              inTextView textView: UITextView) -> CGFloat
    {
        let textSize = size(of: newText, in: textView)
        
        let numberOfLines = textSize.height / textView.font!.lineHeight

        return numberOfLines
    }
    
    private func topAndBottomMarginsForTextView() -> CGFloat
    {
        guard let textInputViewTopMargin    = self.textInputViewTopMargin   ,
              let textInputViewBottomMargin = self.textInputViewBottomMargin
        else
        {
            // legacy value
            //
            return 10
        }
        
        let result = textInputViewTopMargin.constant + textInputViewBottomMargin.constant
        return result
    }
    
    private func size(of text: String, in textView: UITextView) -> CGSize {
        
        let textViewInsets = UIEdgeInsetsInsetRect(textView.frame,
                                                   textView.textContainerInset)
        
        let textWidth: CGFloat = textViewInsets.width
            - 2.0 * textView.textContainer.lineFragmentPadding
        
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin,
                                               .usesFontLeading]
        
        let attributes: [NSAttributedStringKey: Any] = [.font: textView.font!]
        
        
        let textBounds = CGSize(width: textWidth, height: 0)
        let boundingRect: CGRect = text.boundingRect(with: textBounds,
                                                     options: options,
                                                     attributes: attributes,
                                                     context: nil)
        
        return CGSize(width: ceil(boundingRect.width),
                      height: ceil(boundingRect.height))
    }
    
    private func containerSize(for textSize: CGSize, in textView: UITextView) -> CGSize {
        let width = textSize.width
            + textView.textContainerInset.left
            + textView.textContainerInset.right
        
        let height = textSize.height
            + textView.textContainerInset.top
            + textView.textContainerInset.bottom

        return CGSize(width: width, height: height)
    }
    
    /**
     Implementing textViewDidChange in order to resize the text input area
     */
    open func textViewDidChange(_ textView: UITextView)
    {
        self.inputTextPlaceholderLabel?.isHidden = !textView.text.isEmpty
        
        let fixedWidth = textView.frame.size.width
        
        var textSize = self.size(of: textView.text, in: textView)
        
        textSize.height = min(textSize.height, self.numberOfRows * textView.font!.lineHeight)
        
        let newSize = self.containerSize(for: textSize, in: textView)
        
        var newFrame = textView.frame
        let newFrameWidth  = max(newSize.width, fixedWidth)
        let newFrameHeight = max(newSize.height, self.textInputViewHeightConst)
        
        newFrame.size = CGSize(width: newFrameWidth,
                               height: newFrameHeight)
        
        let textViewMarginsHeight = self.topAndBottomMarginsForTextView()
        self.textInputViewHeight.constant = newFrame.size.height
        self.textInputAreaViewHeight.constant = newFrame.size.height + textViewMarginsHeight
        
        let symbolsCount = textView.text.characters.count
        
        if
            let maxSymbols = self.maxSymolsCountInMessage,
            let minSymbols = self.minSymbolsToShowCounter,
            let counterLabel = self.symbolsCounterLabel
        {
            // TODO: localize `counterLabel.text` pattern
            //
            counterLabel.text = "\(symbolsCount)/\n\(maxSymbols)"
            
            counterLabel.isHidden = (symbolsCount < minSymbols)
            counterLabel.textColor =
                (symbolsCount <= maxSymbols)
                    ? UIColor.gray
                    : UIColor.red
        }
        
        var isEnabled = !(textView.text.isEmpty)
        
        if self.isSendingEmptyTextAllowed
        {
            isEnabled = true
        }
        
        self.updateSendButtonState(isSendingAllowed: isEnabled)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.updateSendButton()
        
        if !self.canSendMessage {
            self.disableSendButton()
        }
    }
    
    //MARK: TextView helper methods
    /**
     Adds placeholder text and change the color of textInputView
     */
    
    fileprivate func addInputSelectorPlaceholder()
    {
        self.textInputView.text = self.inputTextViewPlaceholder
        self.textInputView.textColor = UIColor.lightGray
        self.isEmptyInputText = true
        
        self.disableSendButton()
    }

    /*
     check text existance in textView's text without spaces and newLines
     */
    
    fileprivate func containsSufficientSymbols(with text: String) -> Bool {
        
        let stringWithoutSpaces = text.replacingOccurrences(of: " ", with: "")
        let stringWithoutNewLinesAndSpaces = stringWithoutSpaces.replacingOccurrences(of: "\n", with: "")
        return !stringWithoutNewLinesAndSpaces.isEmpty
    }
    
    
    //MARK: @IBAction selectors
    /**
     Send button selector
     Sends the text in textInputView to the controller
     */
    @IBAction open func sendButtonClicked(_ sender: AnyObject)
    {
        self.doSend()
    }
    
    private func doSend()
    {
        var currentText: String = ""
        self.inputTextPlaceholderLabel?.isHidden = false
        
        if (self.isEmptyInputText)
        {
            currentText = ""
        }
        else if (!self.isSendingEmptyTextAllowed)
        {
            guard let legacyCurrentText = self.textInputView.text,
                  !legacyCurrentText.isEmpty
            else
            {
                return
            }
            
            currentText = legacyCurrentText
        }
        else
        {
            currentText = self.textInputView.text ?? ""
        }

        self.controller.onSendButtonTapped(havingText: currentText)
        self.cleanupTextFieldAndResize()
    }

    fileprivate func updateSendButtonState(isSendingAllowed: Bool)
    {
        // duplicated assignments for easier debugging
        //
        if (isSendingAllowed)
        {
            self.enableSendButton()
        }
        else
        {
            self.disableSendButton()
        }
    }
    
    fileprivate func disableSendButton()
    {
        // duplicated assignments for easier debugging
        //
        
        self.sendButton.isEnabled = false
        self.sendButton.isUserInteractionEnabled = false
    }
    
    fileprivate func enableSendButton()
    {
        // duplicated assignments for easier debugging
        //
        
        self.sendButton.isEnabled = true
        self.sendButton.isUserInteractionEnabled = true
    }
    
    private func cleanupTextFieldAndResize()
    {
        let textViewMarginsHeight = self.topAndBottomMarginsForTextView()
        self.textInputViewHeight.constant = self.textInputViewHeightConst
        
        
        self.textInputAreaViewHeight.constant =
            self.textInputViewHeightConst
            + textViewMarginsHeight

        self.disableSendButton()
        
        self.textInputView.text = ""
        self.symbolsCounterLabel?.isHidden = true
        
        self.isEmptyInputText = true
    }
    
    
    /**
     Plus button selector
     Requests camera and photo library permission if needed
     Open camera and/or photo library to take/select a photo
     */
    @IBAction open func plusClicked(_ sender: AnyObject?)
    {
        self.checkCameraPermissions { [weak self] cameraPermissionsGranted in
            
            self?.checkPhotoLibraryPermissions { [weak self] photoLibraryPermissionsGranted in
                
                self?.showPickerView(executeAfterTransition: { [weak self] in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    // FIXME: Application crashes if camera permissions were not granted
                    switch (cameraPermissionsGranted, photoLibraryPermissionsGranted) {
                        
                    case (true, true):
                        break
                        
                    case (false, true):
                        
                        strongSelf.alertUtils
                            .postGoToSettingToEnableCameraModal(fromController: strongSelf.cameraVC)
                        
                    case (true, false):
                        
                        strongSelf.alertUtils
                            .postGoToSettingToEnableLibraryModal(fromController: strongSelf.cameraVC)
                        
                    case (false, false):
                        
                        strongSelf.alertUtils
                            .postGoToSettingToEnableCameraAndLibraryModal(fromController: strongSelf.cameraVC)
                    }
                })
            }
        }
    }
    
    private func checkCameraPermissions(_ completion: @escaping (Bool) -> Void) {
        
        let authStatus = self.cameraVcProto.cameraAuthStatus

        if authStatus != AVAuthorizationStatus.authorized {
            
            self.cameraVcProto.isCameraPermissionGranted(completion)
            
        } else {
            
            completion(true)
        }
    }
    
    private func checkPhotoLibraryPermissions(_ completion: @escaping (Bool) -> Void) {
        
        let photoLibAuthStatus = self.cameraVcProto.photoLibAuthStatus
        
        if photoLibAuthStatus != PHAuthorizationStatus.authorized {
            
            self.cameraVcProto.requestPhotoLibraryPermissions(completion)
            
        } else {
            
            completion(true)
        }
    }
    
    //MARK: CameraView delegate methods
    //
    //
    
    /**
     Implemetning CameraView delegate method
     Close the CameraView and sends the image to the controller
     */
    open func pickedImages(_ images: [UIImage])
    {
        if self.isPickerDismissedImplicitly
        {
            self.hidePickerView()
        }
        self.controller.onImagesPicked(images)
    }
    
    open func pickedAssets(_ assets: [PHAsset])
    {
        self.controller.onAssetsPicked(assets)
    }
    

    
    
    private typealias ShowPickerViewCompletion = () -> Swift.Void
    private func showPickerView(
        executeAfterTransition callback: ShowPickerViewCompletion?)
    {
        DispatchQueue.main.async
        {
            self.doShowPickerView(executeAfterTransition: callback)
        }
    }
    
    private func doShowPickerView(
        executeAfterTransition callback: ShowPickerViewCompletion?)
    {
        if (self.isPickerCameraVc())
        {
            // legacy behaviour
            //
            self.controller.present( self.cameraVC,
                           animated: true,
                         completion: callback)
        }
        else if let navBar = self.controller.navigationController
        {
            navBar.pushViewController(self.cameraVC, animated: true)
            
            if let callbackUnwrap = callback
            {
                DispatchQueue.main.async
                {
                    // a hack to let the transition complete
                    callbackUnwrap()
                }
            }
        }
        else
        {
            // legacy behaviour
            //
            self.controller.present( self.cameraVC,
                                     animated: true,
                                     completion: callback)
        }
    }
    
    open func hidePickerView()
    {
        DispatchQueue.main.async
        {
            self.doHidePickerView()
        }
    }
    
    private func doHidePickerView()
    {
        if (self.isPickerCameraVc())
        {
            // legacy behaviour
            //
            self.cameraVC.dismiss(animated: true, completion: nil)
        }
        else if let navBar = self.controller.navigationController
        {
            navBar.popViewController(animated: true)
        }
        else
        {
            self.cameraVC.dismiss(animated: true, completion: nil)
        }
    }
    
    
    private func isPickerCameraVc() -> Bool
    {
        if let _ = self.cameraVC as? UIImagePickerController
        {
           return true
        }
    
        return false
    }
    
    /**
     Implemetning CameraView delegate method
     Close the CameraView
     */
    open func cameraCancelSelection()
    {
        self.hidePickerView()
    }

    /**
     Should define behavior when a photo is selected.
     Is called together with `pickedImages()`.
     
     Provides low level details and metadata to use with business logic.
     */
    public func pickedImageAssets(_ assets: [PHAsset])
    {
        // IDLE - this will be done in `self.pickedImages()`
        //
        // self.hidePickerView()
        
        if (!assets.isEmpty)
        {
            // a side effect...
            // to show the badge
            // in case of multiselection
            //
            self.enableSendButton()
        }
        
        self.controller.onAssetsPicked(assets)
    }
    
    public func nmessengerDidShowPicker()
    {
        self.controller.nmessengerDidShowPicker()
    }
}
