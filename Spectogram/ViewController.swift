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
    @IBOutlet weak var spectogramView: SpectogramView!

    let audioEngine  = AVAudioEngine()
    var inputNode:AVAudioNode?
    
    var state:SpectogramState = .idle
    let sliceSize:Int = 512
    let downSample:Int = 4
    var inputSlice:[Float]=[]

    var window :[Float]=[]
    var fftSetup:FFTSetup!
    
    func tap(){
        if state == .idle {
            try! audioEngine.start()
            state = .started
        }else if state == .started {
            audioEngine.stop()
            state = .idle
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputNode = audioEngine.inputNode
        let bus = 0
        //var realp = [Float](repeating: 0, count: sliceSize/2)
        //var imagp = [Float](repeating: 0, count: sliceSize/2)
        inputSlice = [Float](repeating: 0, count: sliceSize)
        window = [Float](repeating: 0, count: sliceSize)
        vDSP_hann_window(&window, vDSP_Length(sliceSize), Int32(vDSP_HANN_NORM))
        
        let log2n = UInt(round(log2(Double(sliceSize))))
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))

        var lastDate = Date()
        
        inputNode?.installTap(onBus: bus, bufferSize: UInt32(sliceSize), format: inputNode?.inputFormat(forBus: bus)) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            //print("time:\(time.audioTimeStamp.mSampleTime)")
            //print("rate:\(time.audioTimeStamp.mRateScalar)")
            let size = UInt32(self.sliceSize)
            let csize = size/2

            var realp = [Float](repeating: 0, count: Int(csize))
            var imagp = [Float](repeating: 0, count: Int(csize))
            var outputSlice = DSPSplitComplex(realp: &realp, imagp: &imagp)
            let ds = UInt32(self.downSample)
            
            if let floatChannelData = buffer.floatChannelData{
                let sliceCount = buffer.frameLength/(size*ds)
                for i in 0...sliceCount-1{
                    for j in 0...size-1{
                        var c0:Float = 0
                        var c1:Float = 0
                        for k in 0...ds-1{
                            let index = Int(i*size*ds + j*ds + k)
                            
                            c0 += floatChannelData[0][index]
                            c1 += floatChannelData[1][index]
                            
                        }
                        self.inputSlice[Int(j)] = ((c0+c1)/Float(2*ds))
                    }
                    var transfer = [Float](repeating: 0, count: Int(size))
                    vDSP_vmul(&(self.inputSlice), 1, &self.window, 1, &transfer, 1, vDSP_Length(size))
                    let temp = UnsafePointer<Float>(transfer)
                    temp.withMemoryRebound(to: DSPComplex.self, capacity: transfer.count) { (typeConvertedTransferBuffer) -> Void in
                        vDSP_ctoz(typeConvertedTransferBuffer, 2, &outputSlice, 1, vDSP_Length(csize))
                    }
                    vDSP_fft_zrip(self.fftSetup, &outputSlice, 1, log2n, FFTDirection(FFT_FORWARD))
                    
                    var magnitudes = [Float](repeating: 0.0, count: Int(csize))
                    vDSP_zvmags(&outputSlice, 1, &magnitudes, 1, vDSP_Length(Int(csize)))
                    
                    var normalizedMagnitudes = [Float](repeating: 0.0, count: Int(csize))
                    vDSP_vsmul(self.sqrtq(magnitudes), 1, [2.0 / Float(Int(csize))], &normalizedMagnitudes, 1, vDSP_Length(Int(csize)))
                    self.spectogramView.addSlice(slice: normalizedMagnitudes)
                }
                
            }
            
            let date = Date()
            //print("sliceDuration:\(date.timeIntervalSince(lastDate))")
            lastDate = date
            
        }
        
        audioEngine.prepare()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }

}

