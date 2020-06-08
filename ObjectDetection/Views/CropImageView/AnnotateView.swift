//
//  AnnotateView.swift
//  test4
//
//  Created by Lshiva on 03/06/2020.
//  Copyright © 2020 what3words. All rights reserved.
//

import UIKit

enum Labels : String {
    case w3w = "what3words", w3wlogo = "what3wordslogo", other = "other"
    
    static let allLabels = [w3w, w3wlogo, other]
}

struct BoundingBox {
    var name : Labels
    var box : CGRect
}

func rectFromStartAndEnd(_ startPoint:CGPoint, endPoint: CGPoint) -> CGRect
{
  var  top, left, bottom, right: CGFloat;
  top = min(startPoint.y, endPoint.y)
  bottom = max(startPoint.y, endPoint.y)
  
  left = min(startPoint.x, endPoint.x)
  right = max(startPoint.x, endPoint.x)
  
  let result = CGRect(x: left, y: top, width: right-left, height: bottom-top)
  return result
}


@objc protocol AnnotationViewDelegateProtocol
{
  func haveValidCropRect(_: Bool)
}


class AnnotateView: UIView, CornerpointClientProtocol {


    // TODO: this code must present in the super view and call via delegate
    // To make sure it works independently
    var imageProcess  = ImageProcess()

    var label : Labels = .w3w
    
    var colors: [String: UIColor] = [:]
    
    // MARK: - properties -
    var  imageToCrop: UIImage? {
        didSet
        {
            imageSize = imageToCrop?.size
            setNeedsLayout()
        }
    }

    let viewForImage: UIView
    var imageSize: CGSize?
    var imageRect: CGRect?
    var aspect: CGFloat
    var draggingRect: Bool = false
    var boundingBoxView = UIView()
    var cornerpoints =  [CornerDragView]()
    
    @IBOutlet var  cropDelegate: AnnotationViewDelegateProtocol?
    let dragger: UIPanGestureRecognizer
  
