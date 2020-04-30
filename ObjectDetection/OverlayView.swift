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
        private let boundingBoxBorderThickness: CGFloat = 2.0
        // Border color of capture zone
        private let boundingBoxBorderColor: UIColor = UIColor .white
        //non-w3w detection background color
        public let nonW3wBackgroundColor: UIColor = UIColor.clear
        // w3w detection background color
        public let W3wBackgroundColor: UIColor = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 0.6)

        public var boundingBox: CGRect = CGRect.zero {
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
            context.setFillColor(W3wBackgroundColor.cgColor)
            
            context.fill(scaledBounds!)

            let intersection = self.boundingBox.intersection(scaledBounds!)
            context.addRect(intersection)
            context.clip()
            context.clear(intersection)

            context.setFillColor(UIColor.clear.cgColor)
            context.fill(intersection)

            context.restoreGState()
        }
        
        private func drawBorderLayer(_ context: CGContext!) {
            // Draw the outline of the capture zone
            self.addPathForboundingBox(context)
            context.setStrokeColor(boundingBoxBorderColor.cgColor)
            context.setLineWidth(boundingBoxBorderThickness)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }

        private func addPathForboundingBox(_ context: CGContext!) {
            let origin = self.boundingBox.origin
            let width = self.boundingBox.width
            let height = self.boundingBox.height

            let points = [origin,
                CGPoint.init(x: self.boundingBox.origin.x + width, y: origin.y),
                CGPoint.init(x: self.boundingBox.origin.x + width, y: origin.y + height),
                CGPoint.init(x: self.boundingBox.origin.x, y: origin.y + height)]

            context.addLines(between: points)
            context.closePath()
        }
    }

    extension UIView {
        func removeAllSubView() {
            self.subviews.forEach { $0.removeFromSuperview() }
    }
}
