//
//  ViewController.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/10/23.
//

import UIKit
import ScanditCaptureCore
import ScanditBarcodeCapture

class ViewController: UIViewController {
  
  var context: DataCaptureContext?
  var barcodeCapture: BarcodeCapture?
  var camera: Camera?
  
  var latestScanResult: BarcodeScanResult? {
    didSet {
      if let latestScanResult = latestScanResult {
        print("New scan: \(latestScanResult) :: \(Date())")
      }
    }
  }
  
  var licenseKey: Dictionary<String, String>? {
    return NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Scandit", ofType: "plist")!) as? Dictionary
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureScandit()
    configureView()
  }
  
  private func configureView() {
    view.backgroundColor = .systemRed
  }
  
  private func configureScandit() {
    configureCapture()
    configureFrameSource()
    configureCaptureView()
  }
  
}

// MARK: - Scandit Configuration

private extension ViewController {
  
  private func getBarcodeSettings() -> BarcodeCaptureSettings {
    let settings = BarcodeCaptureSettings()
    
    settings.set(symbology: .code128, enabled: true)
    settings.set(symbology: .code39, enabled: true)
    settings.set(symbology: .qr, enabled: true)
    settings.set(symbology: .ean8, enabled: true)
    settings.set(symbology: .upce, enabled: true)
    settings.set(symbology: .ean13UPCA, enabled: true)
    
    return settings
  }
  
  private func getCamera() -> Camera {
    let cameraSettings = BarcodeCapture.recommendedCameraSettings
    let camera = Camera.default!
    
    camera.apply(cameraSettings)
    
    return camera
  }
  
  private func configureCapture() {
    let settings = getBarcodeSettings()
    let camera = getCamera()
    
    self.context = DataCaptureContext(licenseKey: self.licenseKey!["0"]!)
    self.barcodeCapture = BarcodeCapture(context: context, settings: settings)
    self.barcodeCapture?.addListener(self)
    self.barcodeCapture?.feedback.success = Feedback(vibration: nil, sound: nil)
    self.camera = camera
  }
  
  private func configureFrameSource() {
    context?.setFrameSource(camera)
    camera?.switch(toDesiredState: .on)
  }
  
  private func configureCaptureView() {
    let captureView = DataCaptureView(context: context, frame: view.bounds)
    let overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture!, view: captureView)
    
    captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    captureView.addOverlay(overlay)
    
    view.addSubview(captureView)
  }
  
}

// MARK: - BarcodeCaptureListener

extension ViewController: BarcodeCaptureListener {
  
  func barcodeCapture(_ barcodeCapture: BarcodeCapture, didScanIn session: BarcodeCaptureSession, frameData: FrameData) {
    let recognizedBarcodes = session.newlyRecognizedBarcodes
    let scanResultString = recognizedBarcodes.first?.jsonString
    
    // Decode scan data
    guard let scanData = scanResultString,
          let scanDataRaw = scanData.data(using: .utf8) else {
      return
    }
    
    guard let decodedScanData = try? JSONDecoder().decode(BarcodeScanResult.self, from: scanDataRaw) else {
      return
    }
    
    // Ensure scan result is new
    if decodedScanData != latestScanResult {
      latestScanResult = decodedScanData
      
      // Set camera to standby, stagger return to "on" state by half a second
      camera?.switch(toDesiredState: .standby) { _ in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0) { [weak self] in
            self?.camera?.switch(toDesiredState: .on)
          }
      }
    }
  }
  
}

