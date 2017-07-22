//
//  SpectogramView.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 16/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

class SpectogramView: UIView {
    //@IBOutlet weak var container:UIView!
    var pixelPerSlice:CGFloat = 2
    var slicesViews:[UIView] = []

    func addSlice(slice:[Float]){
        
        DispatchQueue.main.async {[weak self] in
            if let s = self {
                let frame = s.frame
                for sliceView in s.slicesViews {
                    let sliceFrame = sliceView.frame.offsetBy(dx: s.pixelPerSlice, dy: 0)
                    sliceView.frame = sliceFrame
                    //if !(frame?.contains(sliceView.frame))!{
                    //    sliceView.removeFromSuperview()
                    //}
                }
                let newFrame = CGRect(x:0, y:0, width:s.pixelPerSlice, height:frame.size.height)
                let newSliceView = SpectogramSliceView(frame: newFrame)
                newSliceView.slice = slice
                s.slicesViews.append(newSliceView)
                s.addSubview(newSliceView)
                
                
                if CGFloat(s.slicesViews.count)*s.pixelPerSlice > frame.size.width {
                    let width = CGFloat(s.slicesViews.count)*s.pixelPerSlice
                    s.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: frame.size.height)
                }
                newSliceView.setNeedsDisplay()
                s.setNeedsDisplay()
            }
        }
    }
    
}
