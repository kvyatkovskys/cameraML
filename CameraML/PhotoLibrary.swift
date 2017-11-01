//
//  PhotoLibrary.swift
//  CameraML
//
//  Created by Kviatkovskii on 01/11/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import Photos

struct PhotoLibrary {

    func getLastPhoto(size: CGSize, getPhoto: @escaping (_ photo: UIImage?) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("authorized")
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let photos = PHAsset.fetchAssets(with: .image, options: options)
                
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                
                if let lastAsset: PHAsset = photos.lastObject {
                    let manager = PHImageManager.default()
                    
                    manager.requestImage(for: lastAsset,
                                         targetSize: size,
                                         contentMode: .aspectFill,
                                         options: requestOptions,
                                         resultHandler: { (image, _) in
                                            getPhoto(image)
                    })
                }
                
            case .denied, .restricted:
                print("Not allowed")
                getPhoto(nil)
            case .notDetermined:
                print("Not determined yet")
                getPhoto(nil)
            }
        }
    }
}
