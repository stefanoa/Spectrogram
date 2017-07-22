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
    let sliceSize:Int
    let downsamplingRate:Int
    let log2n:UInt
    let fftSetup:FFTSetup

    var window :[Float]
    var magnitudes :[Float]
    var windowed:[Float]
    var outputSlice:DSPSplitComplex
    
    init(sliceSize:Int, downsamplingRate:Int){
        self.sliceSize = sliceSize
        self.downsamplingRate = downsamplingRate
        log2n = UInt(round(log2(Double(sliceSize))))
        window = [Float](repeating: 0, count: sliceSize)
        windowed = [Float](repeating: 0, count: sliceSize)
        magnitudes = [Float](repeating: 0, count: sliceSize/2)

        var realp = [Float](repeating: 0, count: sliceSize/2)
        var imagp = [Float](repeating: 0, count: sliceSize/2)
        outputSlice = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
        vDSP_hann_window(&window, vDSP_Length(sliceSize), Int32(vDSP_HANN_NORM))
    }
   
    func processSamples(samples:[Float]) -> [Float]{
        let size = UInt32(sliceSize)
        let csize = size/2
        
       
        vDSP_vmul(samples, 1, &window, 1, &windowed, 1, vDSP_Length(size))
        let temp = UnsafePointer<Float>(windowed)
        temp.withMemoryRebound(to: DSPComplex.self, capacity: windowed.count) { (typeConvertedTransferBuffer) -> Void in
            vDSP_ctoz(typeConvertedTransferBuffer, 2, &outputSlice, 1, vDSP_Length(csize))
        }

        vDSP_fft_zrip(self.fftSetup, &outputSlice, 1, log2n, FFTDirection(FFT_FORWARD))
        vDSP_zvmags(&outputSlice, 1, &magnitudes, 1, vDSP_Length(Int(csize)))
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: Int(csize))
        vDSP_vsmul(self.sqrtq(magnitudes), 1, [2.0 / Float(Int(csize))], &normalizedMagnitudes, 1, vDSP_Length(Int(csize)))

        return normalizedMagnitudes
    }
    
    private func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }
}
