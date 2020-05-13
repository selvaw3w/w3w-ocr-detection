
//
//  BaseViewController.swift
//  ObjectDetection
//
//  Created by Lshiva on 03/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, CoordinatorNavigationControllerDelegate {

    // MARK: - Controller lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupNavigationController()
    }
    
    // MARK: - Private methods
    
    private func setupNavigationController() {
        if let navigationController = self.navigationController as? CoordinatorNavigationController {
            navigationController.swipeBackDelegate = self
        }
    }
    
    // MARK: - SwipeBackNavigationControllerDelegate
    
    internal func transitionBackFinished() {
        
    }
    
    internal func didSelectCustomBackAction() {
        
    }

}
