//
//  CanvasView.swift
//  NewScribble
//
//  Created by Erik Loehfelm on 10/30/18.
//  Copyright © 2018 Erik Loehfelm. All rights reserved.
//

import Foundation
import UIKit


class CanvasView: UIImageView {
    
    let π = CGFloat(Double.pi)
    let forceSensitivity: CGFloat = 4.0
    let defaultLineWidth: CGFloat = 6
    private var drawingImage: UIImage?
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("no touch")
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
//        image?.draw(in: bounds)
        drawingImage?.draw(in: bounds)
        var touches = [UITouch]()
        
        // coalesced
        if let coalescedTouches = event?.coalescedTouches(for: touch) {
            touches = coalescedTouches
        } else {
            touches.append(touch)
        }
        
        for touch in touches {
            drawStroke(context: context, touch: touch, isPredictedTouch: false)
        }
        
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // predicted
        if let predictedTouches = event?.predictedTouches(for: touch) {
            for touch in predictedTouches {
                drawStroke(context: context, touch: touch, isPredictedTouch: true)
            }
        }
        
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        image = drawingImage
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        image = drawingImage
    }
    
    func drawStroke(context: CGContext?, touch: UITouch, isPredictedTouch: Bool) {
        print("drawStroke")
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        var lineWidth: CGFloat = 1.0
        
        if touch.type == .stylus {
            lineWidth = lineWidthForDrawing(context: context, touch: touch)
//            UIColor.darkGray.setStroke()
        }
        
        if isPredictedTouch {
            print("red")
            UIColor.red.setStroke()
        } else {
            print("grey")
            UIColor.darkGray.setStroke()
        }
        
        context!.setLineWidth(lineWidth)
        context!.setLineCap(.round)
        
        context?.move(to: previousLocation)
        context?.addLine(to: location)
        
        context!.strokePath()
    }
    
    func lineWidthForDrawing(context: CGContext?, touch: UITouch) -> CGFloat {
        var lineWidth = defaultLineWidth
        
        if touch.force > 0 {
            lineWidth = touch.force * forceSensitivity
        }
        
        return lineWidth
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
