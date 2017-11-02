//
//  Router.swift
//  CameraML
//
//  Created by Kviatkovskii on 26.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

final class Router {
    fileprivate let rootViewController: UINavigationController
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    // контроллер на главный экран
    func showMainController() {
        rootViewController.setViewControllers([MainViewController(router: self)], animated: true)
        rootViewController.isNavigationBarHidden = true
        rootViewController.navigationBar.isTranslucent = false
    }
    
    // показываем просмоторщик, фото в библиотеке
    func showLookPhotoLibrary(controller: UIImagePickerController, image: UIImage, delegate: LookPhotoLibraryDelegate) {
        let dependeces = LookPhotoDependeces(image, delegate)
        let lookPhotoLibraryControler = LookPhotoViewController(dependeces)
        controller.present(lookPhotoLibraryControler, animated: true, completion: nil)
    }
}
