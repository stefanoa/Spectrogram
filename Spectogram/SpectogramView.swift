//
//  SpectogramView.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 16/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

class SpectogramView: UIScrollView,SpectogramDataSource {
    var containerView:SpectogramContainerView!
    var pixelPerSlice:CGFloat = 2
    var slicesViews:[UIView] = []
    var slices:[[Float]] = []
    
    func prepare(){
        let containerFrame = CGRect(x:0,y:0,width:self.frame.size.width,height:self.frame.size.height)
        containerView = SpectogramContainerView(frame: containerFrame)
        containerView.backgroundColor = UIColor.white
        self.addSubview(containerView)
        containerView.dataSource = self
        self.contentSize = containerView.getSize()
    }
    
    func addSlice(slice:[Float]){
        slices.insert(slice, at: 0)
        self.contentSize = containerView.getSize()
        containerView.reloadData()
    }
    
    func numberOfSlices() -> Int {
        return slices.count
    }
    
    func sliceAtIndex(_ index: Int) -> [Float] {
        return slices[index]
    }
}
