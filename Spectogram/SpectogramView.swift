//
//  SpectogramView.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 16/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

class SpectogramView: UIView {
    var pixelPerSlice:CGFloat = 2
    var slicesViews:[UIView] = []

    func addSlice(slice:[Float]){
        
        //DispatchQueue.main.async {
            let s = self
            
            let newFrame = CGRect(x:0, y:0, width:s.pixelPerSlice, height:s.frame.size.height)
            let newSliceView = SpectogramSliceView(frame: newFrame)
            newSliceView.slice = slice
            
            for sliceView in s.slicesViews {
                let sliceFrame = sliceView.frame.offsetBy(dx: s.pixelPerSlice, dy: 0)
                sliceView.frame = sliceFrame
                //if !(frame?.contains(sliceView.frame))!{
                //    sliceView.removeFromSuperview()
                //}
            }
            s.slicesViews.append(newSliceView)
            s.addSubview(newSliceView)
            if CGFloat(s.slicesViews.count)*s.pixelPerSlice > s.frame.size.width {
                let width = CGFloat(s.slicesViews.count)*s.pixelPerSlice
                s.frame = CGRect(x: s.frame.origin.x, y: s.frame.origin.y, width: width, height: s.frame.size.height)
            }
            
            //s.setNeedsDisplay()
        //}
    }
    
}
