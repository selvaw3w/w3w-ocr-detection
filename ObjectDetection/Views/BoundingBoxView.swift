import Foundation
import UIKit

class BoundingBoxView {

    let shapeLayer  : CAShapeLayer
    let textLayer   : CATextLayer

    init() {
    
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.isHidden = true

        textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.isHidden = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 16
        textLayer.font = UIFont(name: Config.Font.type.sourceLight, size: textLayer.fontSize)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
    }

    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        if (Settings.boolForKey(key: Config.w3w.developerMode) == true) {
            parent.addSublayer(textLayer)
        }
    }
    

    func show(frame: CGRect, label: String, color: UIColor) {
        
        let cornerLengthToShow = frame.size.height * 0.25

        let topLeftCorner = UIBezierPath()
        topLeftCorner.move(to: CGPoint(x: frame.minX, y: frame.minY + cornerLengthToShow))
        topLeftCorner.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
        topLeftCorner.addLine(to: CGPoint(x: frame.minX + cornerLengthToShow, y: frame.minY))

        let topRightCorner = UIBezierPath()
        topRightCorner.move(to: CGPoint(x: frame.maxX - cornerLengthToShow, y: frame.minY))
        topRightCorner.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
        topRightCorner.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + cornerLengthToShow))

        let bottomRightCorner = UIBezierPath()
        bottomRightCorner.move(to: CGPoint(x: frame.maxX, y: frame.maxY - cornerLengthToShow))
        bottomRightCorner.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        bottomRightCorner.addLine(to: CGPoint(x: frame.maxX - cornerLengthToShow, y: frame.maxY ))

        let bottomLeftCorner = UIBezierPath()
        bottomLeftCorner.move(to: CGPoint(x: frame.minX, y: frame.maxY - cornerLengthToShow))
        bottomLeftCorner.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
        bottomLeftCorner.addLine(to: CGPoint(x: frame.minX + cornerLengthToShow, y: frame.maxY))

        let combinedPath = CGMutablePath()
        combinedPath.addPath(topLeftCorner.cgPath)
        combinedPath.addPath(topRightCorner.cgPath)
        combinedPath.addPath(bottomRightCorner.cgPath)
        combinedPath.addPath(bottomLeftCorner.cgPath)
        
        shapeLayer.path = combinedPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
        textLayer.string = label
        textLayer.backgroundColor = color.cgColor
        
        textLayer.isHidden = false
        
        let attributes = [
          NSAttributedString.Key.font: textLayer.font as Any
        ]
        
        let originX = max(frame.origin.x, 0)
        let textRect = label.boundingRect(with: CGSize(width: 400, height: 100), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)
        let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
        let textOrigin = CGPoint(x: originX - 2, y: frame.origin.y - textSize.height)
        textLayer.frame = CGRect(origin: textOrigin, size: textSize)
        
    }

    func hide() {
        self.shapeLayer.isHidden = true
        self.textLayer.isHidden = true
    }
}
