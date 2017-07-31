//
//  SynteticViewController.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 22/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

enum ProductionState{
    case started
    case idle
}

class SynteticViewController: UIViewController {
    //@IBOutlet weak var fftView: FFTView!
    var scrollView:UIScrollView!
    @IBOutlet weak var spectrogramView:SpectogramView!
    var spectrogram:Spectogram!;
    var queue:DispatchQueue = DispatchQueue(label: "sampleproduction")
    var state:ProductionState = .idle
    let numberOfNotes = 88
    let sampleRate:Int = 11000
    let sliceSize:Int = 1024
    let slicingWindow:Int = 1024
    
    func synth(){
        if state == .idle {
            state = .started
            
            var hz:Float = 27.5000
            let rate = self.sampleRate
            let nOn = self.numberOfNotes
            let duration = sliceSize
            var samples:[Float] = []
            for note in 0...nOn-1{
                for i in 0...duration-1{
                    let index = (i+note*duration)
                    let x:Float = Float(index)/Float(rate)
                    samples.append(sin(2*Float.pi*x*hz))
                }
                hz *= Spectogram.noteSeparation
            }
            
            let slices = spectrogram.processSound(samples: samples, sliceSize: sliceSize, slicingWindow: slicingWindow)
            for slice in slices{
                spectrogramView.addSlice(slice: slice)
            }
        }
    }
    
    @objc func tap(){
        spectrogramView.setNeedsDisplay()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        spectrogram = Spectogram(sliceSize: sliceSize)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        spectrogramView.prepare()
        synth()
    }
   
}
