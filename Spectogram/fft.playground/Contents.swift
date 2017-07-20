import UIKit
import Accelerate

func sqrtq(_ x: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}

let sliceSize = 128

var inputSlice = [Float](repeating: 0, count: sliceSize)
var window = [Float](repeating: 0, count: sliceSize)
var transfer = [Float](repeating: 0, count: sliceSize)

vDSP_hann_window(&window, vDSP_Length(sliceSize), Int32(vDSP_HANN_NORM))

let log2n = UInt(round(log2(Double(sliceSize))))
let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
var realp = [Float](repeating: 0, count: sliceSize/2)
var imagp = [Float](repeating: 0, count: sliceSize/2)
var outputSlice = DSPSplitComplex(realp: &realp, imagp: &imagp)

for i in 0...sliceSize/3-1{
    let x:Float = 2 * .pi * Float(i)/Float(sliceSize)
    inputSlice[i] = sin(4*x)
}

//vDSP_vmul(&inputSlice, 1, &window, 1, &transfer, 1, vDSP_Length(sliceSize))
let temp = UnsafePointer<Float>(inputSlice)
temp.withMemoryRebound(to: DSPComplex.self, capacity: transfer.count) { (typeConvertedTransferBuffer) -> Void in
    vDSP_ctoz(typeConvertedTransferBuffer, 2, &outputSlice, 1, vDSP_Length(sliceSize/2))
}
vDSP_fft_zrip(fftSetup!, &outputSlice, 1, log2n, FFTDirection(FFT_FORWARD))

var magnitudes = [Float](repeating: 0.0, count: sliceSize/2)
vDSP_zvmags(&outputSlice, 1, &magnitudes, 1, vDSP_Length(Int(sliceSize/2)))

var normalizedMagnitudes = [Float](repeating: 0.0, count: sliceSize/2)
vDSP_vsmul(sqrtq(magnitudes), 1, [2.0 / Float(sliceSize/2)], &normalizedMagnitudes, 1, vDSP_Length(sliceSize/2))

for i in 0...sliceSize/2-1{
    print("\(normalizedMagnitudes[i])")
}