//
//  ViewController.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 15/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit

import AVFoundation
import Accelerate

enum SpectogramState{
    case started
    case idle
}

class ViewController: UIViewController {
    //@IBOutlet weak var fftView: FFTView!
    var scrollView:UIScrollView!
    var spectrogramView:SpectogramView!
    
    let audioEngine  = AVAudioEngine()
    var inputNode:AVAudioNode?
    
    var state:SpectogramState = .idle
    var spectrogram:Spectogram!;
    var inputSlice:[Float]=[]

    func tap(){
   /*
        if state == .idle {
            try! audioEngine.start()
            state = .started
        }else if state == .started {
            audioEngine.stop()
            state = .idle
        }*/
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView(frame: view.bounds)
        spectrogramView = SpectogramView(frame:scrollView.bounds)
        self.scrollView.contentSize = self.spectrogramView.frame.size

        scrollView.addSubview(spectrogramView)
        self.view.addSubview(scrollView)
        
        inputNode = audioEngine.inputNode
        let bus = 0
        //var lastDate = Date()
        let sliceSize = 512
        let ds = 4
        spectrogram = Spectogram(sliceSize: sliceSize, downsamplingRate: ds)
        inputSlice = [Float](repeating: 0, count: sliceSize)
        inputNode?.installTap(onBus: bus, bufferSize: UInt32(sliceSize), format: inputNode?.inputFormat(forBus: bus)) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            //print("time:\(time.audioTimeStamp.mSampleTime)")
            //print("rate:\(time.audioTimeStamp.mRateScalar)")
            
            if let floatChannelData = buffer.floatChannelData{
                let sliceCount = buffer.frameLength/UInt32(sliceSize*ds)
                for i in 0...sliceCount-1{
                    for j in 0...sliceSize-1{
                        var c0:Float = 0
                        var c1:Float = 0
                        for k in 0...ds-1{
                            let index = Int(i)*sliceSize*ds + j*ds + k
                            
                            c0 += floatChannelData[0][index]
                            c1 += floatChannelData[1][index]
                            
                        }
                        self.inputSlice[Int(j)] = ((c0+c1)/Float(2*ds))
                    }
                    let normalizedMagnitudes = self.spectrogram.processSamples(samples: self.inputSlice)
                    self.spectrogramView.addSlice(slice: normalizedMagnitudes)
                    self.scrollView.contentSize = self.spectrogramView.frame.size
                }
                
            }
            
            //let date = Date()
            //print("sliceDuration:\(date.timeIntervalSince(lastDate))")
            //lastDate = date
            
        }
        
        audioEngine.prepare()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapRecognizer)
    }

}

