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
    let cutOff = 0
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let width = pixelPerSlice
        let yStart = yAtIndex(index: cutOff)
        for index in 0...dataSource.numberOfSlices()-1{
            let slice = dataSource.sliceAtIndex(index)
            var y0:CGFloat = yStart
            for j in cutOff...slice.count-1{
                let v = slice[j]
                let y = yAtIndex(index: j)
                let rect = CGRect(x: CGFloat(index)*width, y:y0-yStart, width: width, height: y-y0)
                let color = UIColor(red: 1-CGFloat(v),green:CGFloat(v),blue:0.0, alpha: 1.0)
                color.setFill()
                ctx.fill(rect)
                y0 = y
            }
        }
        /*
        UIColor.white.setStroke()
        ctx.setLineWidth(0.5)
        let slice = dataSource.sliceAtIndex(0)
        let size = getSize()
        for j in cutOff...slice.count-1{
            let y = yAtIndex(index: j)-yStart
            let line = UIBezierPath()
            line.move(to: CGPoint(x: 0, y: y))
            line.addLine(to: CGPoint(x: size.width, y: y))
            line.stroke()
        }*/
    }
    
    func getSize()-> CGSize{
        let n = dataSource.numberOfSlices()
        return CGSize(width:pixelPerSlice*CGFloat(n), height: yAtIndex(index: n-1))
    }
    
    func yAtIndex(index:Int)->CGFloat{
        let indexF = CGFloat(index)
        return round((log(indexF+1)/log(CGFloat(Spectogram.noteSeparation)))*pixelDeltaNote)
    }
    
    func reloadData(){
        let size:CGSize = getSize()
        self.frame.size = size
        self.setNeedsDisplay()
    }
}