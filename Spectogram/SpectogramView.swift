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
        DispatchQueue.main.async {[weak self] in
            let frame = self?.frame
            for sliceView in (self?.slicesViews)! {
                let sliceFrame = sliceView.frame.offsetBy(dx: (self?.pixelPerSlice)!, dy: 0)
                sliceView.frame = sliceFrame
                if !(frame?.contains(sliceView.frame))!{
                    sliceView.removeFromSuperview()
                }
            }
            let newFrame = CGRect(x:0, y:0, width:(self?.pixelPerSlice)!, height:(frame?.size.height)!)
            let newSliceView = SpectogramSliceView(frame: newFrame)
            newSliceView.slice = slice
            self?.slicesViews.append(newSliceView)
        
            self?.addSubview(newSliceView)
            newSliceView.setNeedsDisplay()
            self?.setNeedsDisplay()
        }
    }
   
}
