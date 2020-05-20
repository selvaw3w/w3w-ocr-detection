//
//  WGesture.swift
//  ObjectDetection
//
//  Created by Lshiva on 18/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum What3wordPhases {
        case notStarted
        case initialPoint
        case left_downwardStoke
        case left_upwardStoke
        case right_downwardStoke
        case right_upwardStoke
}

class WGesture: UIGestureRecognizer {

    var strokePhase : What3wordPhases = .notStarted
    
    //var state   : State = .began
    
    var initialTouchPoint : CGPoint = CGPoint.zero
    
    var trackedTouch : UITouch? = nil

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event!)
            
            if touches.count != 1 {
                self.state = .began
            }
            if self.trackedTouch == nil {
                self.trackedTouch = touches.first
                self.strokePhase = .initialPoint
                self.initialTouchPoint = (self.trackedTouch?.location(in: self.view))!
                self.state = .possible
            }
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesMoved(touches, with: event!)
           let newTouch = touches.first
           // There should be only the first touch.
           guard newTouch == self.trackedTouch else {
              self.state = .failed
              return
           }
           let newPoint = (newTouch?.location(in: self.view))!
           let previousPoint = (newTouch?.previousLocation(in: self.view))!
           if self.strokePhase == .initialPoint {
              // Make sure the initial movement is down and to the right.
              if newPoint.x >= initialTouchPoint.x && newPoint.y >= initialTouchPoint.y {
                 self.strokePhase = .left_downwardStoke
              } else {
                self.state = .failed
              }
           } else if self.strokePhase == .left_downwardStoke {
              // Always keep moving left to right.
              if newPoint.x >= previousPoint.x {
                 // If the y direction changes, the gesture is moving up again.
                 // Otherwise, the down stroke continues.
                 if newPoint.y < previousPoint.y {
                    self.strokePhase = .left_upwardStoke
                 }
              } else {
                // If the new x value is to the left, the gesture fails.
                self.state = .failed
              }
           } else if self.strokePhase == .left_upwardStoke {
                //Always keep moving right
                if newPoint.x >= previousPoint.x {
                    // if the y directio changes, the gesture is moving down again
                    // otherwise, the upward stoke continues
                    if newPoint.y > previousPoint.y {
                        self.strokePhase = .right_downwardStoke
                    }
                } else {
                    self.state = .failed
                }
           } else if self.strokePhase == .right_downwardStoke {
                // Always keep moving right
                if newPoint.x >= previousPoint.x {
                // If the y direction changes, the gesture is moving up again.
                // Otherwise, the down stroke continues.
                    if newPoint.y < previousPoint.y {
                        self.strokePhase = .right_upwardStoke
                    }
                } else {
                    self.state = .failed
                }
           } else if self.strokePhase == .right_upwardStoke {
                // If the new x value is to the left, or the new y value
                // changed directions again, the gesture fails.]
                if newPoint.x < previousPoint.x || newPoint.y > previousPoint.y {
                    self.state = .failed
                }
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event!)
            
                let newTouch = touches.first
            let newPoint = (newTouch?.location(in: self.view))!
            // There should be only the first touch.
            guard newTouch == self.trackedTouch else {
               self.state = .failed
               return
            }
            // If the stroke was moving up and the final point is
            // above the initial point, the gesture succeeds.
            if self.state == .possible &&
                  self.strokePhase == .right_upwardStoke &&
                  newPoint.y < initialTouchPoint.y {
               self.state = .recognized
            } else {
               self.state = .failed
            }
        }

}
