//
//  ReportViewControllerFactoryImp.swift
//  ObjectDetection
//
//  Created by Lshiva on 05/06/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit

extension DependencyContainer: ReportViewControllerFactory {
    func instantiateReportController() -> ReportController {
        let reportController = UIStoryboard.main.instantiateViewController(identifier: "ReportController") as! ReportController
        return reportController
    }
}
