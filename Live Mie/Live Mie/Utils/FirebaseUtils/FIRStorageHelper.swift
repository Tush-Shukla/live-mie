//
//  FIRStorageHelper.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/30/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import Foundation
import FirebaseStorage

enum StorageFolders: String {
    case images = "images"
}

class FIRStorageHelper {
    static let shared = FIRStorageHelper()
    private var storage: Storage!
    
    private init(){
        storage = Storage.storage()
    }
    
    func uploadImage(folder: StorageFolders, name: String, image: UIImage,
                     success: @escaping (_ url: URL)->Void,
                     failure: @escaping (_ message: String?)->Void
        ) {
        // Data in memory
        guard let data = image.pngData() else {return failure("Error in image data")}
        let ref = storage.reference().child("\(folder.rawValue)/\(name).png")
        let _ = ref.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                return failure(error.debugDescription)
            }
            ref.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return failure(error?.localizedDescription)
                }
                success(downloadURL)
            }
        }
    }
}

extension FIRStorageHelper {
    func uploadProfilePicture(image: UIImage,
                              success: @escaping (_ url: URL)->Void,
                              failure: @escaping (_ message: String?)->Void) {
        guard let user = FIRAuthHelper.getUser(), let id = user._id else {return failure("User error")}
        uploadImage(folder: .images, name: id, image: image, success: { (url) in
            success(url)
        }) { (message) in
            failure(message)
        }
    }
}
