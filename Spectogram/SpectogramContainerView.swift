//
//  SpectogramContainerView.swift
//  Spectogram
//
//  Created by Stefano on 30/07/2017.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

protocol SpectogramDataSource {
    func numberOfSlices() -> Int;
    func sliceAtIndex(_ index:Int)->[Float];
}

class SpectogramContainerView:UIView{
    var dataSource:SpectogramDataSource!
    var pixelPerSlice:CGFloat = 2
    var pixelDeltaNote:CGFloat = 10
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let width = pixelPerSlice
        for index in 0...dataSource.numberOfSlices()-1{
            let slice = dataSource.sliceAtIndex(index)
            var y0:CGFloat = 0
            for j in 0...slice.count-1{
                let v = slice[j]
                let y = yAtIndex(index: j)
                let rect = CGRect(x: CGFloat(index)*width, y:y, width: width, height: y-y0)
                let color = UIColor(white: 1-CGFloat(v), alpha: 1.0)
                color.setFill()
                ctx.fill(rect)
                y0 = y
            }
        }
        /*
        UIColor.red.setStroke()
        ctx.setLineWidth(1.0)
        let line = UIBezierPath()
        let size = getSize()
        let n = Int(size.height/10)
        for i in 1...n-1{
            line.move(to: CGPoint(x: 0, y: CGFloat(i)*pixelDeltaNote))
            line.addLine(to: CGPoint(x: size.width, y: CGFloat(i)*pixelDeltaNote))
            line.stroke()
        }*/
    }
    
    func getSize()-> CGSize{
        let n = dataSource.numberOfSlices()
        return CGSize(width:pixelPerSlice*CGFloat(n), height: yAtIndex(index: n-1))
    }
    
    func yAtIndex(index:Int)->CGFloat{
        let indexF = CGFloat(index)
        return (log(indexF+1)/log(CGFloat(Spectogram.noteSeparation)))*pixelDeltaNote
    }
    
    func reloadData(){
        let size:CGSize = getSize()
        self.frame.size = size
        self.setNeedsDisplay()
    }
}
