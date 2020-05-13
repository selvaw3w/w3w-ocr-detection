//
//  AuthCoordinatorOutput.swift
//  EncoreJets
//
//  Created by LShiva on 4/11/18.
//  Copyright © 2020 LShiva. All rights reserved.
//

import Foundation

protocol CoordinatorFinishOutput {
    var finishFlow: (() -> Void)? { get set }
}
