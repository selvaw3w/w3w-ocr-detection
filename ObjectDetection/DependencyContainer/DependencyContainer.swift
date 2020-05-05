//
//  DependencyContainer.swift
//  HauteCurator
//
//  Created by LShiva on 1/18/19.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit

typealias Factory = CoordinatorFactoryProtocol & ViewControllerFactory
typealias ViewControllerFactory = ScanViewControllerFactory  //& WalktroughViewControllerFactory

class DependencyContainer {
    
    // MARK: - Vars & Lets
    
    private var rootController: CoordinatorNavigationController
    
    // MARK: App Coordinator
    
    internal lazy var aplicationCoordinator = self.instantiateApplicationCoordinator()
        
    // MARK: - Public func
    
    func start() {
        self.aplicationCoordinator.start()
    }
    
    // MARK: - Initialization
    
    init(rootController: CoordinatorNavigationController) {
        self.rootController = rootController
        self.customizeNavigationController()
    }
    
    // MARK: - Private methods
    
    private func customizeNavigationController() {
        self.rootController.enableSwipeBack()
        self.rootController.customizeTitle(titleColor: UIColor.red,
                                           largeTextFont: UIFont(name: Config.Font.type.sourceLight, size: 22)!,
                                           smallTextFont: UIFont(name: Config.Font.type.sourceLight, size: 18)!,
                                           isTranslucent: true,
                                           barTintColor: UIColor.purple)
        self.rootController.customizeBackButton(backButtonImage: UIImage(named: "GoBack"),
                                      backButtonTitle: "Back3",
                                      backButtonfont: UIFont(name: Config.Font.type.sourceLight, size: 15),
                                      backButtonTitleColor: .black,
                                      shouldUseViewControllerTitles: true)
    }
}

// MARK: - Extensions
// MARK: - CoordinatorFactoryProtocol

extension DependencyContainer: CoordinatorFactoryProtocol {
    
    func instantiateApplicationCoordinator() -> ApplicationCoordinator {
        return ApplicationCoordinator(router: Router(rootController: rootController), factory: self as Factory, launchInstructor: LaunchInstructor.configure())
    }
    
    func instantiateScanCoordinator(router: RouterProtocol) -> ScanCoordinator {
        return ScanCoordinator(router: router, factory: self)
    }
    
//    func instantiateSettingsCoordinator(router: RouterProtocol) -> WalktroughCoordinator {
//        return SettingsCoordinator(router: router, factory: self)
//    }
    
}
