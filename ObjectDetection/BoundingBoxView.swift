import Foundation
import UIKit

class BoundingBoxView {

    //let shapeLayer: CAShapeLayer
    let textLayer: CATextLayer
    let w3wLayer: CATextLayer
    let w3wRectLayer: CATextLayer
    var w3wText : String?
    var selfDestructtimer : Int?

    init() {
    
//        shapeLayer = CAShapeLayer()
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineWidth = 4
//        shapeLayer.isHidden = true

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
        
        w3wRectLayer = CATextLayer()
        w3wRectLayer.foregroundColor = UIColor.black.cgColor
        w3wRectLayer.borderColor = UIColor.white.cgColor
        w3wRectLayer.borderWidth = 6
        w3wRectLayer.contentsScale = UIScreen.main.scale
        w3wRectLayer.fontSize = 16
        w3wRectLayer.backgroundColor = UIColor.clear.cgColor
        w3wRectLayer.font = UIFont(name: Config.Font.type.sourceLight, size: textLayer.fontSize)
        w3wRectLayer.alignmentMode = CATextLayerAlignmentMode.center
        
    }

    func addToLayer(_ parent: CALayer) {
        //parent.addSublayer(shapeLayer)
        parent.addSublayer(textLayer)
        parent.addSublayer(w3wLayer)
        parent.addSublayer(w3wRectLayer)
    }

    func draw(frame: CGRect, label: String, w3w: String, color: UIColor) {
        CATransaction.setDisableActions(false)
//        let path = UIBezierPath(rect: frame)
//        shapeLayer.path = path.cgPath
//        shapeLayer.strokeColor = color.cgColor
//        shapeLayer.isHidden = false
                
        w3wRectLayer.string = " "
        w3wRectLayer.isHidden = false
        

        w3wLayer.string = w3w
        w3wLayer.backgroundColor = color.cgColor
        w3wLayer.isHidden = false
        w3wText = w3w


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
        
        let w3wRect = w3w.boundingRect(with: CGSize(width: 400, height: 100), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)
        w3wRectLayer.frame = CGRect(origin: frame.origin, size: frame.size)
    }
    
    func add(frame: CGRect, label: String, w3w: String, color: UIColor) {
        //CATransaction.setDisableActions(true)
        self.w3wRectLayer.removeAllAnimations()
        self.w3wLayer.removeAllAnimations()
        self.textLayer.removeAllAnimations()
        self.draw(frame: frame, label: label, w3w: w3w, color: color)
    }
    
    func update(frame: CGRect, label: String, w3w: String, color: UIColor) {
        UIView.animate(withDuration: 1.0) {
            self.draw(frame: frame, label: label, w3w: w3w, color: color)
        }
    }
    
    func hide() {
        //self.shapeLayer.isHidden = true
        // fade animation
        self.w3wRectLayer.removeAllAnimations()
        self.w3wLayer.removeAllAnimations()
        self.textLayer.removeAllAnimations()
        self.textLayer.isHidden = true
        self.w3wLayer.isHidden = true
        self.w3wRectLayer.isHidden = true
        self.w3wText = ""
    }
}
