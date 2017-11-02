//
//  AppInjections.swift
//  CameraML
//
//  Created by Kviatkovskii on 02/11/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import UIKit

protocol HasLookPhotoProvider {
    var image: UIImage { get }
    weak var delegate: LookPhotoLibraryDelegate? { get }
}

struct LookPhotoDependeces: HasLookPhotoProvider {
    let image: UIImage
    weak var delegate: LookPhotoLibraryDelegate?
    
    init(_ image: UIImage, _ delegate: LookPhotoLibraryDelegate) {
        self.image = image
        self.delegate = delegate
    }
}
