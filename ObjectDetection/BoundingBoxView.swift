import Foundation
import UIKit

class BoundingBoxView {

    let shapeLayer: CAShapeLayer
    let textLayer: CATextLayer
    let w3wLayer: CATextLayer

    init() {
    
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.isHidden = true

        textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.isHidden = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 16
        textLayer.font = UIFont(name: Config.Font.type.sourceLight, size: textLayer.fontSize)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center

        w3wLayer = CATextLayer()
        w3wLayer.foregroundColor = UIColor.black.cgColor
        w3wLayer.isHidden = true
        w3wLayer.contentsScale = UIScreen.main.scale
        w3wLayer.fontSize = 14
        w3wLayer.backgroundColor = Config.Font.Color.text.cgColor
        w3wLayer.font = UIFont(name: Config.Font.type.sourceLight, size: textLayer.fontSize)
        w3wLayer.alignmentMode = CATextLayerAlignmentMode.center

    }

    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        //TODO: show only for development parent.addSublayer(textLayer)
        parent.addSublayer(w3wLayer)
    }

    func show(frame: CGRect, label: String, w3w: String, color: UIColor) {
        CATransaction.setDisableActions(true)

        let path = UIBezierPath(rect: frame)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false

        textLayer.string = label
        textLayer.backgroundColor = color.cgColor
        textLayer.isHidden = false

        w3wLayer.string = w3w
        w3wLayer.backgroundColor = color.cgColor
        w3wLayer.isHidden = false


        let attributes = [
          NSAttributedString.Key.font: textLayer.font as Any
        ]

        let textRect = label.boundingRect(with: CGSize(width: 400, height: 100), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)
        let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
        let textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
        textLayer.frame = CGRect(origin: textOrigin, size: textSize)
            
            
        //TODO: change the x to 0 if less than zero
        let w3wTextRect = w3w.boundingRect(with: CGSize(width: 400, height: 100), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)
        let w3wTextSize = CGSize(width: w3wTextRect.width + 12, height: w3wTextRect.height)
        let w3wTextOrigin = CGPoint(x: textOrigin.x, y: frame.origin.y + frame.height)
        w3wLayer.frame = CGRect(origin: w3wTextOrigin, size: w3wTextSize)

    }

    func hide() {
        self.shapeLayer.isHidden = true
        self.textLayer.isHidden = true
        self.w3wLayer.isHidden = true
    }
}
