//
//  ReportCoordinator.swift
//  ObjectDetection
//
//  Created by Lshiva on 05/06/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit

class ReportCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
    //MARK: coordinator did finish output
    var finishFlow: (() -> Void)?
    
    
    //MARK: Vars & lets
    private let router : RouterProtocol
    private let factory : Factory
    
    //MARK: private methods
    private func showReportViewController() {
        let reportController = self.factory.instantiateReportController()
        reportController.onBack = { [unowned self] in
            self.router.popModule(transition: FadeAnimator(animationDuration: 0.1, isPresenting: true))
        }
        self.router.push(reportController, transition: FadeAnimator(animationDuration: 0.2, isPresenting: true))
    }
    
    // MARK: - Coordinator
    override func start() {
        self.showReportViewController()
    }
    
    //MARK: init
    init(router: RouterProtocol, factory: Factory) {
        self.router = router
        self.factory = factory
    }
}
