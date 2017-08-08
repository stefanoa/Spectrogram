//
//  SpectogramContainerView.swift
//  Spectogram
//
//  Created by Stefano on 30/07/2017.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

protocol SpectogramDataSource {
    func numberOfSlices() -> Int
    func sliceAtIndex(_ index:Int)->[Float]
}
protocol SpectogramDelegate {
    func selectedSliceAtIndex(_ index:Int, slice:[Float])
}
class SpectogramContainerView:UIView{
    var dataSource:SpectogramDataSource!
    var delegate:SpectogramDelegate?
    var pixelPerSlice:CGFloat = 4
    var pixelDeltaNote:CGFloat = 10
    let cutOff = 0
    var rate:Float = 41100
    var longPressRecognizer:UILongPressGestureRecognizer!
    
    func longPressed(recognizer:UILongPressGestureRecognizer){
        if let delegate = delegate , recognizer.state == .began{
            let position = recognizer.location(in: recognizer.view)
            let index = Int(position.x/pixelPerSlice)
            if index < dataSource.numberOfSlices(){
                let slice = dataSource.sliceAtIndex(index)
                delegate.selectedSliceAtIndex(index, slice: slice)
            }
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    
    override func draw(_ rect: CGRect) {
        if dataSource.numberOfSlices()>0 {
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
                    //let color = UIColor(red: 1-CGFloat(v),green:CGFloat(v),blue:0.0, alpha: 1.0)
                    let color = UIColor(white: 1-CGFloat(v), alpha: 1.0)
                    
                    color.setFill()
                    ctx.fill(rect)
                    y0 = y
                }
            }
            
            /*
             let slice = dataSource.sliceAtIndex(0)
             let sliceSize = Float(slice.count)
             var ci:Float = 55
             UIColor.darkGray.setStroke()
             let size = getSize()
            for _ in 1...7 {
                let kf = ci*sliceSize/rate
                let k = Int(kf)
                let y = yAtIndex(index: k)-yStart
                let line = UIBezierPath()
                line.move(to: CGPoint(x: 0, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                line.stroke()
                ci*=2
            }*/
            
        }
    }
    
    func getSize()-> CGSize{
        if dataSource.numberOfSlices() > 0{
            let slice = dataSource.sliceAtIndex(0)
            let n = slice.count
            let numberOfSlices = dataSource.numberOfSlices()
            return CGSize(width:pixelPerSlice*CGFloat(numberOfSlices), height: yAtIndex(index: n-1))
            
        }else{
            return CGSize.zero
        }
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
