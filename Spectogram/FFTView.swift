//
//  FFTView.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 16/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

class FFTView: UIView {
    var fft:[Float]?

    override func draw(_ rect: CGRect) {
        if let fft = fft {
            let viewHeight = self.frame.size.height
            let viewWidth = self.frame.size.width
            let deltaX = viewHeight/CGFloat(fft.count)
            let scaleY = viewWidth
            var points:[CGPoint] = [CGPoint]()
            
            for  i in 0...fft.count-1 {
                let point = CGPoint(x: CGFloat(fft[i])*scaleY, y: CGFloat(i)*deltaX)
                points.append(point)
            }
            //points.append(CGPoint(x: 0, y: 0))
            //points.append(CGPoint(x: viewWidth, y: viewHeight))
            let path = UIBezierPath()
            path.move(to: points[0])
            for i in 1...points.count-1 {
                path.addLine(to: points[i])
            }
            
            UIColor.red.set()
            path.stroke()
            
            
        }

        
        
    }

}
