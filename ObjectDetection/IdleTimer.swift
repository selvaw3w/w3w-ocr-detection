//
//  IdleTimer.swift
//  ObjectDetection
//
//  Created by Lshiva on 14/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import Foundation

class IdleTimer {

    var timer : Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }

    func startTimer() {
        timer?.invalidate()
        //timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(), userInfo: nil, repeats: false)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        timer?.invalidate()
        self.startTimer()
    }
}
