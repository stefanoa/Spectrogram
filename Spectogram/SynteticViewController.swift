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
    let sampleRate:Int = 4096*4
    let numberOfNotes = 88
    let sliceSize:Int = 2048
    
    func synth(){
        if state == .idle {
            state = .started
            
            //queue.async {
                var hz:Float = 130.81/4
                let rate = self.sampleRate
                let nOn = self.numberOfNotes
                let sliceSize = self.sliceSize
                let duration = 10*sliceSize
                var samples:[Float] = []
                for note in 0...nOn-1{
                    for i in 0...duration-1{
                        let index = (i+note*duration)
                        let x:Float = Float(index)/Float(rate)
                        let k = (i+note*duration)%(sliceSize)
      
                        if k == 0 && samples.count >= sliceSize{
                            //print("---\(hz)----")
                            let sliceRes = self.spectrogram.processSamples(samples: samples)
                            self.spectrogramView.addSlice(slice: sliceRes)
                        }
                        samples.append(sin(2*Float.pi*x*hz))
                        if samples.count > sliceSize{
                            samples.remove(at: 0)
                        }
                    }
                    hz *= Spectogram.noteSeparation
                }
            //}
        }
    }
    
    @objc func tap(){
        synth()
        spectrogramView.setNeedsDisplay()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        spectrogram = Spectogram(sliceSize: sliceSize, frequency:44100)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        spectrogramView.prepare()
    }
   
}
