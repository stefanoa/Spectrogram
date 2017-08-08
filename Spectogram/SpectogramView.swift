//
//  SpectogramView.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 16/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

class SpectogramView: UIScrollView, SpectogramDataSource, SpectogramDelegate, FFTDelegate {
    var containerView:SpectogramContainerView!
    var pixelPerSlice:CGFloat = 2
    var slicesViews:[UIView] = []
    var slices:[[Float]] = []
    var rate:Float = 41100
    var currentFFTview:FFTView?
    
    func prepare(){
        let containerFrame = CGRect(x:0,y:0,width:self.frame.size.width,height:self.frame.size.height)
        containerView = SpectogramContainerView(frame: containerFrame)
        containerView.backgroundColor = UIColor.white
        containerView.rate = self.rate
        self.addSubview(containerView)
        containerView.dataSource = self
        containerView.delegate = self
        self.contentSize = containerView.getSize()
    }
    
    func addSlice(slice:[Float]){
        slices.insert(slice, at: 0)
        self.contentSize = containerView.getSize()
        containerView.reloadData()
    }
    
    func clearSlices(){
        slices.removeAll()
        self.contentSize = containerView.getSize()
        containerView.reloadData()
    }
    
    func numberOfSlices() -> Int {
        return slices.count
    }
    
    func sliceAtIndex(_ index: Int) -> [Float] {
        return slices[index]
    }
    
    func selectedSliceAtIndex(_ index: Int, slice: [Float]) {
        if let currentFFTView = self.currentFFTview {
            currentFFTView.removeFromSuperview()
        }
        let width = self.frame.size.width
        let height = containerView.getSize().height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let currentFFTview  = FFTView(frame:frame)
        currentFFTview.slice = slice
        currentFFTview.delegate = self
        containerView.addSubview(currentFFTview)
        self.currentFFTview = currentFFTview
        print("selected slice at:\(index)")
    }
    
    func didTap() {
        if let currentFFTview = currentFFTview{
            currentFFTview.removeFromSuperview()
            self.currentFFTview = nil
        }
    }
}
