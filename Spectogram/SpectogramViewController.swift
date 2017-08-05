//
//  SpectogramViewController.swift
//  Spectogram
//
//  Created by Stefano Antonelli on 05/08/2017.
//  Copyright © 2017 SA. All rights reserved.
//

import UIKit
import AVFoundation

enum SVCStatus {
    case idle
    case recording
}
class SpectogramViewController: UIViewController {
    @IBOutlet weak var spectrogramView:SpectogramView!
    let audioEngine  = AVAudioEngine()
    var inputNode:AVAudioNode?
    
    var spectrogram:Spectogram!;
    let sliceSize:Int = 1024
    let slicingWindow:Int = 1024

    var status:SVCStatus = .idle
    var samples:[Float] = []
    
    @IBOutlet weak var recordButton: UIButton!
    @IBAction func recordOrStop(_ sender: Any) {
        if status == .idle {
            try! audioEngine.start()
            status = .recording
            recordButton.setTitle("Stop", for: .normal)
            spectrogramView.clearSlices()
            samples = []
        }else{
            audioEngine.stop()
            status = .idle
            recordButton.setTitle("Record", for: .normal)
            recordButton.isEnabled = false
            processSound()
            recordButton.isEnabled = true
            
        }
    }
    
    func processSound(){
        let slices = spectrogram.processSound(samples: samples, sliceSize: sliceSize, slicingWindow: slicingWindow)
        for slice in slices{
            spectrogramView.addSlice(slice: slice)
        }
    }
    
    func synth(){
        let numberOfNotes = 88
        let sampleRate:Int = 11000
        
        var hz:Float = 27.5000
        let duration = sliceSize
        for note in 0...numberOfNotes-1{
            for i in 0...duration-1{
                let index = (i+note*duration)
                let x:Float = Float(index)/Float(sampleRate)
                samples.append(sin(2*Float.pi*x*hz))
            }
            hz *= Spectogram.noteSeparation
        }
        
        let slices = spectrogram.processSound(samples: samples, sliceSize: sliceSize, slicingWindow: slicingWindow)
        for slice in slices{
            spectrogramView.addSlice(slice: slice)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        spectrogram = Spectogram(sliceSize: sliceSize)
        
        inputNode = audioEngine.inputNode
        let bus = 0
        let ds:UInt32 = 4
        inputNode?.installTap(onBus: bus, bufferSize: UInt32(sliceSize), format: inputNode?.inputFormat(forBus: bus)) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            
            if let floatChannelData = buffer.floatChannelData{
                let sampleCount = buffer.frameLength/UInt32(ds)
                for i in 0...sampleCount-1{
                    var c0:Float = 0
                    var c1:Float = 0
                    for j in 0...ds-1{
                        let index:Int = Int(i*ds + j)
                        c0 += floatChannelData[0][index]
                        c1 += floatChannelData[1][index]
                        
                    }
                    self.samples.append((c0+c1)/(Float(ds)*2))
                }
            }
            print("rate:\(buffer.format.sampleRate)")
            print("bufferSize:\(buffer.frameLength)")
            print("samples:\(self.samples.count)")
            
        }
        
        audioEngine.prepare()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        spectrogramView.prepare()
    }
    

    
}
