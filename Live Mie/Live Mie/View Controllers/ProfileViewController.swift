//
//  ProfileViewController.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/30/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    // MARK: Constants
    
    // MARK: IBOutlets
    @IBOutlet weak var imgProfile: CCImageView!
    @IBOutlet weak var tvName: UILabel!
    @IBOutlet weak var tvEmail: UILabel!
    @IBOutlet weak var tfStatus: CCTextField!
    
    // MARK: Variables
    let mImagePicker = UIImagePickerController()
    var mSelectedImage: UIImage? {
        didSet {
            imgProfile?.image = mSelectedImage
            imgProfile?.contentMode = .scaleAspectFill
            imgProfile?.clipsToBounds = true
            uploadProfileImage(image: mSelectedImage!)
        }
    }
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Helper Methods
    func initViews() {
        guard let loggedUser = FIRAuthHelper.getUser() else {return self.dismiss(animated: true, completion: nil)}
        DialogUtil.showProgress()
        FIRDatabaseHelper.shared.getUserInfo(id: nil, success: { (user) in
            DialogUtil.hideProgress()
            self.tvName.text = user.name
            self.tvEmail.text = loggedUser.email
            if let url = user.imageUrl {
                UIUtil.loadImage(imageView: self.imgProfile, link: url, showProcessing: true)
            }
            self.tfStatus.text = user.status
            PreferenceUtil.save(user: user)
        }) { (message) in
            DialogUtil.hideProgress()
            DialogUtil.showMessage(title: "Error", message: message ?? "Unable to get user profile info", controller: self, okHandler: nil)
        }
    }
    
    func uploadProfileImage(image: UIImage) {
        DialogUtil.showProgress()
        FIRStorageHelper.shared.uploadProfilePicture(image: image, success: { (url) in
            FIRDatabaseHelper.shared.updateUserProfileUrl(id: nil, url: url.absoluteString, success: {
                let user = FIRAuthHelper.getUser()!
                user.imageUrl = url.absoluteString
                PreferenceUtil.save(user: user)
                DialogUtil.hideProgress()
            }, failure: { (message) in
                DialogUtil.hideProgress()
                DialogUtil.showMessage(title: "Error", message: "Unable to update profile picture url", controller: self, okHandler: nil)
            })
        }) { (message) in
            DialogUtil.hideProgress()
            DialogUtil.showMessage(title: "Upload Error", message: "Unable to update profile picture", controller: self, okHandler: nil)
        }
    }
    
    func updateStatus() {
        
    }
    
    
    // MARK: IBActions
    @IBAction func onEditImageClick(_ sender: Any) {
        let sheet = UIAlertController(title: "Select Picture", message: "Choose option to provide offer picture", preferredStyle: .actionSheet)
        if let presenter = sheet.popoverPresentationController {
            presenter.sourceView = sender as! UIButton
            presenter.sourceRect = (sender as! UIButton).bounds
        }
        sheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openCameraToCaptureImage()
        }))
        sheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (action) in
            self.openGalleryToSelectImage()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }
    @IBAction func onCloseClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onSignOutClick(_ sender: Any) {
        DialogUtil.showConfirmationDialog(title: "Confirmation", message: "Do you want to log out?", controller: self, positive: UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            FIRAuthHelper.signout(success: {
                AppUtils.showLoginView(controller: nil)
            }, failure: { (message) in
                DialogUtil.showMessage(title: "Failed", message: "Lo out operation failed.", controller: self, okHandler: nil)
            })
        }), negative: UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    @IBAction func onUpdateClick(_ sender: Any) {
        let status = tfStatus.text!
        let user = FIRAuthHelper.getUser()!
        DialogUtil.showProgress()
        if user.status != status {
            FIRDatabaseHelper.shared.updateUserStatus(id: nil, status: status, success: {
                DialogUtil.hideProgress()
                user.status = status
                PreferenceUtil.save(user: user)
                self.dismiss(animated: true, completion: nil)
            }) { (message) in
                DialogUtil.hideProgress()
                ToastUtil.show(message: message ?? "Status not updated")
            }
        }
        
    }
    
    
}

// MARK: UIImagePickerControllerDelegate Methods
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func openCameraToCaptureImage() {
        mImagePicker.delegate = self
        mImagePicker.allowsEditing = false
        mImagePicker.sourceType = UIImagePickerController.SourceType.camera
        present(mImagePicker, animated: true, completion: nil)
    }
    
    func openGalleryToSelectImage() {
        mImagePicker.delegate = self
        mImagePicker.allowsEditing = false
        mImagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(mImagePicker, animated: true, completion: nil)
    }
    
    func selectedImage(image: UIImage) {
        mSelectedImage = image
    }
}
