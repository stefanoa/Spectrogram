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
    var frequency:CGFloat = 44100
    var sliceSize:CGFloat = 512
    var deltaFrequency:CGFloat = 44100/512
    var pixelDeltaNote:CGFloat = 5
    
    init(frame: CGRect, frequency:Float, sliceSize:Int) {
        super.init(frame:frame)
        self.frequency = CGFloat(frequency)
        self.sliceSize = CGFloat(sliceSize)
        self.deltaFrequency = CGFloat(frequency/Float(sliceSize))
        self.backgroundColor = UIColor.white
    }
    
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
            //let height = self.frame.size.height
            let deltaY = pixelDeltaNote
            
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
                let y = (log(CGFloat(i+1))/log(CGFloat(Spectogram.noteSeparation)))*pixelDeltaNote
                let rect = CGRect(x: 0, y:y, width: width, height: pixelDeltaNote)
                let color = UIColor(white: 1-CGFloat(r), alpha: 1.0)
                color.setFill()
                ctx.fill(rect)
            }
            print("max:\(max),\(maxIndex)")
        }
    }

}