    var startPoint: CGPoint?
    public var internalCropRect: BoundingBox?
    public var allBoundingBoxRect = [BoundingBox]()
    var selectedBoundingBoxRect: BoundingBox?
    {
        set
        {
            if let realCropRect = newValue
            {
                let newRect:CGRect =  realCropRect.box.intersection(imageRect!)
                internalCropRect = BoundingBox(name: label, box: newRect)
                cornerpoints[0].centerPoint = newRect.origin
                cornerpoints[1].centerPoint = CGPoint(x: newRect.maxX, y: newRect.origin.y)
                cornerpoints[3].centerPoint = CGPoint(x: newRect.origin.x, y: newRect.maxY)
                cornerpoints[2].centerPoint = CGPoint(x: newRect.maxX,y: newRect.maxY)
            } else {
                internalCropRect = nil
                for aCornerpoint in cornerpoints
                {
                    aCornerpoint.centerPoint = nil;
                }
            }
            if let cropDelegate = cropDelegate
            {
                let rectIsTooSmall: Bool = internalCropRect?.box == nil ||
                internalCropRect!.box.size.width < 5 ||
                internalCropRect!.box.size.height < 5
                cropDelegate.haveValidCropRect(internalCropRect?.box != nil && !rectIsTooSmall)
            }
      
        setNeedsDisplay()
        }
        get
        {
            return internalCropRect
        }
    }
  //-------------------------------------------------------------------------------------------------------
  // MARK: - Designated initializer(s)
  //-------------------------------------------------------------------------------------------------------
      override init(frame: CGRect) {
        
        for label in Labels.allLabels {
            colors[label.rawValue] = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        }
        
        for _ in 1...4
        {
            let aCornerpointView = CornerDragView()
            print(aCornerpointView)
            cornerpoints.append(aCornerpointView)
        }

        viewForImage = UIView(frame: CGRect.zero)
        viewForImage.translatesAutoresizingMaskIntoConstraints = false
        aspect = 1
    
        dragger = UIPanGestureRecognizer()
        super.init(frame: frame)
        addSubview(boundingBoxView)
        boundingBoxView.frame = CGRect.zero
        dragger.addTarget(self as AnyObject, action: #selector(handleDragInView(_:)))
        viewForImage.frame = frame
        addGestureRecognizer(dragger)

        let tapper = UITapGestureRecognizer(target: self as AnyObject, action: #selector(handleViewTap(_:)));
        addGestureRecognizer(tapper)

        for aCornerpoint in cornerpoints
        {
            tapper.require(toFail: aCornerpoint.dragger)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        
        for label in Labels.allLabels {
            colors[label.rawValue] = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        }
        
        for _ in 1...4
        {
            let aCornerpointView = CornerDragView()
            print(aCornerpointView)
            cornerpoints.append(aCornerpointView)
        }

        viewForImage = UIView(frame: CGRect.zero)
        viewForImage.translatesAutoresizingMaskIntoConstraints = false
        aspect = 1
    
        dragger = UIPanGestureRecognizer()
        super.init(coder: aDecoder)

        addSubview(boundingBoxView)
        boundingBoxView.frame = CGRect.zero
        dragger.addTarget(self as AnyObject, action: #selector(handleDragInView(_:)))
        viewForImage.frame = frame
        addGestureRecognizer(dragger)

        let tapper = UITapGestureRecognizer(target: self as AnyObject, action: #selector(handleViewTap(_:)));
        addGestureRecognizer(tapper)

        for aCornerpoint in cornerpoints
        {
            tapper.require(toFail: aCornerpoint.dragger)
        }
    }
  
//---------------------------------------------------------------------------------------------------------
// MARK: - UIView methods
//---------------------------------------------------------------------------------------------------------

    override func awakeFromNib() {
    
        super.awakeFromNib()
    
        superview?.insertSubview(viewForImage, belowSubview: self)

        for aCornerpoint in cornerpoints
        {
            addSubview(aCornerpoint)
            aCornerpoint.cornerpointDelegate = self;
        }

        selectedBoundingBoxRect = nil;
    
    }
  
  override func layoutSubviews()
  {
        super.layoutSubviews()
        selectedBoundingBoxRect = nil;
    
        //If we have an image...
        if let requiredImageSize = imageSize {
            var displaySize: CGSize = CGSize.zero
            displaySize.width = min(requiredImageSize.width, bounds.size.width)
            displaySize.height = min(requiredImageSize.height, bounds.size.height)
            let heightAsepct: CGFloat = displaySize.height/requiredImageSize.height
            let widthAsepct: CGFloat = displaySize.width/requiredImageSize.width
            aspect = min(heightAsepct, widthAsepct)
            displaySize.height = round(requiredImageSize.height * aspect)
            displaySize.width = round(requiredImageSize.width * aspect)
      
            imageRect = CGRect(x: 0, y: 0, width: displaySize.width, height: displaySize.height)
        }
    
        if imageToCrop != nil
        {
            //Drawing the image every time in drawRect is too slow. Instead, create a
            //snapshot of the image and install it as the content of the viewForImage's layer
            UIGraphicsBeginImageContextWithOptions(viewForImage.layer.bounds.size, true, 1)
      
            let path = UIBezierPath.init(rect: viewForImage.bounds)
            UIColor.white.setFill()
            path.fill()

            imageToCrop?.draw(in: imageRect!)
            let result = UIGraphicsGetImageFromCurrentImageContext()
      
            UIGraphicsEndImageContext();
      
            let theImageRef = result!.cgImage
            viewForImage.layer.contents = theImageRef as AnyObject
            
        }
    }
  
//---------------------------------------------------------------------------------------------------------
  
    override func draw(_ rect: CGRect) {
        if let realCropRect = internalCropRect?.box {
            self.drawRectangle(realCropRect)
        }
        
        for rect in allBoundingBoxRect {
            // draw all rect in the screen
            self.drawRectangle(rect.box)
        }
    }

    func drawRectangle(_ rect: CGRect) {
        let path = UIBezierPath(rect: rect)
        path.lineWidth = 1.0
        let color = colors[label.rawValue]?.withAlphaComponent(0.3) ?? UIColor.blue.withAlphaComponent(0.3)
        color.setFill()
        path.fill()
        path.stroke()
    
    }
    
  //-------------------------------------------------------------------------------------------------------
    @objc func handleDragInView(_ thePanner: UIPanGestureRecognizer) {
    
    let newPoint = thePanner.location(in: self)
    
    switch thePanner.state {
    
    case UIGestureRecognizerState.began:
        //if we have a crop rect and the touch is inside it, drag the entire rect.
        if let requiredCropRect = internalCropRect?.box {
            if requiredCropRect.contains(newPoint) {
                startPoint = requiredCropRect.origin
                draggingRect = true;
                thePanner.setTranslation(CGPoint.zero, in: self)
            }
        }
      
        if !draggingRect {
            startPoint = newPoint
            draggingRect = false;
        }
        if let selectRect = selectedBoundingBoxRect?.box {
            if (selectedBoundingBoxRect?.box.contains(newPoint))! {
                print("Drag")
            } else {
                if !draggingRect {
                    allBoundingBoxRect.append(BoundingBox(name: label, box: selectRect))
                }
            }
        }
    case UIGestureRecognizerState.changed:
        //If the user is dragging the entire rect, don't let it be draggged out-of-bounds
        if draggingRect {
            var newX = max(startPoint!.x + thePanner.translation(in: self).x,0)
            if newX + internalCropRect!.box.size.width > imageRect!.size.width  {
                newX = imageRect!.size.width - internalCropRect!.box.size.width
            }
            
            var newY = max(startPoint!.y + thePanner.translation(in: self).y,0)
            if newY + internalCropRect!.box.size.height > imageRect!.size.height {
                newY = imageRect!.size.height - internalCropRect!.box.size.height
            }
            selectedBoundingBoxRect!.box.origin = CGPoint(x: newX, y: newY)

            } else {
            //The user is creating a new rect, so just create it from
            //start and end points
            selectedBoundingBoxRect =  BoundingBox(name: label, box: rectFromStartAndEnd(startPoint!, endPoint: newPoint))
        }
    case .ended:
        draggingRect = false;
    default:
      draggingRect = false;
      break
    }
  }


    //The user tapped outside of the crop rect. Cancel the current crop rect.
    @objc func handleViewTap(_ theTapper: UITapGestureRecognizer) {
        let currentTap = theTapper.location(in: self)
        updateAllRects(currentTap)
    }
  
    func cornerHasChanged(_ newCornerPoint: CornerDragView) {
        var pointIndex: Int?
        //Find the cornerpoint the user dragged in the array.
        for (index, aCornerpoint) in cornerpoints.enumerated()
        {
            if newCornerPoint == aCornerpoint
            {
                pointIndex = index
                break
            }
        }
        if (pointIndex == nil)
        {
            return;
        }

        //Find the index of the opposite corner.
        let otherIndex:Int = (pointIndex! + 2) % 4
        
        //Calculate a new cropRect using those 2 corners
        selectedBoundingBoxRect = BoundingBox(name: label, box: rectFromStartAndEnd(newCornerPoint.centerPoint!, endPoint: cornerpoints[otherIndex].centerPoint!))
    }
    
    func updateAllRects(_ point: CGPoint) {
        for rect in allBoundingBoxRect {
            if rect.box.contains(point) {
                allBoundingBoxRect.removeAll { (removeRect) -> Bool in
                    removeRect.box == rect.box
                }
                if let selectedRect = selectedBoundingBoxRect?.box {
                    allBoundingBoxRect.append(BoundingBox(name: label, box: selectedRect))
                    selectedBoundingBoxRect?.box = rect.box
                } else {
                    selectedBoundingBoxRect?.box = rect.box
                }
            }
        }
    }
        
   @objc func deleteBoundingBoxRect() {
        label = .w3w
        selectedBoundingBoxRect = nil
    }
}
