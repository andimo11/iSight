//
//  ViewController.swift
//  iSight
//
//  Created by Alexander N. Dimopoulos on 12/7/19.
//  Copyright © 2019 Alexander N. Dimopoulos. All rights reserved.
//

//
//  ViewController.swift
//  iSight
//
//  Created by Alexander N. Dimopoulos on 12/7/19.
//  Copyright © 2019 Alexander N. Dimopoulos. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Vision

struct ImageData {
    var dist: String?
    var obj1: String?
    var obj2: String?
    var obj3: String?
    var obj4: String?
}
    
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVSpeechSynthesizerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice)  else {return}
        captureSession.addInput(input)
        captureSession.startRunning()

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    @IBAction func see(_ sender: Any) {
        func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
                    guard let objects = try? VNCoreMLModel(for: YOLOv3TinyFP16().model) else {return}
                    var data = ImageData()
                    let requestObj = VNCoreMLRequest(model: objects) {
                        (finishedReq, err) in
                        guard let results = finishedReq.results as?
                            [VNClassificationObservation] else {return}
                        guard let firstObj = results.first else {return}
                        data.obj1 = firstObj.identifier
                    }
                    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestObj])
                    let synthesizer = AVSpeechSynthesizer()
                    let utterance = AVSpeechUtterance(string: "There is a \(data.obj1 ?? "dog") in front of you")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = 0.1
                    synthesizer.speak(utterance)
                }
        }
    }
    
    
    
