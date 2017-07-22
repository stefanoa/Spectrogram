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
    var spectrogramView:SpectogramView!
    var spectrogram:Spectogram!;
    var queue:DispatchQueue = DispatchQueue(label: "sampleproduction")
    var state:ProductionState = .idle
    let rate:Int = 4096*2
    let numberOfNotes = 48
    let factor:Float = 1.059463
    let sliceSize:Int = 1024
    
    func tap(){
        if state == .idle {
            state = .started
            
            queue.async {
                var hz:Float = 130.81*2
                let factor = self.factor
                let rate = self.rate
                let nOn = self.numberOfNotes
                let sliceSize = self.sliceSize
                let duration = 3*sliceSize
                var samples:[Float] = [Float](repeating: 0, count: sliceSize)
                var isFirst = true
                for note in 0...nOn-1{
                    for i in 0...duration-1{
                        let index = (i+note*duration)
                        let x:Float = Float(index)/Float(rate)
                        let k = (i+note*duration)%sliceSize
      
                        if k == 0 && !isFirst{
                            print("---\(hz)----")
                            let sliceRes = self.spectrogram.processSamples(samples: samples)
                            self.spectrogramView.addSlice(slice: sliceRes)
                        }
                        samples[k] = sin(2 * .pi*x*hz)
                        isFirst = false
                    }
                    hz *= factor
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView(frame: view.bounds)
        spectrogramView = SpectogramView(frame:scrollView.bounds)
        self.scrollView.contentSize = self.spectrogramView.frame.size
        
        scrollView.addSubview(spectrogramView)
        self.view.addSubview(scrollView)
        
        spectrogram = Spectogram(sliceSize: sliceSize)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapRecognizer)
    }

   
}
