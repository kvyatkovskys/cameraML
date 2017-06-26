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
        rootViewController.setViewControllers([ViewController()], animated: true)
        rootViewController.isNavigationBarHidden = true
        rootViewController.navigationBar.isTranslucent = false
    }
}
