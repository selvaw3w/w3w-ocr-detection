//
//  BoundingBoxView.swift
//  test4
//
//  Created by Lshiva on 03/06/2020.
//  Copyright © 2020 what3words. All rights reserved.
//

import UIKit

@objc protocol CornerpointClientProtocol
{
  func cornerHasChanged(_: CornerDragView)
}

class CornerDragView: UIView {
    var drawCornerOutlines = false
    var dragger: UIPanGestureRecognizer!
    var dragStart: CGPoint!
    var cornerpointDelegate: CornerpointClientProtocol?
    
    var centerPoint : CGPoint?
    {
        didSet(oldPoint) {
            if let newCenter = centerPoint {
                 isHidden = false
                 center = newCenter
            } else {
                isHidden = true
            }
        }
    }
    
    init()
    {
        super.init(frame:CGRect.zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        dragger = UIPanGestureRecognizer(target: self, action: #selector(handleCornerDrag(_:)))
        addGestureRecognizer(dragger)
        
        //Make the corner point view big enough to drag with a finger.
        bounds.size = CGSize(width: 30, height: 30)
        
        //Add a layer to the view to draw an outline for this corner point.
        let newLayer = CALayer()
        newLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        newLayer.bounds.size = CGSize(width: 7, height: 7)
        newLayer.borderWidth = 1.0
        newLayer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        newLayer.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor

        if drawCornerOutlines
        {
          //Create a faint white 3-point thick rectangle for the draggable area
          var shapeLayer = CAShapeLayer()
          shapeLayer.frame = layer.bounds
          shapeLayer.path = UIBezierPath(rect: layer.bounds).cgPath
          shapeLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
          shapeLayer.lineWidth = 3.0;
          shapeLayer.fillColor = UIColor.clear.cgColor
          layer.addSublayer(shapeLayer)
          
          //Create a faint black 1 pixel rectangle to go on top  white rectangle
          shapeLayer = CAShapeLayer()
          shapeLayer.frame = layer.bounds
          shapeLayer.path = UIBezierPath(rect: layer.bounds).cgPath
          shapeLayer.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
          shapeLayer.lineWidth = 1;
          shapeLayer.fillColor = UIColor.clear.cgColor
          layer.addSublayer(shapeLayer)
          
        }
        layer.addSublayer(newLayer)
        
    }
    
    @objc func handleCornerDrag(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                dragStart = centerPoint
                sender.setTranslation(CGPoint.zero,in: self)
                
            case .changed:
                centerPoint = CGPoint(x: dragStart.x + sender.translation(in: self).x, y: dragStart.y + sender.translation(in: self).y)
                if let theDelegate = cornerpointDelegate
                {
                    theDelegate.cornerHasChanged(self)
                }
            default:
            break;
        }
    }
}
