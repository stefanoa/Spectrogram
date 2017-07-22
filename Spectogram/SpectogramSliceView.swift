//
//  SpectogramSliceView.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 16/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

class SpectogramSliceView: UIView {
    var slice:[Float]?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        if let slice = slice {
            let width = self.frame.size.width
            let height = self.frame.size.height
            let deltaY = height/CGFloat(slice.count)
            var max:Float = 0;
            var maxIndex:Int = 0;
            UIColor.clear.setStroke()
            ctx.setLineWidth(0)
            for i in 0...slice.count-1{
                let v = slice[i]
                var r = log10(v/0.1)
                if( r > max ){
                    max = r
                    maxIndex = i
                }
                r = r < 0.1 ? 0:r
                let y = CGFloat(i)*deltaY
                let rect = CGRect(x: 0, y:y, width: width, height: deltaY)
                let color = UIColor(white: 1-CGFloat(r), alpha: 1.0)
                color.setFill()
                ctx.fill(rect)
                
                
            }
            print("max:\(max),\(maxIndex)")
        }
    }

}
