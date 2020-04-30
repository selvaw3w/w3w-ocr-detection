//
//  OCRSelectedAreaView.swift
//  ObjectDetection
//
//  Created by Lshiva on 29/04/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit

class OverlayView: UIView {
        // Border thickness of capture zone
        private let areaBorderThickness: CGFloat = 1.0
        // Background color
        private let areaFogColor: UIColor = UIColor(red: 0.22, green: 0.33, blue: 0.38, alpha: 0.5)
        // Border color of capture zone
        private let areaBorderColor: UIColor = UIColor .clear

        public var selectedArea: CGRect = CGRect.zero {
            didSet {
                DispatchQueue.main.async {
                    self.setNeedsDisplay()
                }
            }
        }

    //# MARK: - LifeCycle

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.doInit()
        }

        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.doInit()
        }

    //# MARK: - Private

        private func doInit() {
            self.isExclusiveTouch = true
        }

        override public func draw(_ rect: CGRect) {
            super.draw(rect)

            let currentContext = UIGraphicsGetCurrentContext()

            currentContext!.saveGState()
            currentContext!.translateBy(x: 0, y: 0)

            self.drawFogLayer(currentContext)
            self.drawBorderLayer(currentContext)

            currentContext!.restoreGState()
        }

        private func drawFogLayer(_ context: CGContext!) {
            context.saveGState()

            let scaledBounds = self.superview?.bounds

            // Fill the background
            context.setFillColor(areaFogColor.cgColor)
            
            context.fill(scaledBounds!)

            let intersection = self.selectedArea.intersection(scaledBounds!)
            context.addRect(intersection)
            context.clip()
            context.clear(intersection)

            context.setFillColor(UIColor.clear.cgColor)
            context.fill(intersection)

            context.restoreGState()
        }
        
        private func drawBorderLayer(_ context: CGContext!) {
            // Draw the outline of the capture zone
            self.addPathForSelectedArea(context)
            context.setStrokeColor(areaBorderColor.cgColor)
            context.setLineWidth(areaBorderThickness)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }

        private func addPathForSelectedArea(_ context: CGContext!) {
            let origin = self.selectedArea.origin
            let width = self.selectedArea.width
            let height = self.selectedArea.height

            let points = [origin,
                CGPoint.init(x: self.selectedArea.origin.x + width, y: origin.y),
                CGPoint.init(x: self.selectedArea.origin.x + width, y: origin.y + height),
                CGPoint.init(x: self.selectedArea.origin.x, y: origin.y + height)]

            context.addLines(between: points)
            context.closePath()
        }
    }

    extension UIView {
        func removeAllSubView() {
            self.subviews.forEach { $0.removeFromSuperview() }
    }
}
