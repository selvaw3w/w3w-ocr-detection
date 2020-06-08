//
//  ApplicationCoordinator.swift
//  ObjectDetection
//
//  Created by Lshiva on 03/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import Foundation

final class ApplicationCoordinator: BaseCoordinator {

    // MARK: - Vars & Lets
    private let factory: Factory
    private let router: RouterProtocol
    private var launchInstructor: LaunchInstructor
    
    // MARK: - Init
    
    init(router: RouterProtocol, factory: Factory, launchInstructor: LaunchInstructor) {
        self.router = router
        self.factory = factory
        self.launchInstructor = launchInstructor
    }
    
    // MARK: - Coordinator
    
    override func start(with option: DeepLinkOption?) {
        if option != nil {
            
        } else {
            switch launchInstructor {
            case .onboarding: runOnboardingFlow()
            case .auth: runScanFlow()
            case .main: runMainFlow()
            }
        }
    }
    
    // MARK: - Private methods
       
    private func runScanFlow() {
        let coordinator = self.factory.instantiateScanCoordinator(router: self.router)
        coordinator.finishFlow = { [unowned self] in
            self.removeDependency(coordinator)
            self.start()
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
    
    private func runReportFlow() {
        let coordinator = self.factory.instantiateReportCoordinator(router: self.router)
        coordinator.finishFlow = { [unowned self] in
            self.removeDependency(coordinator)
            self.start()
        }
        self.addDependency(coordinator)
        coordinator.start()

    }
    private func runOnboardingFlow() {
//       let coordinator = self.factory.instantiateWalktroughCoordinator(router: self.router)
//       coordinator.finishFlow = { [unowned self, unowned coordinator] in
//           self.removeDependency(coordinator)
//           self.launchInstructor = LaunchInstructor.configure(isAutorized: true, tutorialWasShown: true)
//           self.start()
//       }
//       self.addDependency(coordinator)
//       coordinator.start()
    }
       
    private func runMainFlow() {
        
    }
}
