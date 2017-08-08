//
//  FFTView.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 16/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

protocol FFTDelegate {
    func didTap()
}
class FFTView: UIView {
    var slice:[Float]!
    var pixelDeltaNote:CGFloat = 10
    var delegate:FFTDelegate?
    
    func tap(recognizer:UITapGestureRecognizer){
        if let delegate = delegate {
            delegate.didTap()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let recogniser = UITapGestureRecognizer(target: self, action: #selector(tap(recognizer:)))
        self.addGestureRecognizer(recogniser)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let recogniser = UITapGestureRecognizer(target: self, action: #selector(tap(recognizer:)))
        self.addGestureRecognizer(recogniser)
        self.backgroundColor = UIColor.clear
    }
    
    
    override func draw(_ rect: CGRect) {
        let viewWidth = self.frame.size.width
        let scaleX = viewWidth
        var points1:[CGPoint] = [CGPoint]()
        var points2:[CGPoint] = [CGPoint]()
        var points3:[CGPoint] = [CGPoint]()
        
        for  i in 0...slice.count-1 {
            let y = yAtIndex(index: i)
            let point1 = CGPoint(x: CGFloat(slice[i])*scaleX, y:y)
            let point2 = CGPoint(x: CGFloat(log(slice[i]/0.1))*scaleX, y:y)
            let point3 = CGPoint(x: CGFloat(log2(slice[i]/0.1))*scaleX, y:y)
            points1.append(point1)
            points2.append(point2)
            points3.append(point3)
            
        }
        let path1 = UIBezierPath()
        let path2 = UIBezierPath()
        let path3 = UIBezierPath()
        path1.move(to: points1[0])
        path2.move(to: points2[0])
        path3.move(to: points3[0])
        for i in 1...points1.count-1 {
            let p1 = points1[i]
            let p2 = points2[i]
            let p3 = points3[i]
            print("\(i),\(p1.y),\(slice[i])")
            path1.addLine(to: p1)
            path2.addLine(to: p2)
            path3.addLine(to: p3)
        }
        
        UIColor.red.set()
        path1.stroke()
        UIColor.blue.set()
        path2.stroke()
        UIColor.green.set()
        path3.stroke()
        
        
    }
    
    func yAtIndex(index:Int)->CGFloat{
        let indexF = CGFloat(index)
        return round((log(indexF+1)/log(CGFloat(Spectogram.noteSeparation)))*pixelDeltaNote)
    }
}
