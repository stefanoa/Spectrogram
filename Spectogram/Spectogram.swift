//
//  Spectogram.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 22/07/17.
//  Copyright © 2017 SA. All rights reserved.
//

import Foundation
import Accelerate

class Spectogram {
    static let noteSeparation:Float = 1.059463
    
    let sliceSize:Int
    let log2n:UInt
    let fftSetup:FFTSetup
    
    
    var window :[Float]
    var magnitudes :[Float]
    var realp:[Float]
    var imagp:[Float]
    var windowed:[Float]
    var outputSlice:DSPSplitComplex
    
    init(sliceSize:Int){
        self.sliceSize = sliceSize
        log2n = UInt(round(log2(Double(sliceSize))))
        window = [Float](repeating: 0, count: sliceSize)
        windowed = [Float](repeating: 0, count: sliceSize)
        magnitudes = [Float](repeating: 0, count: sliceSize/2)

        realp = [Float](repeating: 0, count: sliceSize/2)
        imagp = [Float](repeating: 0, count: sliceSize/2)
        outputSlice = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
        vDSP_hann_window(&window, vDSP_Length(sliceSize), Int32(vDSP_HANN_NORM))
    }
    /*
     let sampleRate:Int = 11000
     let sliceSize:Int = 1024
     let slicingWindow:Int = 1024/2
     */
    func processSound(samples:[Float],sliceSize:Int, slicingWindow:Int)-> [[Float]]{
        var slices:[[Float]] = []
        var slice:[Float] = []
        for index in 0...samples.count-1{
            let k = index%slicingWindow
            if k == 0 && slice.count >= sliceSize{
                let sliceRes = processSlice(samples: slice)
                slices.append(sliceRes)
            }
            if slice.count > sliceSize{
                slice.remove(at: 0)
            }
            slice.append(samples[index])
        }
        return slices
    }
    
    func processSlice(samples:[Float]) -> [Float]{
        let size = UInt32(sliceSize)
        let csize = size/2
        
       
        //vDSP_vmul(samples, 1, &window, 1, &windowed, 1, vDSP_Length(size))
        let p = UnsafePointer<Float>(samples)
        p.withMemoryRebound(to: DSPComplex.self, capacity: samples.count) { (typeConvertedTransferBuffer) -> Void in
            vDSP_ctoz(typeConvertedTransferBuffer, 2, &outputSlice, 1, vDSP_Length(csize))
        }

        vDSP_fft_zrip(self.fftSetup, &outputSlice, 1, log2n, FFTDirection(FFT_FORWARD))
        vDSP_zvmags(&outputSlice, 1, &magnitudes, 1, vDSP_Length(Int(csize)))
        
        var nm = [Float](repeating: 0.0, count: Int(csize))
        for i in 0...Int(csize-1) {
            nm[i] = sqrt(magnitudes[i])/Float(csize)
        }
        
        return nm
    }
    
    private func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }
}
